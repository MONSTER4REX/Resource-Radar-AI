"use client";

import { NeedSignal } from "@/lib/types";
import { MapPin, Users, Clock } from "lucide-react";

interface Props {
  signals: NeedSignal[];
  selected: NeedSignal | null;
  onSelect: (signal: NeedSignal) => void;
}

export default function SignalList({ signals, selected, onSelect }: Props) {
  return (
    <div className="w-80 border-l border-white/5 flex flex-col shrink-0">
      <div className="p-4 border-b border-white/5">
        <h2 className="text-sm font-semibold">Signal Feed</h2>
        <p className="text-xs text-slate-500 mt-0.5">{signals.length} signals</p>
      </div>
      <div className="flex-1 overflow-y-auto">
        {signals.map((signal) => (
          <button
            key={signal.signal_id}
            onClick={() => onSelect(signal)}
            className={`w-full text-left p-4 border-b border-white/5 transition-all hover:bg-white/3 ${
              selected?.signal_id === signal.signal_id ? "bg-blue-500/5 border-l-2 border-l-blue-500" : ""
            }`}
          >
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-2">
                <span className={`w-2.5 h-2.5 rounded-full shrink-0 ${urgencyDot(signal.urgency_tier)}`} />
                <span className="text-sm font-medium capitalize">{signal.need_type}</span>
              </div>
              {signal.urgency_score && (
                <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${urgencyBadge(signal.urgency_tier)}`}>
                  {signal.urgency_score}
                </span>
              )}
            </div>
            <div className="mt-2 space-y-1 pl-4.5">
              <div className="flex items-center gap-1.5 text-xs text-slate-400">
                <MapPin size={12} />
                {signal.ward_id}
              </div>
              <div className="flex items-center gap-1.5 text-xs text-slate-400">
                <Users size={12} />
                {signal.people_count} people
              </div>
              <div className="flex items-center gap-1.5 text-xs text-slate-500">
                <Clock size={12} />
                {formatTime(signal.created_at)}
              </div>
            </div>
            {signal.verification_status === "suspicious" && (
              <span className="inline-block mt-2 text-[10px] bg-red-500/10 text-red-400 px-2 py-0.5 rounded-full">
                ⚠ Flagged for review
              </span>
            )}
          </button>
        ))}
      </div>
    </div>
  );
}

function urgencyDot(tier?: string): string {
  switch (tier) {
    case "critical": return "bg-red-500 pulse-critical";
    case "high": return "bg-orange-500";
    case "medium": return "bg-yellow-500";
    case "low": return "bg-emerald-500";
    default: return "bg-slate-500";
  }
}

function urgencyBadge(tier?: string): string {
  switch (tier) {
    case "critical": return "bg-red-500/20 text-red-400";
    case "high": return "bg-orange-500/20 text-orange-400";
    case "medium": return "bg-yellow-500/20 text-yellow-400";
    case "low": return "bg-emerald-500/20 text-emerald-400";
    default: return "bg-slate-500/20 text-slate-400";
  }
}

function formatTime(ts: { seconds: number } | undefined): string {
  if (!ts) return "—";
  const date = new Date(ts.seconds * 1000);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMin = Math.floor(diffMs / 60000);
  if (diffMin < 1) return "Just now";
  if (diffMin < 60) return `${diffMin}m ago`;
  const diffHr = Math.floor(diffMin / 60);
  if (diffHr < 24) return `${diffHr}h ago`;
  return date.toLocaleDateString();
}
