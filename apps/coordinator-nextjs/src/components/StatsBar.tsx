"use client";

import { AlertTriangle, CheckCircle, Clock, Zap, Database, TrendingUp } from "lucide-react";
import { useState, useEffect, useRef } from "react";
import gsap from "gsap";

interface Stats {
  total: number;
  critical: number;
  active: number;
  resolved: number;
}

export default function StatsBar({ stats }: { stats: Stats }) {
  const [vectorReady, setVectorReady] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setVectorReady(true);
    
    const ctx = gsap.context(() => {
      gsap.from(".stat-card", {
        scale: 0.9,
        opacity: 0,
        y: 20,
        stagger: 0.1,
        duration: 0.8,
        ease: "expo.out",
        delay: 0.5
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const cards = [
    { label: "Total Signals", value: stats.total, icon: Zap, color: "text-sky-400", bg: "bg-sky-400/10", border: "border-sky-400/20" },
    { label: "Critical", value: stats.critical, icon: AlertTriangle, color: "text-red-400", bg: "bg-red-400/10", border: "border-red-400/20" },
    { label: "Active", value: stats.active, icon: Clock, color: "text-amber-400", bg: "bg-amber-400/10", border: "border-amber-400/20" },
    { label: "Resolved", value: stats.resolved, icon: CheckCircle, color: "text-emerald-400", bg: "bg-emerald-400/10", border: "border-emerald-400/20" },
    { 
      label: "Vector Search", 
      value: vectorReady ? "LIVE" : "...", 
      icon: Database, 
      color: vectorReady ? "text-emerald-400" : "text-slate-600", 
      bg: vectorReady ? "bg-emerald-400/10" : "bg-white/5",
      border: vectorReady ? "border-emerald-400/20" : "border-white/5"
    },
  ];

  return (
    <div ref={containerRef} className="grid grid-cols-5 gap-6 px-6 py-4">
      {cards.map((card) => (
        <div key={card.label} className={`stat-card glass-card p-5 flex items-center gap-5 group border-white/5 bg-slate-900/20`}>
          <div className={`w-14 h-14 rounded-2xl ${card.bg} border ${card.border} flex items-center justify-center transition-all group-hover:scale-110 duration-500 group-hover:shadow-glow`}>
            <card.icon size={26} className={card.color} />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between">
              <p className={`text-2xl font-black tabular-nums tracking-tight ${card.label === "Vector Search" ? (vectorReady ? "text-emerald-400 text-glow" : "text-slate-600") : "text-white"}`}>
                {card.value}
              </p>
              <TrendingUp size={14} className="text-slate-600 opacity-0 group-hover:opacity-100 transition-opacity" />
            </div>
            <p className="text-[10px] text-slate-500 uppercase tracking-[0.2em] font-black mt-1">{card.label}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
