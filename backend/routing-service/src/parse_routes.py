from typing import List, Dict, Any, Tuple


def parse_optimization_response(
    api_response: Dict[str, Any],
    original_signals: List[Dict[str, Any]],
) -> Tuple[List[Dict[str, Any]], List[str]]:
    """
    Parse the Routes response into structured route data.
    Handles both Optimization API and adapted Routes API v2 formats.
    """
    routes = []
    served_signal_ids = set()

    # Map signals by ID for quick lookup if index is missing
    signal_map = {s.get("signal_id", ""): s for s in original_signals}

    api_routes = api_response.get("routes", [])
    for route_data in api_routes:
        vehicle_label = route_data.get("vehicleLabel", "unknown")
        visits = route_data.get("visits", [])
        
        # In v2 adaptation, we might have metrics directly
        metrics = route_data.get("metrics", {})
        total_distance_m = metrics.get("totalDistanceMeters", 0)
        total_duration_s = _parse_seconds(metrics.get("duration", "0s"))

        stops = []
        for visit in visits:
            signal = None
            
            # Try by index first (Optimization API style)
            if "shipmentIndex" in visit:
                idx = visit["shipmentIndex"]
                if idx < len(original_signals):
                    signal = original_signals[idx]
            
            # Try by label (Adapted v2 style)
            elif "shipmentLabel" in visit:
                label = visit["shipmentLabel"]
                signal = signal_map.get(label)

            if signal:
                signal_id = signal.get("signal_id", "")
                served_signal_ids.add(signal_id)

                location = signal.get("location", {})
                stops.append({
                    "signal_id": signal_id,
                    "ward_id": signal.get("ward_id", ""),
                    "need_type": signal.get("need_type", ""),
                    "lat": location.get("latitude", 0),
                    "lng": location.get("longitude", 0),
                    "eta_minutes": _parse_duration_to_minutes(
                        visit.get("startTime", "")
                    ),
                })

        # Sum up transition distances if metrics weren't provided (Legacy Optimization API)
        if not total_distance_m:
            transitions = route_data.get("transitions", [])
            for transition in transitions:
                total_distance_m += transition.get("travelDistanceMeters", 0)
                total_duration_s += _parse_seconds(transition.get("travelDuration", "0s"))

        if stops:
            routes.append({
                "vehicle_id": vehicle_label,
                "driver_name": vehicle_label,
                "stops": stops,
                "total_distance_km": round(total_distance_m / 1000, 2),
                "total_duration_minutes": total_duration_s // 60,
            })

    # Determine unserved signals
    all_signal_ids = {s.get("signal_id", "") for s in original_signals}
    unserved = list(all_signal_ids - served_signal_ids)

    return routes, unserved


def _parse_duration_to_minutes(time_str: str) -> int:
    """Parse an ISO time string to estimate ETA in minutes from now."""
    if not time_str: return 0
    try:
        from datetime import datetime, timezone
        dt = datetime.fromisoformat(time_str.replace("Z", "+00:00"))
        now = datetime.now(timezone.utc)
        delta = dt - now
        return max(0, int(delta.total_seconds() / 60))
    except (ValueError, TypeError):
        return 0


def _parse_seconds(duration_str: Any) -> int:
    """Parse a duration string like '300s' or integer seconds."""
    if isinstance(duration_str, int):
        return duration_str
    if not duration_str:
        return 0
    try:
        return int(str(duration_str).rstrip("s"))
    except (ValueError, TypeError):
        return 0
