"use client";

import { MapPin, Radio, Users, BarChart3, Settings, Shield } from "lucide-react";

interface SidebarProps {
  open: boolean;
  onToggle: () => void;
}

const navItems = [
  { icon: Radio, label: "Live Signals", active: true },
  { icon: MapPin, label: "Map View", active: false },
  { icon: Users, label: "Volunteers", active: false },
  { icon: BarChart3, label: "Analytics", active: false },
  { icon: Shield, label: "Triage Queue", active: false },
  { icon: Settings, label: "Settings", active: false },
];

export default function Sidebar({ open }: SidebarProps) {
  if (!open) return null;

  return (
    <aside className="w-64 border-r border-white/5 flex flex-col shrink-0 bg-slate-950 lg:relative fixed inset-y-0 left-0 z-40">
      {/* Logo */}
      <div className="h-16 flex items-center px-6 border-b border-white/5 gap-3">
        <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-violet-500 flex items-center justify-center">
          <Radio size={16} className="text-white" />
        </div>
        <div>
          <p className="text-sm font-bold tracking-tight">ResourceRadar</p>
          <p className="text-[10px] text-slate-500 uppercase tracking-wider">AI Coordinator</p>
        </div>
      </div>

      {/* Nav Items */}
      <nav className="flex-1 py-4 px-3 space-y-1">
        {navItems.map((item) => (
          <button
            key={item.label}
            className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm transition-all ${
              item.active
                ? "bg-blue-500/10 text-blue-400 font-medium"
                : "text-slate-400 hover:text-slate-200 hover:bg-white/5"
            }`}
          >
            <item.icon size={18} />
            {item.label}
          </button>
        ))}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-white/5">
        <div className="glass-card p-3">
          <p className="text-xs text-slate-400">Powered by</p>
          <p className="text-sm font-semibold mt-0.5">Gemini 1.5 Pro</p>
          <div className="flex items-center gap-1.5 mt-2">
            <span className="w-1.5 h-1.5 bg-emerald-400 rounded-full" />
            <span className="text-[11px] text-emerald-400">AI Engine Online</span>
          </div>
        </div>
      </div>
    </aside>
  );
}
