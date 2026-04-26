export type NeedType = 'food' | 'water' | 'medicine' | 'shelter' | 'clothing' | 'other';
export type UrgencyTier = 'critical' | 'high' | 'medium' | 'low';
export type VerificationStatus = 'verified' | 'suspicious' | 'needs_review' | 'pending';
export type SourceChannel = 'field_form' | 'whatsapp' | 'sms' | 'civic_api';
export type SignalStatus = 'active' | 'assigned' | 'resolved' | 'duplicate' | 'false_report';

export interface RawSignal {
    ward_id: string;
    city_id: string;
    need_type: NeedType;
    people_count: number;
    urgency_raw: number; // 1-5
    photo_url?: string;
    notes?: string;
    reporter_id: string;
    reporter_role: string;
    source_channel: SourceChannel;
}

export interface NeedSignal extends RawSignal {
    signal_id: string;
    urgency_score?: number; // 0-100 (Gemini)
    urgency_tier?: UrgencyTier;
    photo_matches_claim?: boolean;
    verification_status: VerificationStatus;
    duplicate_risk: boolean;
    gemini_reasoning?: string;
    location: {
        latitude: number;
        longitude: number;
    };
    status: SignalStatus;
    assigned_volunteers: string[];
    assigned_vehicle_route?: string;
    created_at: Date | { seconds: number; nanoseconds: number };
    triaged_at?: Date | { seconds: number; nanoseconds: number };
    resolved_at?: Date | { seconds: number; nanoseconds: number };
    ngo_id: string;
}
