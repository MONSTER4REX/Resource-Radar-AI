"use client";

import { useEffect, useRef } from "react";
import {
  MapPin,
  Radio,
  Users,
  BarChart3,
  Settings,
  Shield,
  LogOut,
  Menu,
  X,
} from "lucide-react";
import { useAuth } from "./auth/AuthContext";
import gsap from "gsap";

export type ActiveView = "signals" | "map" | "volunteers" | "analytics" | "triage" | "settings";

interface SidebarProps {
  open: boolean;
  onToggle: () => void;
  activeView: ActiveView;
  onViewChange: (view: ActiveView) => void;
}

const navItems: { icon: React.ElementType; label: string; view: ActiveView }[] = [
  { icon: Radio,    label: "Live Signals", view: "signals"    },
  { icon: MapPin,   label: "Map View",     view: "map"        },
  { icon: Users,    label: "Volunteers",   view: "volunteers" },
  { icon: BarChart3,label: "Analytics",    view: "analytics"  },
  { icon: Shield,   label: "Triage Queue", view: "triage"     },
  { icon: Settings, label: "Settings",     view: "settings"   },
];

export default function Sidebar({ open, onToggle, activeView, onViewChange }: SidebarProps) {
  const { user, logout } = useAuth();
  const sidebarRef = useRef<HTMLElement>(null);

  useEffect(() => {
    if (open) {
      gsap.from(".nav-item", {
        x: -20,
        opacity: 0,
        stagger: 0.05,
        duration: 0.5,
        ease: "power2.out",
        delay: 0.1,
        clearProps: "all",
      });
    }
  }, [open]);

  return (
    <aside
      ref={sidebarRef}
      className={`
        border-r border-white/5 flex flex-col shrink-0 h-full min-h-0
        bg-slate-950/90 backdrop-blur-2xl
        transition-all duration-300 ease-in-out
        lg:relative fixed inset-y-0 left-0 z-40
        ${open ? "w-64" : "w-0 lg:w-[72px] overflow-hidden"}
      `}
    >
      {/* Logo & Toggle */}
      <div className="h-20 flex items-center border-b border-white/5 shrink-0 px-4 gap-3">
        <div className="w-9 h-9 shrink-0 rounded-xl bg-gradient-to-br from-blue-500 to-violet-600 flex items-center justify-center shadow-lg shadow-blue-500/25">
          <Radio size={18} className="text-white" />
        </div>

        {open && (
          <div className="min-w-0 flex-1">
            <p className="text-sm font-bold tracking-tight text-white truncate">ResourceRadar</p>
            <p className="text-[9px] text-slate-500 uppercase tracking-widest font-bold">Tactical</p>
          </div>
        )}

        <button
          onClick={onToggle}
          className="ml-auto p-1.5 rounded-lg hover:bg-white/5 text-slate-500 hover:text-white transition-colors shrink-0"
          aria-label="Toggle sidebar"
        >
          {open ? <X size={16} /> : <Menu size={16} />}
        </button>
      </div>

      {/* Nav Items */}
      <nav className="flex-1 py-4 px-2 space-y-1 overflow-y-auto overflow-x-hidden">
        {navItems.map((item) => {
          const isActive = activeView === item.view;
          return (
            <button
              key={item.view}
              onClick={() => onViewChange(item.view)}
              title={!open ? item.label : undefined}
              className={`nav-item w-full flex items-center gap-3 px-3 py-3 rounded-xl text-sm font-semibold transition-all duration-200 group relative ${
                isActive
                  ? "bg-blue-600/90 text-white shadow-[0_0_20px_rgba(37,99,235,0.3)] border border-blue-400/20"
                  : "text-slate-400 hover:text-white hover:bg-white/5 border border-transparent"
              }`}
            >
              <item.icon
                size={18}
                className={`shrink-0 ${
                  isActive ? "text-white" : "text-slate-500 group-hover:text-blue-400 transition-colors"
                }`}
              />
              {open && (
                <span className="truncate text-left">{item.label}</span>
              )}
              {isActive && !open && (
                <div className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-blue-400 rounded-r-full" />
              )}
            </button>
          );
        })}
      </nav>

      {/* Bottom section */}
      <div className={`border-t border-white/5 p-3 shrink-0 ${!open && "flex flex-col items-center"}`}>
        {/* AI status */}
        {open ? (
          <div className="mb-3 p-3 rounded-xl bg-blue-600/8 border border-blue-500/20">
            <p className="text-[9px] text-blue-400 uppercase tracking-widest font-black mb-1.5">Gemini AI</p>
            <div className="h-1 w-full bg-slate-800 rounded-full overflow-hidden">
              <div className="h-full bg-blue-500 w-3/4 rounded-full" />
            </div>
          </div>
        ) : (
          <div className="w-9 h-9 mb-3 rounded-xl bg-blue-600/10 border border-blue-500/20 flex items-center justify-center" title="Gemini AI Active">
            <div className="w-2 h-2 bg-blue-400 rounded-full animate-pulse" />
          </div>
        )}

        {/* User */}
        {user && (
          <div className={`flex items-center gap-2.5 mb-2 ${!open && "justify-center"}`}>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={user.photoURL || `https://ui-avatars.com/api/?name=${user.displayName || "User"}&background=1e293b&color=94a3b8&bold=true`}
              alt=""
              className="w-8 h-8 rounded-full border border-white/10 shrink-0"
            />
            {open && (
              <p className="text-[10px] font-black text-white truncate uppercase">
                {user.displayName || user.email}
              </p>
            )}
          </div>
        )}

        {/* Sign out */}
        <button
          onClick={logout}
          title={!open ? "Sign Out" : undefined}
          className={`flex items-center gap-2 px-2 py-2 rounded-lg text-[9px] font-black uppercase tracking-widest text-slate-500 hover:text-red-400 hover:bg-red-500/10 transition-all ${!open ? "justify-center w-full" : "w-full"}`}
        >
          <LogOut size={14} />
          {open && <span>Sign Out</span>}
        </button>
      </div>
    </aside>
  );
}
