"use client";

import { NeedSignal } from "@/lib/types";
import { X, Brain, ShieldCheck, ShieldAlert, MapPin, Users, Clock, Camera } from "lucide-react";

interface Props {
  signal: NeedSignal | null;
  onClose: () => void;
}

export default function AISidebar({ signal, onClose }: Props) {
  return (
    <div className="w-96 border-l border-white/5 flex flex-col shrink-0 bg-slate-950/80 backdrop-blur-xl">
      {/* Header */}
      <div className="p-4 border-b border-white/5 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Brain size={18} className="text-blue-400" />
          <h2 className="text-sm font-semibold">AI Analysis</h2>
        </div>
        <button onClick={onClose} className="p-1.5 hover:bg-white/5 rounded-lg">
          <X size={16} />
        </button>
      </div>

      {!signal ? (
        <div className="flex-1 flex items-center justify-center p-8 text-center">
          <div>
            <Brain size={40} className="text-slate-600 mx-auto mb-4" />
            <p className="text-sm text-slate-400">Select a signal to view AI analysis</p>
            <p className="text-xs text-slate-600 mt-1">Gemini reasoning, verification, and suggested actions</p>
          </div>
        </div>
      ) : (
        <div className="flex-1 overflow-y-auto">
          {/* Signal Summary */}
          <div className="p-4 border-b border-white/5">
            <div className="flex items-center justify-between mb-3">
              <span className="text-sm font-semibold capitalize">{signal.need_type} Signal</span>
              <span className={`text-xs font-bold px-2.5 py-1 rounded-full ${tierStyle(signal.urgency_tier)}`}>
                {signal.urgency_tier?.toUpperCase() || "PENDING"}
              </span>
            </div>
            <div className="space-y-2">
              <InfoRow icon={MapPin} label="Location" value={signal.ward_id} />
              <InfoRow icon={Users} label="People" value={`${signal.people_count} affected`} />
              <InfoRow icon={Clock} label="Field Urgency" value={`${signal.urgency_raw} / 5`} />
            </div>
          </div>

          {/* AI Urgency Score */}
          {signal.urgency_score !== undefined && (
            <div className="p-4 border-b border-white/5">
              <p className="text-xs text-slate-500 uppercase tracking-wider mb-3">AI Urgency Score</p>
              <div className="flex items-end gap-3">
                <span className={`text-4xl font-black tabular-nums ${scoreColor(signal.urgency_score)}`}>
                  {signal.urgency_score}
                </span>
                <span className="text-sm text-slate-500 mb-1">/ 100</span>
              </div>
              <div className="mt-3 h-2 rounded-full bg-slate-800 overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all duration-1000 ${scoreBarColor(signal.urgency_score)}`}
                  style={{ width: `${signal.urgency_score}%` }}
                />
              </div>
            </div>
          )}

          {/* Photo Verification */}
          {signal.photo_matches_claim !== undefined && (
            <div className="p-4 border-b border-white/5">
              <p className="text-xs text-slate-500 uppercase tracking-wider mb-3">Photo Verification</p>
              <div className={`flex items-center gap-3 p-3 rounded-xl ${
                signal.photo_matches_claim ? "bg-emerald-500/10" : "bg-red-500/10"
              }`}>
                {signal.photo_matches_claim ? (
                  <>
                    <ShieldCheck size={20} className="text-emerald-400" />
                    <div>
                      <p className="text-sm font-medium text-emerald-400">Verified</p>
                      <p className="text-xs text-slate-400">Photo matches reported claim</p>
                    </div>
                  </>
                ) : (
                  <>
                    <ShieldAlert size={20} className="text-red-400" />
                    <div>
                      <p className="text-sm font-medium text-red-400">Mismatch Detected</p>
                      <p className="text-xs text-slate-400">Photo may not match claim</p>
                    </div>
                  </>
                )}
              </div>
            </div>
          )}

          {/* Gemini Reasoning */}
          {signal.gemini_reasoning && (
            <div className="p-4 border-b border-white/5">
              <div className="flex items-center gap-2 mb-3">
                <Brain size={14} className="text-blue-400" />
                <p className="text-xs text-slate-500 uppercase tracking-wider">Gemini Reasoning</p>
              </div>
              <div className="glass-card p-4">
                <p className="text-sm text-slate-300 leading-relaxed">{signal.gemini_reasoning}</p>
              </div>
            </div>
          )}

          {/* Actions */}
          <div className="p-4">
            <p className="text-xs text-slate-500 uppercase tracking-wider mb-3">Suggested Actions</p>
            <div className="space-y-2">
              <button className="w-full py-2.5 px-4 rounded-xl bg-blue-500/10 text-blue-400 text-sm font-medium hover:bg-blue-500/20 transition-colors">
                Assign Volunteers
              </button>
              <button className="w-full py-2.5 px-4 rounded-xl bg-orange-500/10 text-orange-400 text-sm font-medium hover:bg-orange-500/20 transition-colors">
                Optimize Route
              </button>
              <button className="w-full py-2.5 px-4 rounded-xl bg-white/5 text-slate-300 text-sm font-medium hover:bg-white/10 transition-colors">
                Manual Review
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function InfoRow({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value: string }) {
  return (
    <div className="flex items-center gap-2 text-xs">
      <Icon size={13} className="text-slate-500" />
      <span className="text-slate-500 w-20">{label}</span>
      <span className="text-slate-300">{value}</span>
    </div>
  );
}

function tierStyle(tier?: string): string {
  switch (tier) {
    case "critical": return "bg-red-500/20 text-red-400";
    case "high": return "bg-orange-500/20 text-orange-400";
    case "medium": return "bg-yellow-500/20 text-yellow-400";
    case "low": return "bg-emerald-500/20 text-emerald-400";
    default: return "bg-slate-500/20 text-slate-400";
  }
}

function scoreColor(score: number): string {
  if (score >= 80) return "text-red-400";
  if (score >= 60) return "text-orange-400";
  if (score >= 40) return "text-yellow-400";
  return "text-emerald-400";
}

function scoreBarColor(score: number): string {
  if (score >= 80) return "bg-gradient-to-r from-red-500 to-red-400";
  if (score >= 60) return "bg-gradient-to-r from-orange-500 to-orange-400";
  if (score >= 40) return "bg-gradient-to-r from-yellow-500 to-yellow-400";
  return "bg-gradient-to-r from-emerald-500 to-emerald-400";
}
