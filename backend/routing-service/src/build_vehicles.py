from typing import List, Dict, Any


def build_vehicles_from_fleet(
    fleet: List[Dict[str, Any]],
    depot_lat: float,
    depot_lng: float,
    max_vehicles: int = 10,
) -> List[Dict[str, Any]]:
    """
    Convert NGO fleet data into Routes Optimization API 'vehicles'.
    Each vehicle starts and ends at the depot location.
    """
    vehicles = []
    for i, vehicle_data in enumerate(fleet[:max_vehicles]):
        vehicle = {
            "startLocation": {
                "latitude": depot_lat,
                "longitude": depot_lng,
            },
            "endLocation": {
                "latitude": depot_lat,
                "longitude": depot_lng,
            },
            "loadLimits": {
                "weight": {
                    "maxLoad": str(vehicle_data.get("capacity", 50)),
                },
            },
            "costPerKilometer": vehicle_data.get("cost_per_km", 10),
            "costPerHour": vehicle_data.get("cost_per_hour", 50),
            "travelDurationLimit": {
                "maxDuration": f"{vehicle_data.get('max_hours', 8) * 3600}s",
            },
            "label": vehicle_data.get("vehicle_id", f"vehicle_{i}"),
        }
        vehicles.append(vehicle)

    return vehicles
