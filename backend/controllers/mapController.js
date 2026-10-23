const axios = require('axios');
const { sendSuccess, sendError } = require('../utils/response');

// Proxy to OpenRouteService — keeps API key secure in backend .env
const getRoute = async (req, res) => {
  try {
    const { startLat, startLng, endLat, endLng } = req.query;

    if (!startLat || !startLng || !endLat || !endLng) {
      return sendError(res, 'startLat, startLng, endLat, endLng are required.', 400);
    }

    const apiKey = process.env.ORS_API_KEY;
    if (!apiKey) {
      return sendError(res, 'ORS_API_KEY is not configured on the server.', 500);
    }

    const orsRes = await axios.post(
      'https://api.openrouteservice.org/v2/directions/driving-car/geojson',
      {
        coordinates: [
          [parseFloat(startLng), parseFloat(startLat)],
          [parseFloat(endLng), parseFloat(endLat)],
        ],
      },
      {
        headers: {
          Authorization: apiKey,
          'Content-Type': 'application/json',
        },
        timeout: 10000,
      }
    );

    const feature = orsRes.data.features[0];
    const summary = feature.properties.summary;

    // Convert [lng, lat] GeoJSON coords → [{lat, lng}] for Flutter
    const routePoints = feature.geometry.coordinates.map(([lng, lat]) => ({ lat, lng }));

    return sendSuccess(res, 'Route fetched successfully.', {
      route: routePoints,
      distance_km: (summary.distance / 1000).toFixed(1),
      duration_min: Math.ceil(summary.duration / 60),
    });
  } catch (error) {
    const msg = error.response?.data?.error?.message || error.message;
    return sendError(res, `Route fetch failed: ${msg}`, 500);
  }
};

module.exports = { getRoute };
