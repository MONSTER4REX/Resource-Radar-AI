export type NeedType = "food" | "water" | "medicine" | "shelter" | "clothing" | "other";
export type UrgencyTier = "critical" | "high" | "medium" | "low";
export type VerificationStatus = "verified" | "suspicious" | "needs_review" | "pending";
export type SignalStatus = "active" | "assigned" | "resolved" | "duplicate" | "false_report";

export interface NeedSignal {
  signal_id: string;
  ward_id: string;
  city_id: string;
  need_type: NeedType;
  people_count: number;
  urgency_raw: number;
  urgency_score?: number;
  urgency_tier?: UrgencyTier;
  photo_url?: string;
  notes?: string;
  reporter_id: string;
  verification_status: VerificationStatus;
  duplicate_risk: boolean;
  gemini_reasoning?: string;
  photo_matches_claim?: boolean;
  location: { latitude: number; longitude: number };
  status: SignalStatus;
  assigned_volunteers: string[];
  assigned_vehicle_route?: string;
  created_at: { seconds: number; nanoseconds: number };
  triaged_at?: { seconds: number; nanoseconds: number };
  ngo_id: string;
}
