"use client";

import { useEffect, useRef, useState } from "react";
import { NeedSignal } from "../lib/types";
import { Navigation } from "lucide-react";

interface MapComponentProps {
  signals: NeedSignal[];
  onSignalSelect: (signal: NeedSignal) => void;
  selectedSignal: NeedSignal | null;
}

const TIER_COLORS: Record<string, string> = {
  critical: "#ef4444",
  high: "#f97316",
  medium: "#eab308",
  low: "#10b981",
};

export default function MapComponent({ signals, onSignalSelect, selectedSignal }: MapComponentProps) {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<import("leaflet").Map | null>(null);
  const markersRef = useRef<import("leaflet").CircleMarker[]>([]);
  const [mapReady, setMapReady] = useState(false);
  const [mapType, setMapType] = useState<"street" | "satellite">("street");

  const defaultCenter: [number, number] = signals.length > 0
    ? [signals[0].location.latitude, signals[0].location.longitude]
    : [28.6139, 77.209];

  // --- Initialise Leaflet once (client only) ---
  useEffect(() => {
    if (typeof window === "undefined" || mapRef.current) return;

    let cancelled = false;

    import("leaflet").then((L) => {
      if (cancelled || !mapContainerRef.current) return;

      // Fix default icon paths for Next.js / webpack
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      delete (L.Icon.Default.prototype as any)._getIconUrl;
      L.Icon.Default.mergeOptions({
        iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
        iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
        shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
      });

      const map = L.map(mapContainerRef.current!, {
        center: defaultCenter,
        zoom: 13,
        zoomControl: false,
      });

      L.control.zoom({ position: "bottomright" }).addTo(map);

      // Street tile layer
      L.tileLayer(
        "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
        {
          attribution: "© OpenStreetMap contributors © CARTO",
          subdomains: "abcd",
          maxZoom: 20,
        }
      ).addTo(map);

      mapRef.current = map;
      setMapReady(true);
    });

    return () => {
      cancelled = true;
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // --- Sync markers when signals change ---
  useEffect(() => {
    if (!mapReady || !mapRef.current) return;

    import("leaflet").then((L) => {
      const map = mapRef.current!;

      // Clear old markers
      markersRef.current.forEach((m) => m.remove());
      markersRef.current = [];

      signals.forEach((signal) => {
        const color = TIER_COLORS[signal.urgency_tier ?? ""] ?? "#64748b";
        const isSelected = selectedSignal?.signal_id === signal.signal_id;

        const marker = L.circleMarker(
          [signal.location.latitude, signal.location.longitude],
          {
            radius: isSelected ? 18 : 10,
            fillColor: color,
            color: "#ffffff",
            weight: 2,
            opacity: 1,
            fillOpacity: 0.85,
          }
        )
          .addTo(map)
          .bindTooltip(
            `<div style="background:#0f172a;border:1px solid rgba(255,255,255,0.1);padding:8px 12px;border-radius:8px;color:white;font-size:11px;font-weight:bold;text-transform:uppercase;letter-spacing:0.1em">
              ${signal.need_type} · Ward ${signal.ward_id}<br/>
              <span style="color:${color}">${(signal.urgency_tier ?? 'unknown').toUpperCase()}</span> · ${signal.people_count} people
            </div>`,
            { className: "leaflet-tooltip-custom", opacity: 1, permanent: isSelected }
          )
          .on("click", () => onSignalSelect(signal));

        markersRef.current.push(marker);
      });
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [signals, selectedSignal, mapReady]);

  // --- Pan to selected ---
  useEffect(() => {
    if (!mapRef.current || !selectedSignal) return;
    mapRef.current.flyTo(
      [selectedSignal.location.latitude, selectedSignal.location.longitude],
      15,
      { animate: true, duration: 0.8 }
    );
  }, [selectedSignal]);

  // --- Center all ---
  const centerAll = () => {
    if (!mapRef.current || signals.length === 0) return;
    mapRef.current.flyTo(
      [signals[0].location.latitude, signals[0].location.longitude],
      13,
      { animate: true, duration: 0.8 }
    );
  };

  return (
    <div className="w-full h-full relative">
      {/* Overlay top-left */}
      <div className="absolute top-4 left-4 z-[500]">
        <div className="px-3 py-1.5 bg-slate-900/90 backdrop-blur-md border border-white/10 rounded-lg">
          <p className="text-[9px] font-black text-sky-400 uppercase tracking-[0.2em]">
            Live Tactical Feed
          </p>
        </div>
      </div>

      {/* Overlay top-right controls */}
      <div className="absolute top-4 right-4 z-[500] flex gap-2">
        <button
          onClick={centerAll}
          className="px-3 py-1.5 bg-slate-900/90 backdrop-blur-md border border-white/10 rounded-lg text-[9px] font-black text-blue-400 uppercase tracking-widest hover:bg-blue-400/10 transition-all flex items-center gap-2"
        >
          <Navigation size={12} />
          Center
        </button>
      </div>

      {/* Legend */}
      <div className="absolute bottom-6 left-4 z-[500] flex flex-col gap-1.5 bg-slate-900/80 backdrop-blur-md border border-white/10 rounded-xl p-3">
        {Object.entries(TIER_COLORS).map(([tier, color]) => (
          <div key={tier} className="flex items-center gap-2">
            <div className="w-2.5 h-2.5 rounded-full border border-white/30" style={{ backgroundColor: color }} />
            <span className="text-[9px] font-black uppercase tracking-widest text-slate-400">{tier}</span>
          </div>
        ))}
      </div>

      {/* Map container */}
      <div ref={mapContainerRef} className="w-full h-full" style={{ zIndex: 10 }} />

      {/* Loading state */}
      {!mapReady && (
        <div className="absolute inset-0 flex items-center justify-center bg-slate-950/80 z-[600]">
          <div className="flex flex-col items-center gap-3">
            <div className="w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
            <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Initialising Map…</p>
          </div>
        </div>
      )}
    </div>
  );
}
