"use client";

import { useState, useEffect } from "react";
import { collection, onSnapshot, query, orderBy, limit } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { NeedSignal } from "@/lib/types";
import Sidebar from "./Sidebar";
import SignalList from "./SignalList";
import StatsBar from "./StatsBar";
import AISidebar from "./AISidebar";
import { MapPin, Activity, Brain, Menu, X } from "lucide-react";

export default function Dashboard() {
  const [signals, setSignals] = useState<NeedSignal[]>([]);
  const [selectedSignal, setSelectedSignal] = useState<NeedSignal | null>(null);
  const [showAI, setShowAI] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(true);

  useEffect(() => {
    const q = query(
      collection(db, "need_signals"),
      orderBy("created_at", "desc"),
      limit(100)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = snapshot.docs.map((doc) => doc.data() as NeedSignal);
      setSignals(data);
    });

    return () => unsubscribe();
  }, []);

  const stats = {
    total: signals.length,
    critical: signals.filter((s) => s.urgency_tier === "critical").length,
    active: signals.filter((s) => s.status === "active").length,
    resolved: signals.filter((s) => s.status === "resolved").length,
  };

  return (
    <div className="flex h-screen overflow-hidden">
      {/* Left Nav */}
      <Sidebar open={sidebarOpen} onToggle={() => setSidebarOpen(!sidebarOpen)} />

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Bar */}
        <header className="h-16 border-b border-white/5 flex items-center justify-between px-6 shrink-0">
          <div className="flex items-center gap-3">
            <button onClick={() => setSidebarOpen(!sidebarOpen)} className="lg:hidden p-2 hover:bg-white/5 rounded-lg">
              {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
            <div className="flex items-center gap-2">
              <Activity size={20} className="text-blue-400" />
              <h1 className="text-lg font-semibold tracking-tight">Live Command Center</h1>
            </div>
            <span className="flex items-center gap-1.5 text-xs text-emerald-400 bg-emerald-400/10 px-2.5 py-1 rounded-full">
              <span className="w-1.5 h-1.5 bg-emerald-400 rounded-full animate-pulse" />
              {signals.length} signals live
            </span>
          </div>
          <button
            onClick={() => setShowAI(!showAI)}
            className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all ${
              showAI
                ? "bg-blue-500/20 text-blue-400 border border-blue-500/30"
                : "bg-white/5 hover:bg-white/10 text-slate-300"
            }`}
          >
            <Brain size={16} />
            AI Insights
          </button>
        </header>

        {/* Stats Bar */}
        <StatsBar stats={stats} />

        {/* Content Area */}
        <div className="flex-1 flex overflow-hidden">
          {/* Map Area — Placeholder since Maps SDK needs API key */}
          <div className="flex-1 relative bg-slate-900/50 flex items-center justify-center">
            <div className="text-center space-y-4">
              <div className="w-20 h-20 mx-auto rounded-2xl bg-blue-500/10 flex items-center justify-center">
                <MapPin size={32} className="text-blue-400" />
              </div>
              <div>
                <p className="text-lg font-semibold text-slate-300">Interactive Map View</p>
                <p className="text-sm text-slate-500 mt-1">
                  Configure <code className="text-blue-400 bg-blue-400/10 px-1.5 py-0.5 rounded text-xs">NEXT_PUBLIC_GOOGLE_MAPS_API_KEY</code> to enable
                </p>
              </div>
              {/* Signal Pins Preview */}
              <div className="grid grid-cols-2 gap-3 max-w-xs mx-auto mt-6">
                {signals.slice(0, 4).map((s) => (
                  <button
                    key={s.signal_id}
                    onClick={() => { setSelectedSignal(s); setShowAI(true); }}
                    className="glass-card p-3 text-left hover:border-blue-500/30 transition-all cursor-pointer"
                  >
                    <div className="flex items-center gap-2 mb-1">
                      <span className={`w-2 h-2 rounded-full ${urgencyColor(s.urgency_tier)}`} />
                      <span className="text-xs font-medium capitalize">{s.need_type}</span>
                    </div>
                    <p className="text-[11px] text-slate-500 truncate">{s.ward_id}</p>
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Signal List Panel */}
          <SignalList
            signals={signals}
            selected={selectedSignal}
            onSelect={(s) => { setSelectedSignal(s); setShowAI(true); }}
          />

          {/* AI Sidebar */}
          {showAI && (
            <AISidebar signal={selectedSignal} onClose={() => setShowAI(false)} />
          )}
        </div>
      </div>
    </div>
  );
}

function urgencyColor(tier?: string): string {
  switch (tier) {
    case "critical": return "bg-red-500";
    case "high": return "bg-orange-500";
    case "medium": return "bg-yellow-500";
    case "low": return "bg-emerald-500";
    default: return "bg-slate-500";
  }
}
