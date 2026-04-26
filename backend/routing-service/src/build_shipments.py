from typing import List, Dict, Any


def build_shipments_from_signals(signals: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Convert NeedSignals into Routes Optimization API 'shipments'.
    Each signal becomes a delivery with a pickup at the depot and
    a delivery at the signal's location.
    """
    shipments = []
    for signal in signals:
        location = signal.get("location", {})
        lat = location.get("latitude", 0)
        lng = location.get("longitude", 0)

        # Demand weight based on people count and urgency
        urgency_multiplier = {
            "critical": 4,
            "high": 3,
            "medium": 2,
            "low": 1,
        }.get(signal.get("urgency_tier", "medium"), 2)

        people = signal.get("people_count", 1)
        load_demand = max(1, people // 10)  # Simplified load units

        shipment = {
            "deliveries": [{
                "arrivalLocation": {
                    "latitude": lat,
                    "longitude": lng,
                },
                "duration": f"{_estimate_service_time(signal)}s",
                "timeWindows": [],  # No hard time windows for humanitarian ops
            }],
            "loadDemands": {
                "weight": {"amount": str(load_demand)},
            },
            "penaltyCost": urgency_multiplier * 100,  # Higher penalty = higher priority
            "label": signal.get("signal_id", ""),
        }
        shipments.append(shipment)

    return shipments


def _estimate_service_time(signal: dict) -> int:
    """Estimate on-site service time in seconds based on need type and scale."""
    base_times = {
        "food": 600,       # 10 min distribution
        "water": 300,      # 5 min
        "medicine": 900,   # 15 min (requires verification)
        "shelter": 1200,   # 20 min
        "clothing": 600,   # 10 min
        "other": 600,
    }
    base = base_times.get(signal.get("need_type", "other"), 600)
    people = signal.get("people_count", 1)

    # Scale service time logarithmically with people count
    import math
    scale_factor = 1 + math.log10(max(1, people / 10))
    return int(base * scale_factor)
