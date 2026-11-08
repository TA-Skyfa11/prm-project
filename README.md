# Aspen House Finder (House Finding System)
## PRM393 - Mobile Programming Course Project

An enterprise-grade Flutter mobile application and cloud edge architecture designed for finding and renting rooms/apartments for students and workers in Vietnam.

---

## 🏛 Architecture & Tech Stack

```
                          ┌───────────────────────────┐
                          │    Flutter Mobile App     │
                          │     (Android / iOS)       │
                          └──────┬─────────────┬──────┘
                                 │             │
              Firebase Auth,     │             │  Direct Uploads & Cached Queries
              Firestore, FCM     │             │  (Presigned URL / CDN Images)
                                 ▼             ▼
                    ┌─────────────────┐     ┌───────────────────────────┐
                    │ Firebase        │     │ Cloudflare                │
                    │ - Auth (JWT)    │     │ - Workers (Edge API)      │
                    │ - Firestore DB  │     │ - R2 (Media / Photos)     │
                    │ - FCM (Push)    │     │ - CDN (Image Resizing)    │
                    └─────────────────┘     └───────────────────────────┘
```

1. **Flutter Mobile Application (`lib/`):**
   - Material Design 3 Aspen aesthetic (blue accent `#176CF5`, rounded modern cards, subtle elevation).
   - Real-time NoSQL synchronization via Cloud Firestore.
   - Built-in multi-persona **Role Switcher** (Finder, House Owner, Admin) for testing and grading without requiring 3 separate physical devices.
   - Offline-first architecture with instant fallback to local mock data.

2. **Cloudflare Edge Layer (`cloudflare/`):**
   - **Cloudflare Workers (`cloudflare/worker.js`):** Edge reverse proxy, CORS handling, GPS radius proximity calculations, and pre-signed upload URL generation.
   - **Cloudflare R2 Object Storage:** Zero-egress bandwidth storage for property photos and landlord KYC documents.
   - **Cloudflare CDN & Image Resizing:** Automatically compresses images to WebP format for 5x faster mobile loading.

3. **Firebase Services (`firestore.rules`, `firestore.seed.json`):**
   - **Firebase Authentication:** Email/password, Google OAuth, and phone OTP with custom claims (`role`: `finder`, `owner`, `admin`).
   - **Cloud Firestore:** Real-time database collections for `users`, `apartments`, `listings`, `appointments`, `chat_rooms`, `reviews`, `reports`.
   - **Firebase Cloud Messaging (FCM):** Push alerts for appointment approvals, new chat messages, and post moderation results.

---

## 📱 Core Features & User Workflows

### 1. House Finder (Người tìm trọ)
- **Smart Discovery:** Filter by district (Cầu Giấy, Ba Đình, Nam Từ Liêm, Đống Đa, Tây Hồ), category (Phòng trọ, Căn hộ mini, Nhà nguyên căn, Ở ghép), and price slider (1 tr - 15 tr/tháng).
- **Transparent Utility Costs:** Detailed breakdown of electricity (đ/kWh), water (đ/khối), and internet fees.
- **5-Stage Viewing Appointments:** Book a viewing by selecting date and time slots (`Pending` -> `Approved` -> `Completed` / `Cancelled`).
- **Real-Time Chat & Quick Call:** In-app messaging with preset question chips and 1-tap phone dialer.
- **Wishlist:** Save favorite rooms for instant offline access.

### 2. House Owner (Chủ trọ)
- **Host KYC & Verification:** Submit CCCD/CMND for platform verification.
- **Listing Lifecycle Control:** Post new rooms with photos and toggle room availability between **Còn phòng (Available)**, **Đã cho thuê (Rented)**, and **Tạm ẩn (Hidden)**.
- **Appointment Management:** Real-time inbox to **Chấp nhận (Approve)** or **Từ chối (Reject with reason)** tenant viewing requests.

### 3. Administrator (Quản trị viên)
- **Listing Moderation:** Pending posts queue to review photos and pricing transparency before approving for public search.
- **System Metrics & KPIs:** Overview of active users, listings, and violation reports.

---

## 📄 Documentation

The complete, revised, and standardized Software Requirement Specification is located at:
- **`docs/SRS_REVISED_SPECIFICATION.md`**

---

## 🚀 How to Run

### Run Flutter Mobile App
```powershell
# 1. Install dependencies
flutter pub get

# 2. Run analysis & test suite
flutter analyze
flutter test

# 3. Launch application (runs with local demo data out of the box)
flutter run

# 4. Optional: Run connected to live Firebase project
flutter run --dart-define=FIREBASE_ENABLED=true
```

### Run Cloudflare Worker Locally
```powershell
cd cloudflare
npx wrangler dev
```
