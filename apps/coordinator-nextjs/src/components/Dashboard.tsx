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

import MapComponent from "./MapComponent";

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
      const data = snapshot.docs.map((doc) => ({
        ...doc.data(),
        signal_id: doc.id,
      } as NeedSignal));
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
          {/* Map Area */}
          <div className="flex-1 relative bg-slate-900/50">
            <MapComponent 
              signals={signals} 
              selectedSignal={selectedSignal}
              onSignalSelect={(s) => { setSelectedSignal(s); setShowAI(true); }}
            />
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
