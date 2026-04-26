from dotenv import load_dotenv
import os

# Try current dir, then parent dir
if not load_dotenv():
    load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from build_shipments import build_shipments_from_signals
from build_vehicles import build_vehicles_from_fleet
from call_routes_api import optimize_routes
from parse_routes import parse_optimization_response
from firestore_sync import get_active_signals, get_fleet, save_routes

app = FastAPI(title="ResourceRadar Routing Service")


class RouteRequest(BaseModel):
    ngo_id: str
    max_vehicles: int = 10
    depot_lat: float
    depot_lng: float


class RouteStop(BaseModel):
    signal_id: str
    ward_id: str
    need_type: str
    lat: float
    lng: float
    eta_minutes: int


class VehicleRoute(BaseModel):
    vehicle_id: str
    driver_name: str
    stops: List[RouteStop]
    total_distance_km: float
    total_duration_minutes: int


class RouteResponse(BaseModel):
    ngo_id: str
    routes: List[VehicleRoute]
    unserved_signals: List[str]


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "routing"}


@app.post("/optimize", response_model=RouteResponse)
async def optimize_fleet_routes(request: RouteRequest):
    """
    Solve the Capacitated Vehicle Routing Problem (CVRP) for an NGO's fleet:
    1. Fetch active/assigned signals from Firestore
    2. Fetch NGO fleet (vehicles + capacity)
    3. Build shipments (deliveries) from signals
    4. Build vehicles from fleet data
    5. Call Google Routes Optimization API
    6. Parse routes and save to Firestore
    """
    # 1. Fetch active signals
    signals = await get_active_signals(request.ngo_id)
    if not signals:
        return RouteResponse(ngo_id=request.ngo_id, routes=[], unserved_signals=[])

    # 2. Fetch fleet
    fleet = await get_fleet(request.ngo_id)
    if not fleet:
        raise HTTPException(status_code=404, detail="No vehicles found for this NGO")

    # 3. Build shipments
    shipments = build_shipments_from_signals(signals)

    # 4. Build vehicles
    vehicles = build_vehicles_from_fleet(
        fleet=fleet,
        depot_lat=request.depot_lat,
        depot_lng=request.depot_lng,
        max_vehicles=request.max_vehicles,
    )

    # 5. Optimize via Google Routes API
    api_response = await optimize_routes(
        shipments=shipments,
        vehicles=vehicles,
    )

    # 6. Parse and save
    routes, unserved = parse_optimization_response(api_response, signals)
    await save_routes(request.ngo_id, routes)

    return RouteResponse(
        ngo_id=request.ngo_id,
        routes=[VehicleRoute(**r) for r in routes],
        unserved_signals=unserved,
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", 8002)))
