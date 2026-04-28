/**
 * API Client for ResourceRadar Backend Services
 */

const MATCHING_SERVICE_URL = process.env.NEXT_PUBLIC_MATCHING_SERVICE_URL || "http://localhost:8001";
const ROUTING_SERVICE_URL = process.env.NEXT_PUBLIC_ROUTING_SERVICE_URL || "http://localhost:8002";

export interface VolunteerMatch {
  volunteer_id: string;
  display_name: string;
  skills: string[];
  distance_km: number;
  match_score: number;
}

export interface MatchResponse {
  signal_id: string;
  matches: VolunteerMatch[];
  total_candidates: number;
}

export interface RouteStop {
  signal_id: string;
  ward_id: string;
  need_type: string;
  lat: number;
  lng: number;
  eta_minutes: number;
}

export interface VehicleRoute {
  vehicle_id: string;
  driver_name: string;
  stops: RouteStop[];
  total_distance_km: number;
  total_duration_minutes: number;
}

export interface OptimizeResponse {
  ngo_id: string;
  routes: VehicleRoute[];
  unserved_signals: string[];
}

export const api = {
  /**
   * Find the best volunteer matches for a specific signal
   */
  async getMatches(signalId: string): Promise<MatchResponse> {
    const response = await fetch(`${MATCHING_SERVICE_URL}/match`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ signal_id: signalId }),
    });

    if (!response.ok) {
      throw new Error(`Matching service failed: ${response.statusText}`);
    }

    return response.json();
  },

  /**
   * Solve the Capacitated Vehicle Routing Problem (CVRP) for an NGO's fleet
   */
  async optimizeRoutes(ngoId: string, depot: { lat: number; lng: number }): Promise<OptimizeResponse> {
    const response = await fetch(`${ROUTING_SERVICE_URL}/optimize`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        ngo_id: ngoId,
        depot_lat: depot.lat,
        depot_lng: depot.lng,
      }),
    });

    if (!response.ok) {
      throw new Error(`Routing service failed: ${response.statusText}`);
    }

    return response.json();
  }
};
