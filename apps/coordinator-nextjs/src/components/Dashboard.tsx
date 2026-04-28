"use client";

import { useState, useEffect, useRef } from "react";
import { collection, onSnapshot, query, orderBy, limit } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { NeedSignal } from "@/lib/types";
import Sidebar, { ActiveView } from "./Sidebar";
import SignalList from "./SignalList";
import StatsBar from "./StatsBar";
import AISidebar from "./AISidebar";
import { Activity, Brain, Menu, X, Search, Users, BarChart3, Shield, Settings, MapPin } from "lucide-react";
import MapComponent from "./MapComponent";
import gsap from "gsap";

const MOCK_SIGNALS: NeedSignal[] = [
  {
    signal_id: "mock-1",
    need_type: "medicine",
    urgency_tier: "critical",
    urgency_score: 98,
    urgency_raw: 4.9,
    ward_id: "W-104",
    city_id: "delhi",
    people_count: 5,
    status: "active",
    location: { latitude: 28.6139, longitude: 77.209 },
    created_at: { seconds: Math.floor(Date.now() / 1000) - 300, nanoseconds: 0 },
    verification_status: "verified",
    duplicate_risk: false,
    assigned_volunteers: [],
    reporter_id: "demo",
    ngo_id: "demo-ngo",
    gemini_reasoning: "Critical medical supplies needed for 5 patients with chronic conditions. Photo analysis confirms depleted pharmacy stock. Urgency elevated due to proximity to hospital closure zone.",
    photo_matches_claim: true,
  },
  {
    signal_id: "mock-2",
    need_type: "water",
    urgency_tier: "high",
    urgency_score: 85,
    urgency_raw: 4.2,
    ward_id: "W-102",
    city_id: "delhi",
    people_count: 25,
    status: "active",
    location: { latitude: 28.62, longitude: 77.22 },
    created_at: { seconds: Math.floor(Date.now() / 1000) - 1800, nanoseconds: 0 },
    verification_status: "verified",
    duplicate_risk: false,
    assigned_volunteers: [],
    reporter_id: "demo",
    ngo_id: "demo-ngo",
    gemini_reasoning: "Water supply disruption affecting 25 residents in temporary shelters. Satellite imagery confirms pipeline damage in the area. Nearest tanker service is 4.2 km away.",
    photo_matches_claim: true,
  },
  {
    signal_id: "mock-3",
    need_type: "food",
    urgency_tier: "medium",
    urgency_score: 62,
    urgency_raw: 3.1,
    ward_id: "W-098",
    city_id: "delhi",
    people_count: 12,
    status: "active",
    location: { latitude: 28.61, longitude: 77.23 },
    created_at: { seconds: Math.floor(Date.now() / 1000) - 3600, nanoseconds: 0 },
    verification_status: "verified",
    duplicate_risk: false,
    assigned_volunteers: [],
    reporter_id: "demo",
    ngo_id: "demo-ngo",
    gemini_reasoning: "Food distribution needed for 12 displaced individuals. Current rations estimated to last 18 hours. Cross-referenced with nearby community kitchen availability.",
  },
  {
    signal_id: "mock-4",
    need_type: "shelter",
    urgency_tier: "high",
    urgency_score: 81,
    urgency_raw: 4.0,
    ward_id: "W-077",
    city_id: "delhi",
    people_count: 40,
    status: "active",
    location: { latitude: 28.63, longitude: 77.21 },
    created_at: { seconds: Math.floor(Date.now() / 1000) - 900, nanoseconds: 0 },
    verification_status: "verified",
    duplicate_risk: false,
    assigned_volunteers: [],
    reporter_id: "demo",
    ngo_id: "demo-ngo",
    gemini_reasoning: "40 individuals require temporary shelter due to structural damage. Weather forecast indicates rain in next 6 hours. Three potential sites identified within 2 km radius.",
    photo_matches_claim: true,
  },
];

const VIEW_LABELS: Record<ActiveView, string> = {
  signals: "Live Signals",
  map: "Map View",
  volunteers: "Volunteers",
  analytics: "Analytics",
  triage: "Triage Queue",
  settings: "Settings",
};

const VIEW_ICONS: Record<ActiveView, React.ElementType> = {
  signals: Activity,
  map: MapPin,
  volunteers: Users,
  analytics: BarChart3,
  triage: Shield,
  settings: Settings,
};

