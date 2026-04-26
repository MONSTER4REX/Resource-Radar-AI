import math
from typing import List, Dict, Any


def filter_by_distance(
    candidates: List[Dict[str, Any]],
    signal_lat: float,
    signal_lng: float,
    max_km: float = 15.0,
) -> List[Dict[str, Any]]:
    """
    Filter volunteer candidates by geographic distance from the signal location.
    Uses the Haversine formula for accurate earth-surface distance calculation.
    """
    filtered = []
    for candidate in candidates:
        vol_lat = candidate.get("latitude", 0)
        vol_lng = candidate.get("longitude", 0)

        distance = _haversine(signal_lat, signal_lng, vol_lat, vol_lng)

        if distance <= max_km:
            candidate["distance_km"] = round(distance, 2)
            filtered.append(candidate)

    return filtered


def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calculate the great-circle distance between two points on Earth
    using the Haversine formula.
    Returns distance in kilometers.
    """
    R = 6371.0  # Earth radius in km

    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)

    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return R * c
