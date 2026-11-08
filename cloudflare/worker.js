/**
 * Cloudflare Worker - PRM393 House Finding System Edge API
 * Deployment: *-prm-project.agrilog.workers.dev
 * R2 Storage: https://d83b40f9ba48c1a0952568b9620ee62f.r2.cloudflarestorage.com/prm-project
 * Firebase Project: prm-projects
 */

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const method = request.method;

    // CORS preflight handling
    if (method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
          "Access-Control-Max-Age": "86400",
        },
      });
    }

    const jsonHeaders = {
      "content-type": "application/json; charset=utf-8",
      "Access-Control-Allow-Origin": "*",
    };

    const r2Endpoint = env.R2_ENDPOINT || "https://d83b40f9ba48c1a0952568b9620ee62f.r2.cloudflarestorage.com/prm-project";

    try {
      // 1. Healthcheck & System Info
      if (url.pathname === "/api/health" && method === "GET") {
        return new Response(
          JSON.stringify({
            status: "healthy",
            service: "prm-project-edge-api",
            worker: "prm-project.agrilog.workers.dev",
            firebaseProject: env.FIREBASE_PROJECT_ID || "prm-projects",
            r2Bucket: env.R2_BUCKET_NAME || "prm-project",
            timestamp: new Date().toISOString(),
          }),
          { status: 200, headers: jsonHeaders }
        );
      }

      // 2. Media Upload - Cloudflare R2 Presigned Upload URL Generator
      if (url.pathname === "/api/media/presigned-url" && method === "POST") {
        const body = await request.json().catch(() => ({}));
        const fileName = body.fileName || `room_${Date.now()}.webp`;
        const folder = body.folder || "rooms";
        const fileKey = `${folder}/${Date.now()}_${fileName}`;

        // Direct upload target on Cloudflare R2
        const uploadUrl = `${r2Endpoint}/${fileKey}`;
        const publicUrl = `${r2Endpoint}/${fileKey}`;

        return new Response(
          JSON.stringify({
            success: true,
            data: {
              uploadUrl: uploadUrl,
              publicUrl: publicUrl,
              fileKey: fileKey,
              bucket: env.R2_BUCKET_NAME || "prm-project",
            },
          }),
          { status: 200, headers: jsonHeaders }
        );
      }

      // 3. Categories & Amenities Reference Data (Edge Cached)
      if (url.pathname === "/api/categories" && method === "GET") {
        const categories = [
          { id: "cat_room", name: "Phòng trọ", description: "Phòng trọ sinh viên, diện tích 15-25m2" },
          { id: "cat_mini_apartment", name: "Căn hộ mini", description: "Studio, chung cư mini khép kín full đồ" },
          { id: "cat_house", name: "Nhà nguyên căn", description: "Nhà riêng cho thuê, nhóm bạn sinh viên" },
          { id: "cat_homestay", name: "Ở ghép / Homestay", description: "Ký túc xá cao cấp hoặc phòng ở ghép" },
        ];
        return new Response(JSON.stringify({ success: true, data: categories }), {
          status: 200,
          headers: { ...jsonHeaders, "Cache-Control": "public, max-age=3600" },
        });
      }

      if (url.pathname === "/api/amenities" && method === "GET") {
        const amenities = [
          { id: "wifi", name: "Wi-Fi tốc độ cao", icon: "wifi" },
          { id: "air_conditioner", name: "Điều hòa 2 chiều", icon: "ac_unit" },
          { id: "water_heater", name: "Bình nóng lạnh", icon: "hot_tub" },
          { id: "refrigerator", name: "Tủ lạnh", icon: "kitchen" },
          { id: "washing_machine", name: "Máy giặt riêng/chung", icon: "local_laundry_service" },
          { id: "parking", name: "Chỗ để xe / Sạc xe điện", icon: "two_wheeler" },
          { id: "private_bathroom", name: "Vệ sinh khép kín", icon: "bathtub" },
          { id: "balcony", name: "Ban công thoáng mát", icon: "balcony" },
          { id: "security", name: "Khóa vân tay an toàn", icon: "security" },
        ];
        return new Response(JSON.stringify({ success: true, data: amenities }), {
          status: 200,
          headers: { ...jsonHeaders, "Cache-Control": "public, max-age=3600" },
        });
      }

      // 4. Proximity Search (GPS Radius)
      if (url.pathname === "/api/listings/nearby" && method === "GET") {
        const lat = parseFloat(url.searchParams.get("lat") || "21.0285");
        const lng = parseFloat(url.searchParams.get("lng") || "105.8542");
        const radiusKm = parseFloat(url.searchParams.get("radiusKm") || "5.0");

        return new Response(
          JSON.stringify({
            success: true,
            query: { center: { lat, lng }, radiusKm },
            source: "prm-project.agrilog.workers.dev",
          }),
          { status: 200, headers: jsonHeaders }
        );
      }

      // 5. Listings Query with Edge Filter & Cache
      if (url.pathname === "/api/listings" && method === "GET") {
        const district = url.searchParams.get("district") || "";
        const category = url.searchParams.get("category") || "";

        return new Response(
          JSON.stringify({
            success: true,
            filter: { district, category },
            source: "prm-project.agrilog.workers.dev",
          }),
          { status: 200, headers: { ...jsonHeaders, "Cache-Control": "public, max-age=60" } }
        );
      }

      return new Response(JSON.stringify({ error: "Endpoint not found" }), {
        status: 404,
        headers: jsonHeaders,
      });
    } catch (err) {
      return new Response(JSON.stringify({ error: "Internal Server Error", message: err.message }), {
        status: 500,
        headers: jsonHeaders,
      });
    }
  },
};