function PlaceholderView({ view }: { view: ActiveView }) {
  const Icon = VIEW_ICONS[view];
  return (
    <div className="flex-1 flex flex-col items-center justify-center gap-6 text-center p-12">
      <div className="w-24 h-24 rounded-3xl bg-blue-500/10 border border-blue-500/20 flex items-center justify-center">
        <Icon size={40} className="text-blue-400" />
      </div>
      <div>
        <h2 className="text-2xl font-black text-white mb-2 tracking-tight">{VIEW_LABELS[view]}</h2>
        <p className="text-slate-400 text-sm max-w-sm leading-relaxed">
          This section is under active development. Real-time {VIEW_LABELS[view].toLowerCase()} data will appear here once the backend integration is complete.
        </p>
      </div>
      <div className="flex gap-2 items-center px-4 py-2 rounded-xl border border-blue-500/20 bg-blue-500/5">
        <span className="w-1.5 h-1.5 bg-blue-400 rounded-full animate-pulse" />
        <span className="text-[11px] font-black text-blue-400 uppercase tracking-widest">Connecting to backend…</span>
      </div>
    </div>
  );
}

export default function Dashboard() {
  const [signals, setSignals] = useState<NeedSignal[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedSignal, setSelectedSignal] = useState<NeedSignal | null>(null);
  const [showAI, setShowAI] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [activeView, setActiveView] = useState<ActiveView>("signals");
  const [mounted, setMounted] = useState(false);

  const headerRef = useRef<HTMLElement>(null);
  const contentRef = useRef<HTMLElement>(null);

  useEffect(() => { setMounted(true); }, []);

  useEffect(() => {
    const q = query(collection(db, "need_signals"), orderBy("created_at", "desc"), limit(100));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      setSignals(snapshot.docs.map((doc) => ({ ...doc.data(), signal_id: doc.id } as NeedSignal)));
    }, () => { /* silently use mock data on error */ });

    const ctx = gsap.context(() => {
      gsap.from(headerRef.current, { y: -40, opacity: 0, duration: 0.8, ease: "expo.out" });
      gsap.from(".stats-animate", { y: 20, opacity: 0, stagger: 0.07, duration: 0.7, ease: "power4.out", delay: 0.2 });
      gsap.from(contentRef.current, { scale: 0.98, opacity: 0, duration: 0.8, ease: "expo.out", delay: 0.3 });
    });

    return () => { unsubscribe(); ctx.revert(); };
  }, []);

  const displaySignals = signals.length > 0 ? signals : MOCK_SIGNALS;
  const filteredSignals = displaySignals.filter(
    (s) => s.need_type.toLowerCase().includes(searchQuery.toLowerCase()) || s.ward_id.toLowerCase().includes(searchQuery.toLowerCase())
  );
  const stats = {
    total: displaySignals.length,
    critical: displaySignals.filter((s) => s.urgency_tier === "critical").length,
    active: displaySignals.filter((s) => s.status === "active").length,
    resolved: displaySignals.filter((s) => s.status === "resolved").length,
  };

  const ViewIcon = VIEW_ICONS[activeView];

  if (!mounted) return <div className="h-screen w-screen bg-slate-950" />;

  return (
    <div className="flex h-screen overflow-hidden bg-mesh relative" style={{ isolation: "isolate" }}>

      {/* Sidebar */}
      <Sidebar
        open={sidebarOpen}
        onToggle={() => setSidebarOpen((o) => !o)}
        activeView={activeView}
        onViewChange={(v) => setActiveView(v)}
      />

      {/* Mobile overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 bg-black/60 z-30 lg:hidden" onClick={() => setSidebarOpen(false)} />
      )}

      {/* Main */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden relative z-10">

        {/* Header */}
        <header
          ref={headerRef}
          className="shrink-0 h-16 border-b border-white/5 flex items-center justify-between px-5 bg-slate-950/60 backdrop-blur-xl z-20 relative"
        >
          <div className="flex items-center gap-3 flex-1 min-w-0">
            <button
              onClick={() => setSidebarOpen((o) => !o)}
              className="lg:hidden p-2 rounded-xl bg-white/5 border border-white/10 text-slate-400 hover:text-white transition-all"
            >
              {sidebarOpen ? <X size={16} /> : <Menu size={16} />}
            </button>
            <div className="flex items-center gap-2.5 shrink-0">
              <div className="p-2 rounded-xl bg-blue-500/10 border border-blue-500/20">
                <ViewIcon size={18} className="text-blue-400" />
              </div>
              <div>
                <h1 className="text-sm font-bold text-white">{VIEW_LABELS[activeView]}</h1>
                <p className="text-[9px] text-slate-500 uppercase tracking-widest font-bold hidden sm:block">
                  ResourceRadar Coordinator
                </p>
              </div>
            </div>
            {activeView === "signals" && (
              <div className="hidden md:flex flex-1 max-w-xs ml-4">
                <div className="relative w-full">
                  <Search size={13} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" />
                  <input
                    type="text"
                    placeholder="Search signals…"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full bg-white/5 border border-white/10 rounded-xl py-2 pl-9 pr-3 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-blue-500/40 transition-all"
                  />
                </div>
              </div>
            )}
          </div>
          <div className="flex items-center gap-3 shrink-0">
            <span className="hidden sm:flex text-[10px] font-black text-emerald-400 bg-emerald-400/10 px-2.5 py-1 rounded-full border border-emerald-400/20 items-center gap-1.5">
              <span className="w-1.5 h-1.5 bg-emerald-400 rounded-full animate-pulse" />
              LIVE
            </span>
            {(activeView === "signals" || activeView === "map") && (
              <button
                onClick={() => setShowAI(!showAI)}
                className={`flex items-center gap-2 px-3.5 py-2 rounded-xl text-xs font-bold transition-all ${
                  showAI ? "bg-blue-600 text-white shadow-lg shadow-blue-600/40" : "bg-white/5 text-slate-300 border border-white/10 hover:bg-white/10"
                }`}
              >
                <Brain size={14} className={showAI ? "animate-pulse" : ""} />
                <span className="hidden sm:inline">AI ANALYSIS</span>
              </button>
            )}
          </div>
        </header>

        {/* Main content */}
        <main ref={contentRef} className="flex-1 flex flex-col overflow-hidden min-h-0">
          {(activeView === "signals" || activeView === "map") && (
            <div className="stats-animate shrink-0">
              <StatsBar stats={stats} />
            </div>
          )}

          <div className="flex-1 flex overflow-hidden min-h-0">

            {/* Signals view */}
            {activeView === "signals" && (
              <div className="flex-1 flex overflow-hidden p-4 pt-2 gap-4">
                <div className="flex-1 relative rounded-3xl overflow-hidden border border-white/10 bg-slate-900/40 shadow-2xl">
                  <MapComponent
                    signals={filteredSignals}
                    selectedSignal={selectedSignal}
                    onSignalSelect={(s) => { setSelectedSignal(s); setShowAI(true); }}
                  />
                </div>
                <div className="flex gap-4 h-full shrink-0">
                  <div className="w-72 h-full overflow-hidden">
                    <SignalList
                      signals={filteredSignals}
                      selected={selectedSignal}
                      onSelect={(s) => { setSelectedSignal(s); setShowAI(true); }}
                    />
                  </div>
                  <div className={`h-full transition-all duration-500 overflow-hidden ${showAI ? "w-[380px] opacity-100" : "w-0 opacity-0"}`}>
                    {showAI && (
                      <div className="w-[380px] h-full">
                        <AISidebar signal={selectedSignal} onClose={() => setShowAI(false)} />
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Map full view */}
            {activeView === "map" && (
              <div className="flex-1 flex overflow-hidden p-4 pt-2 gap-4">
                <div className="flex-1 relative rounded-3xl overflow-hidden border border-white/10 bg-slate-900/40 shadow-2xl">
                  <MapComponent
                    signals={filteredSignals}
                    selectedSignal={selectedSignal}
                    onSignalSelect={(s) => { setSelectedSignal(s); setShowAI(true); }}
                  />
                </div>
                {showAI && (
                  <div className="w-[380px] h-full">
                    <AISidebar signal={selectedSignal} onClose={() => setShowAI(false)} />
                  </div>
                )}
              </div>
            )}

            {/* Other views */}
            {(activeView === "volunteers" || activeView === "analytics" || activeView === "triage" || activeView === "settings") && (
              <PlaceholderView view={activeView} />
            )}

          </div>
        </main>
      </div>
    </div>
  );
}
