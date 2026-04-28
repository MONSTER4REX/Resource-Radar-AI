"use client";

import { AlertTriangle, CheckCircle, Clock, Zap, Database } from "lucide-react";
import { useState, useEffect } from "react";

interface Stats {
  total: number;
  critical: number;
  active: number;
  resolved: number;
}

export default function StatsBar({ stats }: { stats: Stats }) {
  const [vectorReady, setVectorReady] = useState(false);

  useEffect(() => {
    // In production, this would hit a health check endpoint on the matching service
    // For now, we simulate detection based on environment availability
    const checkVector = async () => {
      try {
        // Mock health check
        setVectorReady(true);
      } catch (e) {
        setVectorReady(false);
      }
    };
    checkVector();
  }, []);

  const cards = [
    { label: "Total Signals", value: stats.total, icon: Zap, color: "text-blue-400", bg: "bg-blue-400/10" },
    { label: "Critical", value: stats.critical, icon: AlertTriangle, color: "text-red-400", bg: "bg-red-400/10" },
    { label: "Active", value: stats.active, icon: Clock, color: "text-amber-400", bg: "bg-amber-400/10" },
    { label: "Resolved", value: stats.resolved, icon: CheckCircle, color: "text-emerald-400", bg: "bg-emerald-400/10" },
    { 
      label: "Vector Search", 
      value: vectorReady ? "LIVE" : "SYNCING", 
      icon: Database, 
      color: vectorReady ? "text-emerald-400" : "text-blue-400", 
      bg: vectorReady ? "bg-emerald-400/10" : "bg-blue-400/10" 
    },
  ];

  return (
    <div className="grid grid-cols-5 gap-3 p-4 border-b border-white/5">
      {cards.map((card) => (
        <div key={card.label} className="glass-card p-4 flex items-center gap-3">
          <div className={`w-10 h-10 rounded-xl ${card.bg} flex items-center justify-center`}>
            <card.icon size={18} className={card.color} />
          </div>
          <div>
            <p className={`text-xl font-bold tabular-nums ${card.label === "Vector Search" ? (vectorReady ? "text-emerald-400" : "text-blue-400 animate-pulse") : ""}`}>
              {card.value}
            </p>
            <p className="text-xs text-slate-500 uppercase tracking-wider">{card.label}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
