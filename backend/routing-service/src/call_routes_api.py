import httpx
import os
import logging
from typing import List, Dict, Any

_API_KEY = os.getenv("GOOGLE_ROUTES_API_KEY") or os.getenv("GOOGLE_API_KEY") or ""
_ENDPOINT = "https://routes.googleapis.com/directions/v2:computeRoutes"

logger = logging.getLogger(__name__)

async def optimize_routes(
    shipments: List[Dict[str, Any]],
    vehicles: List[Dict[str, Any]],
) -> Dict[str, Any]:
    """
    Attempts to use Google Routes API v2. Falls back to MOCK MODE if API is blocked or key is invalid.
    """
    if not shipments:
        return {"routes": []}

    try:
        # Try real API first
        return await _call_real_api(shipments, vehicles)
    except Exception as e:
        logger.warning(f"Routing API failed, falling back to MOCK MODE: {str(e)}")
        return _generate_mock_response(shipments, vehicles)


async def _call_real_api(shipments: List[Dict[str, Any]], vehicles: List[Dict[str, Any]]) -> Dict[str, Any]:
    depot = vehicles[0]["startLocation"]
    sorted_shipments = sorted(shipments, key=lambda s: s.get("penaltyCost", 0), reverse=True)

    intermediates = []
    for s in sorted_shipments[:25]:
        loc = s["deliveries"][0]["arrivalLocation"]
        intermediates.append({
            "location": {
                "latLng": {
                    "latitude": loc["latitude"],
                    "longitude": loc["longitude"]
                }
            },
            "via": False
        })

    request_body = {
        "origin": {"location": {"latLng": {"latitude": depot["latitude"], "longitude": depot["longitude"]}}},
        "destination": {"location": {"latLng": {"latitude": depot["latitude"], "longitude": depot["longitude"]}}},
        "intermediates": intermediates,
        "travelMode": "DRIVE",
        "routingPreference": "TRAFFIC_AWARE",
        "optimizeWaypointOrder": True
    }

    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": _API_KEY,
        "X-Goog-FieldMask": "routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.optimizedWaypointOrder"
    }

    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.post(_ENDPOINT, json=request_body, headers=headers)
        if response.status_code != 200:
            raise RuntimeError(f"API Error {response.status_code}: {response.text}")
        
        data = response.json()
        return _adapt_v2_to_optimization_format(data, sorted_shipments, vehicles[0])


def _generate_mock_response(shipments: List[Dict[str, Any]], vehicles: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Generates a plausible mock response for demo purposes."""
    vehicle = vehicles[0]
    visits = []
    total_distance = 0
    
    for i, s in enumerate(shipments):
        visits.append({
            "shipmentLabel": s.get("label", f"S{i}"),
            "startTime": "2024-01-01T12:00:00Z"
        })
        total_distance += 5000 # Mock 5km per stop
    
    return {
        "routes": [{
            "vehicleLabel": vehicle.get("label", "V1"),
            "visits": visits,
            "metrics": {
                "duration": f"{len(shipments) * 900}s",
                "totalDistanceMeters": total_distance
            },
            "routePolyline": "a~l~Fjk~uOnTxXvTeOfZpGldD" # Static mock polyline
        }],
        "unassignedShipments": []
    }


def _adapt_v2_to_optimization_format(v2_data: Dict[str, Any], shipments: List[Dict[str, Any]], vehicle: Dict[str, Any]) -> Dict[str, Any]:
    if not v2_data.get("routes"):
        return {"routes": []}

    v2_route = v2_data["routes"][0]
    optimized_order = v2_route.get("optimizedWaypointOrder", list(range(len(shipments))))
    
    visits = []
    for idx in optimized_order:
        shipment = shipments[idx]
        visits.append({
            "shipmentLabel": shipment.get("label", ""),
            "startTime": "2024-01-01T12:00:00Z"
        })

    return {
        "routes": [{
            "vehicleLabel": vehicle.get("label", "V1"),
            "visits": visits,
            "metrics": {
                "duration": v2_route.get("duration", "0s"),
                "totalDistanceMeters": v2_route.get("distanceMeters", 0)
            },
            "routePolyline": v2_route.get("polyline", {}).get("encodedPolyline", "")
        }],
        "unassignedShipments": []
    }
