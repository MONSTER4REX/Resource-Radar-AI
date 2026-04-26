import { Firestore } from "@google-cloud/firestore";
import type { NeedSignal } from "./types.js";

const firestore = new Firestore();

export async function saveSignal(signal: NeedSignal): Promise<void> {
    const docRef = firestore.collection("need_signals").doc(signal.signal_id);
    await docRef.set(signal);
}

export async function checkDuplicate(wardId: string, needType: string): Promise<boolean> {
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);
    const snapshot = await firestore.collection("need_signals")
        .where("ward_id", "==", wardId)
        .where("need_type", "==", needType)
        .where("created_at", ">", twoHoursAgo)
        .where("status", "==", "active")
        .limit(1)
        .get();

    return !snapshot.empty;
}
