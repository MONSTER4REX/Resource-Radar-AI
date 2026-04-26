import type { RawSignal, NeedSignal, VerificationStatus, SignalStatus } from "./types.js";
import { geocodeWard } from "./geocoder.js";
import { saveSignal, checkDuplicate } from "./firestore-client.js";
import { v4 as uuidv4 } from "uuid";

export async function processRawSignal(raw: RawSignal): Promise<void> {
    console.log(`Processing raw signal from ${raw.source_channel} for ward ${raw.ward_id}`);

    // 1. Geocode ward
    const location = await geocodeWard(raw.ward_id, raw.city_id);
    if (!location) {
        console.error(`Failed to geocode ward: ${raw.ward_id}`);
        // In a real app, we might move this to a 'manual_review' queue
        return;
    }

    // 2. Check for duplicates (last 2 hours, same ward and type)
    const isDuplicate = await checkDuplicate(raw.ward_id, raw.need_type);

    // 3. Construct canonical NeedSignal
    const signal: NeedSignal = {
        ...raw,
        signal_id: uuidv4(),
        verification_status: 'pending',
        duplicate_risk: isDuplicate,
        location: location,
        status: isDuplicate ? 'duplicate' : 'active',
        assigned_volunteers: [],
        created_at: new Date(),
        ngo_id: process.env.DEFAULT_NGO_ID || "NGO_ROOT",
    };

    // 4. Save to Firestore
    await saveSignal(signal);
    console.log(`Signal ${signal.signal_id} saved successfully. Duplicate: ${isDuplicate}`);

    // 5. Trigger Triage Service
    if (!isDuplicate && process.env.TRIAGE_SERVICE_URL) {
        try {
            await fetch(process.env.TRIAGE_SERVICE_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    signal_id: signal.signal_id,
                    text: signal.notes || `Need ${signal.need_type} for ${signal.people_count} people at ${signal.ward_id}`,
                    photo_url: signal.photo_url
                })
            });
            console.log(`Triage triggered for ${signal.signal_id}`);
        } catch (e) {
            console.error(`Failed to trigger triage: ${e}`);
        }
    }
}
