"use client";

import Dashboard from "@/components/Dashboard";
import LandingPage from "@/components/auth/LandingPage";
import { useAuth } from "@/components/auth/AuthContext";
import { Loader2 } from "lucide-react";

export default function Home() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-blue-500 animate-spin" />
      </div>
    );
  }

  return user ? <Dashboard /> : <LandingPage />;
}
