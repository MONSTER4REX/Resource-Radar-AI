"use client";

import { NeedSignal } from "@/lib/types";
import { MapPin, Users, Clock, Signal, Info } from "lucide-react";
import { useEffect, useRef } from "react";
import gsap from "gsap";

interface Props {
  signals: NeedSignal[];
  selected: NeedSignal | null;
  onSelect: (signal: NeedSignal) => void;
}

export default function SignalList({ signals, selected, onSelect }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (signals.length > 0) {
      const ctx = gsap.context(() => {
        gsap.from(".signal-item", {
          x: 30,
          opacity: 0,
          stagger: 0.05,
          duration: 0.8,
          ease: "power3.out",
          clearProps: "all"
        });
      }, containerRef);
      return () => ctx.revert();
    }
  }, [signals.length]);

  return (
    <div ref={containerRef} className="flex flex-col h-full gap-4">
      <div className="px-4 py-2 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Signal size={14} className="text-sky-400" />
          <h2 className="text-[11px] font-black uppercase tracking-[0.2em] text-slate-400">Signal Feed</h2>
        </div>
        <span className="text-[10px] font-black text-sky-400 bg-sky-400/10 px-3 py-1 rounded-full border border-sky-400/20">{signals.length} ACTIVE</span>
      </div>
      
      <div className="flex-1 overflow-y-auto space-y-4 pr-2 scrollbar-hide pb-12">
        {signals.length === 0 ? (
          <div className="p-8 text-center glass-card border-dashed border-white/5 opacity-50">
            <Info size={24} className="mx-auto mb-3 text-slate-600" />
            <p className="text-xs font-bold text-slate-500">No signals match your filter</p>
          </div>
        ) : (
          signals.map((signal) => (
            <button
              key={signal.signal_id}
              onClick={() => onSelect(signal)}
              className={`signal-item w-full text-left p-5 glass-card border-white/5 transition-all group relative overflow-hidden ${
                selected?.signal_id === signal.signal_id 
                  ? "border-sky-500/40 bg-sky-500/5 ring-1 ring-sky-500/20 translate-x-2" 
                  : "hover:border-white/10 hover:bg-white/2"
              }`}
            >
              {selected?.signal_id === signal.signal_id && (
                <div className="absolute left-0 top-0 bottom-0 w-1 bg-sky-500 shadow-glow" />
              )}
              
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className={`w-3 h-3 rounded-full shrink-0 ${urgencyDot(signal.urgency_tier, signal.urgency_score)}`} />
                  <span className="text-sm font-black text-white capitalize tracking-tight">{signal.need_type || "Unknown"}</span>
                </div>
                {(signal.urgency_score !== undefined || signal.urgency_tier) && (
                  <span className={`text-[10px] font-black px-2.5 py-1 rounded-lg ${urgencyBadge(signal.urgency_tier, signal.urgency_score)}`}>
                    {signal.urgency_score !== undefined ? signal.urgency_score : signal.urgency_tier?.toUpperCase() || "NEW"}
                  </span>
                )}
              </div>

              <div className="mt-4 grid grid-cols-2 gap-4">
                <div className="flex items-center gap-2 text-[11px] text-slate-400 font-bold">
                  <MapPin size={13} className="text-slate-600 shrink-0" />
                  <span className="truncate uppercase tracking-tight">{signal.ward_id || "Unspecified"}</span>
                </div>
                <div className="flex items-center gap-2 text-[11px] text-slate-400 font-bold">
                  <Users size={13} className="text-slate-600 shrink-0" />
                  <span className="truncate">{signal.people_count || "Unknown"} PEOPLE</span>
                </div>
              </div>

              <div className="mt-4 flex items-center justify-between pt-4 border-t border-white/5">
                <div className="flex items-center gap-2 text-[10px] text-slate-500 font-black uppercase tracking-widest">
                  <Clock size={12} className="text-slate-600" />
                  {formatTime(signal.created_at)}
                </div>
                {signal.verification_status === "suspicious" && (
                  <span className="text-[9px] font-black text-red-400 bg-red-400/10 px-2 py-1 rounded border border-red-400/20 uppercase tracking-tighter">
                    SUSPICIOUS
                  </span>
                )}
              </div>
            </button>
          ))
        )}
      </div>
    </div>
  );
}

function urgencyDot(tier?: string, score?: number): string {
  let effectiveTier = tier;
  if ((!tier || tier === "pending") && score !== undefined) {
    if (score >= 80) effectiveTier = "critical";
    else if (score >= 60) effectiveTier = "high";
    else if (score >= 40) effectiveTier = "medium";
    else effectiveTier = "low";
  }

  switch (effectiveTier) {
    case "critical": return "bg-red-500 pulse-critical shadow-[0_0_12px_rgba(239,68,68,0.6)]";
    case "high": return "bg-orange-500 shadow-[0_0_10px_rgba(249,115,22,0.4)]";
    case "medium": return "bg-yellow-500 shadow-[0_0_10px_rgba(234,179,8,0.4)]";
    case "low": return "bg-emerald-500 shadow-[0_0_10px_rgba(16,185,129,0.4)]";
    default: return "bg-slate-500";
  }
}

function urgencyBadge(tier?: string, score?: number): string {
  let effectiveTier = tier;
  if ((!tier || tier === "pending") && score !== undefined) {
    if (score >= 80) effectiveTier = "critical";
    else if (score >= 60) effectiveTier = "high";
    else if (score >= 40) effectiveTier = "medium";
    else effectiveTier = "low";
  }

  switch (effectiveTier) {
    case "critical": return "bg-red-500/20 text-red-400 border border-red-500/20";
    case "high": return "bg-orange-500/20 text-orange-400 border border-orange-500/20";
    case "medium": return "bg-yellow-500/20 text-yellow-400 border border-yellow-500/20";
    case "low": return "bg-emerald-500/20 text-emerald-400 border border-emerald-400/20";
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
  if (diffMin < 60) return `${diffMin}M ago`;
  const diffHr = Math.floor(diffMin / 60);
  if (diffHr < 24) return `${diffHr}H ago`;
  return date.toLocaleDateString();
}
