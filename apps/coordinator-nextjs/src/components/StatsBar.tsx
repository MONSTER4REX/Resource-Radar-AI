"use client";

import { AlertTriangle, CheckCircle, Clock, Zap } from "lucide-react";

interface Stats {
  total: number;
  critical: number;
  active: number;
  resolved: number;
}

export default function StatsBar({ stats }: { stats: Stats }) {
  const cards = [
    { label: "Total Signals", value: stats.total, icon: Zap, color: "text-blue-400", bg: "bg-blue-400/10" },
    { label: "Critical", value: stats.critical, icon: AlertTriangle, color: "text-red-400", bg: "bg-red-400/10" },
    { label: "Active", value: stats.active, icon: Clock, color: "text-amber-400", bg: "bg-amber-400/10" },
    { label: "Resolved", value: stats.resolved, icon: CheckCircle, color: "text-emerald-400", bg: "bg-emerald-400/10" },
  ];

  return (
    <div className="grid grid-cols-4 gap-3 p-4 border-b border-white/5">
      {cards.map((card) => (
        <div key={card.label} className="glass-card p-4 flex items-center gap-3">
          <div className={`w-10 h-10 rounded-xl ${card.bg} flex items-center justify-center`}>
            <card.icon size={18} className={card.color} />
          </div>
          <div>
            <p className="text-2xl font-bold tabular-nums">{card.value}</p>
            <p className="text-xs text-slate-500">{card.label}</p>
          </div>
        </div>
      ))}
    </div>
  );
}
