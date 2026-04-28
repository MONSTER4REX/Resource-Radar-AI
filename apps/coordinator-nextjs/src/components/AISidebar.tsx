"use client";

import { NeedSignal } from "@/lib/types";
import { X, Brain, ShieldCheck, ShieldAlert, MapPin, Users, Clock, Camera, Loader2, UserPlus, CheckCircle2, Navigation, Sparkles } from "lucide-react";
import { useState, useEffect, useRef } from "react";
import { api, VolunteerMatch } from "@/lib/api";
import { doc, updateDoc, arrayUnion } from "firebase/firestore";
import { db } from "@/lib/firebase";
import gsap from "gsap";

interface Props {
  signal: NeedSignal | null;
  onClose: () => void;
}

export default function AISidebar({ signal, onClose }: Props) {
  const [matches, setMatches] = useState<VolunteerMatch[]>([]);
  const [loadingMatches, setLoadingMatches] = useState(false);
  const [loadingRouting, setLoadingRouting] = useState(false);
  const [assigningId, setAssigningId] = useState<string | null>(null);
  
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setMatches([]);
    setLoadingMatches(false);
    
    if (signal) {
      const ctx = gsap.context(() => {
        gsap.from(".ai-content-block", {
          y: 20,
          opacity: 0,
          stagger: 0.1,
          duration: 0.8,
          ease: "expo.out"
        });
      }, containerRef);
      return () => ctx.revert();
    }
  }, [signal?.signal_id]);

  const handleGetMatches = async () => {
    if (!signal) return;
    setLoadingMatches(true);
    try {
      const res = await api.getMatches(signal.signal_id);
      setMatches(res.matches);
    } catch (err) {
      console.error(err);
    } finally {
      setLoadingMatches(false);
    }
  };

  const handleAssign = async (volunteerId: string) => {
    if (!signal) return;
    setAssigningId(volunteerId);
    try {
      const signalRef = doc(db, "need_signals", signal.signal_id);
      await updateDoc(signalRef, {
        assigned_volunteers: arrayUnion(volunteerId),
        status: "assigned"
      });
    } catch (err) {
      console.error("Assignment failed", err);
    } finally {
      setAssigningId(null);
    }
  };

  const handleOptimize = async () => {
    if (!signal) return;
    setLoadingRouting(true);
    try {
      await api.optimizeRoutes(signal.ngo_id, {
        lat: signal.location.latitude,
        lng: signal.location.longitude
      });
      alert("Fleet optimization complete! Routes updated.");
    } catch (err) {
      console.error(err);
      alert("Optimization failed. Check service logs.");
    } finally {
      setLoadingRouting(false);
    }
  };

  return (
    <div ref={containerRef} className="w-[380px] flex flex-col shrink-0 glass-card border-white/5 h-full overflow-hidden bg-slate-950/40">
      {/* Header */}
      <div className="p-6 border-b border-white/5 flex items-center justify-between bg-white/2">
        <div className="flex items-center gap-3">
          <div className="p-2 rounded-xl bg-sky-500/10 border border-sky-500/20">
            <Brain size={20} className="text-sky-400" />
          </div>
          <div>
            <h2 className="text-sm font-black uppercase tracking-[0.1em] text-white">AI Analysis</h2>
            <p className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Gemini Engine v1.5</p>
          </div>
        </div>
        <button onClick={onClose} className="p-2 hover:bg-white/5 rounded-xl transition-colors">
          <X size={18} className="text-slate-400" />
        </button>
      </div>

      {!signal ? (
        <div className="flex-1 flex items-center justify-center p-12 text-center">
          <div className="floating">
            <div className="w-20 h-20 bg-sky-500/5 rounded-full flex items-center justify-center mx-auto mb-6 border border-sky-500/10">
              <Sparkles size={32} className="text-sky-400/40" />
            </div>
            <p className="text-sm font-bold text-slate-400">Select a Signal</p>
            <p className="text-[11px] text-slate-600 mt-2 max-w-[200px] mx-auto">Activate AI processing by selecting an active request from the map or feed.</p>
          </div>
        </div>
      ) : (
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {/* Signal Summary */}
          <div className="ai-content-block p-5 glass-card bg-white/2 border-white/5">
            <div className="flex items-center justify-between mb-4">
              <span className="text-xs font-black uppercase tracking-widest text-slate-400">{signal.need_type} Request</span>
              <span className={`text-[10px] font-black px-3 py-1 rounded-full ${tierStyle(signal.urgency_tier)}`}>
                {signal.urgency_tier?.toUpperCase() || "PENDING"}
              </span>
            </div>
            <div className="space-y-3">
              <InfoRow icon={MapPin} label="Ward ID" value={signal.ward_id} />
              <InfoRow icon={Users} label="Population" value={`${signal.people_count} affected`} />
              <InfoRow icon={Clock} label="Raw Urgency" value={`${signal.urgency_raw} / 5`} />
            </div>
          </div>

          {/* AI Urgency Score */}
          {signal.urgency_score !== undefined && (() => {
            const displayScore = signal.urgency_score <= 10 ? Math.round(signal.urgency_score * 10) : Math.round(signal.urgency_score);
            return (
              <div className="ai-content-block">
                <div className="flex items-center justify-between mb-3">
                  <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Calculated Urgency</p>
                  <span className={`text-xl font-black whitespace-nowrap ${scoreColor(displayScore)}`}>
                    {displayScore}<span className="text-[10px] text-slate-600 ml-0.5">/100</span>
                  </span>
                </div>
                <div className="h-2 rounded-full bg-slate-900 border border-white/5 overflow-hidden p-0.5">
                  <div
                    className={`h-full rounded-full transition-all duration-1000 ${scoreBarColor(displayScore)}`}
                    style={{ width: `${displayScore}%` }}
                  />
                </div>
              </div>
            );
          })()}

          {/* Photo Verification */}
          {signal.photo_matches_claim !== undefined && (
            <div className="ai-content-block">
              <div className={`flex items-center gap-4 p-4 rounded-2xl border ${
                signal.photo_matches_claim ? "bg-emerald-500/5 border-emerald-500/20" : "bg-red-500/5 border-red-500/20"
              }`}>
                <div className={`p-2.5 rounded-xl ${signal.photo_matches_claim ? "bg-emerald-500/10" : "bg-red-500/10"}`}>
                  {signal.photo_matches_claim ? (
                    <ShieldCheck size={22} className="text-emerald-400" />
                  ) : (
                    <ShieldAlert size={22} className="text-red-400" />
                  )}
                </div>
                <div>
                  <p className={`text-sm font-black uppercase tracking-tight ${signal.photo_matches_claim ? "text-emerald-400" : "text-red-400"}`}>
                    {signal.photo_matches_claim ? "Visual Match Verified" : "Visual Mismatch"}
                  </p>
                  <p className="text-[10px] text-slate-500 font-medium mt-0.5">Cross-referenced with on-field imagery</p>
                </div>
              </div>
            </div>
          )}

          {/* Gemini Reasoning */}
          {signal.gemini_reasoning && (
            <div className="ai-content-block">
              <div className="flex items-center gap-2 mb-3">
                <Brain size={14} className="text-sky-400" />
                <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Reasoning Analysis</p>
              </div>
              <div className="p-5 glass-card bg-sky-500/5 border-sky-500/10">
                <p className="text-xs text-slate-300 leading-relaxed font-medium italic">"{signal.gemini_reasoning}"</p>
              </div>
            </div>
          )}

          {/* Actions */}
          <div className="ai-content-block space-y-3 pt-4 border-t border-white/5">
            <button 
              onClick={handleGetMatches}
              disabled={loadingMatches}
              className="w-full py-3.5 px-6 rounded-2xl bg-sky-500 text-white text-[11px] font-black uppercase tracking-[0.2em] hover:bg-sky-400 transition-all shadow-xl shadow-sky-500/20 flex items-center justify-center gap-3 disabled:opacity-50"
            >
              {loadingMatches ? (
                <Loader2 size={16} className="animate-spin" />
              ) : (
                <Users size={16} />
              )}
              Find Best Matches
            </button>
            
            <button 
              onClick={handleOptimize}
              disabled={loadingRouting}
              className="w-full py-3.5 px-6 rounded-2xl bg-white/5 border border-white/10 text-slate-300 text-[11px] font-black uppercase tracking-[0.2em] hover:bg-white/10 transition-all flex items-center justify-center gap-3 disabled:opacity-50"
            >
              {loadingRouting ? (
                <Loader2 size={16} className="animate-spin" />
              ) : (
                <Navigation size={16} />
              )}
              Optimize Routes
            </button>
          </div>

          {/* Match Results */}
          {matches.length > 0 && (
            <div className="ai-content-block mt-8 space-y-4">
              <p className="text-[10px] font-black text-sky-400 uppercase tracking-[0.3em]">Responder Recommendations</p>
              {matches.map((match) => (
                <div key={match.volunteer_id} className="glass-card p-4 border-white/5 bg-white/2 hover:bg-white/5 transition-all group overflow-hidden relative">
                  <div className="flex items-start justify-between gap-4 relative z-10">
                    <div className="min-w-0">
                      <p className="text-sm font-black text-white truncate">{match.display_name}</p>
                      <div className="flex items-center gap-2 mt-1.5">
                        <span className="text-[10px] text-sky-400 font-black bg-sky-400/10 px-2 py-0.5 rounded uppercase">{match.distance_km.toFixed(1)} km</span>
                        <span className="text-[10px] text-slate-500 font-bold">•</span>
                        <span className="text-[10px] text-slate-400 font-bold uppercase tracking-tighter">Ready to Deploy</span>
                      </div>
                      <div className="flex flex-wrap gap-1.5 mt-3">
                        {match.skills.slice(0, 2).map(skill => (
                          <span key={skill} className="text-[9px] px-2 py-1 rounded bg-slate-900 text-slate-400 border border-white/5 uppercase font-black tracking-widest">
                            {skill}
                          </span>
                        ))}
                      </div>
                    </div>
                    <button 
                      onClick={() => handleAssign(match.volunteer_id)}
                      disabled={assigningId === match.volunteer_id || signal.assigned_volunteers?.includes(match.volunteer_id)}
                      className={`p-3 rounded-xl transition-all ${
                        signal.assigned_volunteers?.includes(match.volunteer_id)
                          ? "bg-emerald-500/20 text-emerald-400"
                          : "bg-sky-500/10 text-sky-400 hover:bg-sky-500 hover:text-white"
                      }`}
                    >
                      {assigningId === match.volunteer_id ? (
                        <Loader2 size={18} className="animate-spin" />
                      ) : signal.assigned_volunteers?.includes(match.volunteer_id) ? (
                        <CheckCircle2 size={18} />
                      ) : (
                        <UserPlus size={18} />
                      )}
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function InfoRow({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value: string }) {
  return (
    <div className="flex flex-col gap-1.5 py-1 border-b border-white/5 last:border-0">
      <div className="flex items-center gap-2 text-slate-500 uppercase tracking-widest text-[9px] font-black">
        <Icon size={10} />
        <span>{label}</span>
      </div>
      <span className="text-white text-[11px] font-bold tracking-tight pl-4.5">{value}</span>
    </div>
  );
}

function tierStyle(tier?: string): string {
  switch (tier) {
    case "critical": return "bg-red-500/20 text-red-400 border border-red-500/20 shadow-[0_0_15px_rgba(239,68,68,0.2)]";
    case "high": return "bg-orange-500/20 text-orange-400 border border-orange-500/20";
    case "medium": return "bg-yellow-500/20 text-yellow-400 border border-yellow-500/20";
    case "low": return "bg-emerald-500/20 text-emerald-400 border border-emerald-500/20";
    default: return "bg-slate-500/20 text-slate-400";
  }
}

function scoreColor(score: number): string {
  if (score >= 80) return "text-red-400 text-glow";
  if (score >= 60) return "text-orange-400";
  if (score >= 40) return "text-yellow-400";
  return "text-emerald-400";
}

function scoreBarColor(score: number): string {
  if (score >= 80) return "bg-gradient-to-r from-red-500 to-red-400 shadow-[0_0_10px_rgba(239,68,68,0.4)]";
  if (score >= 60) return "bg-gradient-to-r from-orange-500 to-orange-400";
  if (score >= 40) return "bg-gradient-to-r from-yellow-500 to-yellow-400";
  return "bg-gradient-to-r from-emerald-500 to-emerald-400";
}
