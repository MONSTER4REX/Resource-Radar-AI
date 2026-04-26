import { Client } from "@googlemaps/google-maps-services-js";
import dotenv from "dotenv";

dotenv.config();

const client = new Client({});

export async function geocodeWard(wardId: string, cityId: string): Promise<{ latitude: number, longitude: number } | null> {
    try {
        // Simple address construction: "Ward [X], [City], Haryana, India"
        // In a real scenario, we'd have a mapping of ward IDs to addresses or use the ward ID directly if indexed by Google.
        const wardNumber = wardId.split('-').pop();
        const address = `Ward ${wardNumber}, ${cityId.replace('_', ' ')}, India`;

        const response = await client.geocode({
            params: {
                address: address,
                key: process.env.GOOGLE_MAPS_API_KEY || "",
            },
        });

        if (response.data.results.length > 0) {
            const result = response.data.results[0];
            if (result && result.geometry && result.geometry.location) {
                const location = result.geometry.location;
                return {
                    latitude: location.lat,
                    longitude: location.lng,
                };
            }
        }
        return null;
    } catch (error) {
        console.error("Geocoding error:", error);
        return null;
    }
}
