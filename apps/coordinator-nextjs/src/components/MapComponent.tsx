"use client";

import {
  APIProvider,
  Map,
  AdvancedMarker,
  Pin,
  useAdvancedMarkerRef,
} from "@vis.gl/react-google-maps";
import { useState } from "react";
import { NeedSignal } from "../lib/types";

interface MapComponentProps {
  signals: NeedSignal[];
  onSignalSelect: (signal: NeedSignal) => void;
  selectedSignal: NeedSignal | null;
}

const API_KEY = process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY || "";
const MAP_ID = process.env.NEXT_PUBLIC_GOOGLE_MAPS_ID || "DEMO_MAP_ID";

export default function MapComponent({ signals, onSignalSelect, selectedSignal }: MapComponentProps) {
  // Default center (New Delhi for now, or use first signal)
  const defaultCenter = { lat: 28.6139, lng: 77.2090 };
  const center = signals.length > 0 
    ? { lat: signals[0].location.latitude, lng: signals[0].location.longitude }
    : defaultCenter;

  return (
    <div className="w-full h-full relative">
      <APIProvider apiKey={API_KEY}>
        <Map
          defaultCenter={center}
          defaultZoom={13}
          mapId={MAP_ID}
          gestureHandling={"greedy"}
          disableDefaultUI={true}
          style={{ width: "100%", height: "100%" }}
          colorScheme={"DARK"}
        >
          {signals.map((signal) => (
            <SignalMarker
              key={signal.signal_id}
              signal={signal}
              onClick={() => onSignalSelect(signal)}
              isSelected={selectedSignal?.signal_id === signal.signal_id}
            />
          ))}
        </Map>
      </APIProvider>
      
      {!API_KEY && (
        <div className="absolute inset-0 bg-slate-900/80 flex items-center justify-center backdrop-blur-sm z-50">
          <div className="max-w-md text-center p-8 bg-slate-800 rounded-3xl border border-white/10 shadow-2xl">
            <h3 className="text-xl font-bold text-white mb-2">Maps API Key Required</h3>
            <p className="text-slate-400 text-sm mb-6">
              Please add <code className="text-blue-400 bg-blue-400/10 px-1.5 py-0.5 rounded">NEXT_PUBLIC_GOOGLE_MAPS_API_KEY</code> to your .env file to enable the interactive mission map.
            </p>
            <div className="w-full h-32 bg-slate-700/50 rounded-2xl animate-pulse flex items-center justify-center">
              <span className="text-slate-500 text-xs">Interactive Map Preview</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function SignalMarker({ signal, onClick, isSelected }: { 
  signal: NeedSignal, 
  onClick: () => void,
  isSelected: boolean 
}) {
  const [markerRef] = useAdvancedMarkerRef();

  const getUrgencyColor = (tier?: string) => {
    switch (tier) {
      case "critical": return "#ef4444";
      case "high": return "#f97316";
      case "medium": return "#eab308";
      case "low": return "#10b981";
      default: return "#64748b";
    }
  };

  return (
    <AdvancedMarker
      ref={markerRef}
      position={{ lat: signal.location.latitude, lng: signal.location.longitude }}
      onClick={onClick}
      title={signal.need_type}
    >
      <div className={`relative transition-transform duration-300 ${isSelected ? 'scale-125 z-10' : 'scale-100'}`}>
        <Pin
          background={getUrgencyColor(signal.urgency_tier)}
          glyphColor={"#fff"}
          borderColor={"#fff"}
        />
        {isSelected && (
          <div className="absolute -inset-2 bg-blue-500/20 rounded-full animate-ping pointer-events-none" />
        )}
      </div>
    </AdvancedMarker>
  );
}
