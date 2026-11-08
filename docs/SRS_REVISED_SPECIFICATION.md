# House Finding System
## Software Requirement Specification (SRS) — Revised & Standardized
**Course Project:** PRM393 - Mobile Programming (FPT University)  
**System Architecture:** Flutter Mobile Client + Firebase (Auth, Firestore, FCM) + Cloudflare (Workers, R2, CDN)  
**Version:** 2.0 (Comprehensive Revision)  
**Date:** November 2026  

---

## I. Record of Changes

| Version | Date | Author / Role | Description of Changes |
| :--- | :--- | :--- | :--- |
| **1.0** | 11/2026 | Project Team | Initial draft submitted for course review (contained placeholder templates and incomplete flows). |
| **2.0** | 11/2026 | System Architect | - Removed all outdated LMS template placeholders in sections 3.2 and 3.3.<br>- Resolved payment flow contradiction (clarified deposit roadmap vs standard rental workflow).<br>- Restored missing `UC-07` (Role & Host KYC Management) and expanded from 30 to 36 Use Cases.<br>- Added missing House Owner Appointment Management flow and Add Apartment functionality.<br>- Re-architected data model from relational SQL to NoSQL Cloud Firestore + Cloudflare R2 object storage.<br>- Standardized 45+ RESTful / Cloudflare Edge API endpoints.<br>- Added geolocation proximity search (GPS radius), listing status toggles, and Quick Call. |

---

## II. Software Requirement Specification

### 1. Product Overview

The **House Finding System** is a mobile application developed with **Flutter** targeting Android and iOS devices, designed to solve the rental housing search challenge for university students and workers in Vietnam. It replaces fragmented, risky Facebook groups and street flyers with a verified, secure platform.

#### 1.1 Architectural Ecosystem (Firebase + Cloudflare)
To maximize performance, reduce costs (zero egress fees), and guarantee real-time updates:
* **Mobile Client:** Flutter (Material Design 3), supporting offline caching and responsive UI.
* **Authentication:** Firebase Authentication (Email/Password, Google Sign-In, Phone SMS OTP) with custom claims (`role`: `finder`, `owner`, `admin`).
* **Primary Database:** Google Cloud Firestore (NoSQL Document Store) for sub-second synchronization of listings, chats, and appointments.
* **Media & Storage:** Cloudflare R2 Object Storage for high-definition property photos and KYC documents with zero bandwidth egress cost.
* **Edge Proxy & API Gateway:** Cloudflare Workers running at 300+ edge locations for request validation, presigned R2 upload URLs, image resizing/compression (WebP), and listing search caching.
* **Push Notifications:** Firebase Cloud Messaging (FCM) for instant alerts regarding appointment status changes, new messages, and listing approvals.

#### 1.2 Connected Cloud Infrastructure & Credentials
* **Firebase Project:** `prm-projects` (Project Number: `213546833802`)
* **Firebase Storage Bucket:** `prm-projects.firebasestorage.app`
* **Android Client Package:** `com.example.prm_project` (App ID: `1:213546833802:android:dc522280f180f3baeeda73`)
* **Cloudflare R2 Storage Endpoint:** `https://d83b40f9ba48c1a0952568b9620ee62f.r2.cloudflarestorage.com/prm-project`
* **Cloudflare Edge Worker:** `*-prm-project.agrilog.workers.dev` (`https://prm-project.agrilog.workers.dev`)

---

### 2. User Requirements

#### 2.1 Actors

| # | Actor | Description |
| :--- | :--- | :--- |
| **1** | **Administrator** | Operates and moderates the platform. Verifies landlord identities (KYC), reviews pending room posts, resolves user violation reports, configures system parameters, and monitors activities via the dashboard. |
| **2** | **House Owner (Chủ trọ)** | Manages rental apartment buildings, publishes room listings with detailed pricing (rent, electricity, water, service charges), receives and manages viewing appointments, and chats in real time with prospective tenants. |
| **3** | **House Finder (Người tìm trọ)** | Students and workers looking for rental accommodations. Searches by map radius / GPS or district, views verified photos and utility costs, saves favorite homes, books viewing appointments, chats with landlords, and leaves reviews. |
| **4** | **Guest** | Unauthenticated user exploring the app. Can browse public approved listings and search by location. Must register/login to save favorites, chat, or request viewing appointments. |

---

### 3. Use Case Specifications

#### 3.1 Standardized Use Case Inventory (UC-01 to UC-36)

| Use Case ID | Name | Actor | Description |
| :--- | :--- | :--- | :--- |
| **UC-01** | Manage Housing Posts | Admin | Search, filter, and view details of all submitted listings. |
| **UC-02** | Approve/Reject Post | Admin | Review listing content and approve or reject with mandatory reason. |
| **UC-03** | Manage Reports | Admin | Review user-reported fraudulent listings or scam landlords. |
| **UC-04** | Configure System Settings | Admin | Adjust auto-ban report thresholds, post expiration days, support hotline. |
| **UC-05** | Manage User Accounts | Admin | Search, filter, and view account profiles across all roles. |
| **UC-06** | Ban/Unban User Account | Admin | Ban accounts violating policies; auto-hide all listings of banned users. |
| **UC-07** | **Manage Roles & Host KYC** | Admin | Review submitted landlord IDs and promote verified users to Owner. |
| **UC-08** | Manage Categories & Amenities | Admin | Add, edit, or deactivate room categories and standard facilities. |
| **UC-09** | View Activity Audit Logs | Admin | Track immutable administrative actions (bans, approvals, settings updates). |
| **UC-10** | Search & Filter Listings | Finder / Guest | Search by district, price range, room type, utilities, amenities. |
| **UC-11** | View Listing Details | Finder / Guest | View photo gallery, transparent utility rates, map location, landlord info. |
| **UC-12** | Save / Unsave Favorite Listing | House Finder | Manage personalized saved properties (wishlist). |
| **UC-13** | Book Viewing Appointment | House Finder | Select date, time slot, and send viewing request to landlord. |
| **UC-14** | Cancel Appointment | House Finder | Cancel a pending or approved appointment with a reason before the event. |
| **UC-15** | Real-Time Chat | Finder / Owner | Real-time in-app conversation with quick questions and image sharing. |
| **UC-16** | Rate & Review Room | House Finder | Submit 1-5 star ratings and reviews after completing a viewing. |
| **UC-17** | Report Listing / Landlord | House Finder | Submit scam or false pricing reports with evidence screenshots. |
| **UC-18** | Manage Personal Profile | Finder / Owner | Edit profile information, avatar, phone number, and password. |
| **UC-19** | **Apply for Landlord KYC** | House Finder | Submit identity documents to be certified as a verified Host. |
| **UC-20** | **Create Apartment Building** | House Owner | Register an apartment or boarding house complex (address, GPS, rules). |
| **UC-21** | Update Apartment Details | House Owner | Modify building information and general rules. |
| **UC-22** | View My Listings | House Owner | View dashboard of all created room posts with status badges. |
| **UC-23** | Add New House Post | House Owner | Create a room post under an existing apartment with pricing and photos. |
| **UC-24** | Edit House Post | House Owner | Update listing description, rent price, or photo gallery. |
| **UC-25** | **Toggle Room Availability** | House Owner | Switch listing between Available (Còn phòng), Rented (Đã thuê), or Hidden. |
| **UC-26** | **Manage Appointment Requests** | House Owner | Review incoming viewing requests; Approve or Reject with reason. |
| **UC-27** | **Complete Appointment** | Owner / Finder | Confirm that a physical room viewing occurred. |
| **UC-28** | **Reply to Review** | House Owner | Post a public response to a tenant review. |
| **UC-29** | View Owner Analytics | House Owner | Monitor listing views, appointment trends, and occupancy rates. |
| **UC-30** | In-App Notification Center | All Users | Receive and view real-time push alerts. |
| **UC-31** | Register Account | Guest | Create new account via email/password or Google Sign-In. |
| **UC-32** | Login / Authenticate | Guest | Sign in and acquire Firebase JWT token. |
| **UC-33** | **Forgot Password** | Guest | Request a password reset email via Firebase Authentication. |
| **UC-34** | **Quick Call Landlord** | House Finder | Launch phone dialer directly from listing detail page. |
| **UC-35** | Mark Notifications Read | All Users | Mark individual or all notifications as read. |
| **UC-36** | **Search by GPS Radius** | Finder / Guest | Search for rental rooms within 1km - 10km of current location. |

---

### 4. Data Architecture (Cloud Firestore NoSQL + Cloudflare R2)

#### 4.1 Collections
* `users`: Profiles, custom claims (`role`), verification state.
* `apartments`: Boarding house / building metadata and GPS location.
* `listings`: Room posts, pricing breakdown, amenities array, Cloudflare R2 images.
* `appointments`: Booking viewing dates, time slots, 5 statuses (`pending`, `approved`, `rejected`, `completed`, `cancelled`).
* `chat_rooms` & `messages`: Real-time chat threads.
* `reviews`: Chấm sao và nhận xét từ khách đã xem phòng.
* `reports`: Báo cáo sai phạm tin bài / chủ trọ lừa đảo.
* `notifications`: FCM alerts history.

---

### 5. Comprehensive API Catalog

The platform exposes RESTful endpoints routed through **Cloudflare Workers** and backed by **Firebase Services**:

| # | Group | Method | Endpoint | Access Role | Description & Payload |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | Auth | `POST` | `/api/auth/register` | Public | Register account with `{ email, password, fullName, phone, role }`. |
| **2** | Auth | `POST` | `/api/auth/login` | Public | Authenticate with credentials; returns JWT and user profile. |
| **3** | Auth | `POST` | `/api/auth/google-login` | Public | Login via Firebase Google Auth token `{ idToken }`. |
| **4** | Auth | `POST` | `/api/auth/reset-password` | Public | Send password reset email `{ email }`. |
| **5** | Users | `GET` | `/api/users/profile` | Authenticated | Retrieve current user profile and role claims. |
| **6** | Users | `PUT` | `/api/users/profile` | Authenticated | Update user information `{ fullName, avatarUrl, phone }`. |
| **7** | Users | `POST` | `/api/users/apply-host` | Finder | Apply for Landlord KYC `{ idCardNumber, frontCardUrl, backCardUrl }`. |
| **8** | Apartments | `GET` | `/api/apartments/my` | House Owner | List all apartment complexes owned by landlord. |
| **9** | Apartments | `POST` | `/api/apartments` | House Owner | Create building `{ name, address, district, city, lat, lng, rules }`. |
| **10**| Listings | `GET` | `/api/listings` | Public | Search & filter listings `{ city, district, minPrice, maxPrice, category, amenities }`. |
| **11**| Listings | `GET` | `/api/listings/nearby` | Public | Geo-search `{ lat, lng, radiusKm }` within 1km - 10km. |
| **12**| Listings | `GET` | `/api/listings/:id` | Public | Retrieve full listing details including landlord info. |
| **13**| Listings | `GET` | `/api/listings/my-posts` | House Owner | Retrieve all posts created by landlord with statuses. |
| **14**| Listings | `POST` | `/api/listings` | House Owner | Submit listing `{ apartmentId, title, pricing, specs, amenities, images }`. |
| **15**| Listings | `PATCH` | `/api/listings/:id/status` | House Owner | Toggle room status `{ roomStatus: "available" \| "rented" \| "hidden" }`. |
| **16**| Media | `POST` | `/api/media/presigned-url` | Authenticated | Generate Cloudflare R2 upload URL `{ fileName, fileType, folder }`. |
| **17**| Favorites| `GET` | `/api/favorites` | House Finder | List saved listings for current user. |
| **18**| Favorites| `POST` | `/api/favorites/:listingId` | House Finder | Add room to favorites. |
| **19**| Bookings | `POST` | `/api/appointments` | House Finder | Book viewing `{ listingId, appointmentDate, appointmentTime, note }`. |
| **20**| Bookings | `GET` | `/api/appointments/my` | House Finder | List viewing appointments booked by user. |
| **21**| Bookings | `PATCH` | `/api/appointments/:id/cancel`| House Finder | Cancel appointment `{ reason }`. |
| **22**| Bookings | `GET` | `/api/appointments/requests` | House Owner | List incoming viewing requests for landlord's rooms. |
| **23**| Bookings | `PATCH` | `/api/appointments/:id/approve`| House Owner | Landlord accepts appointment request. |
| **24**| Bookings | `PATCH` | `/api/appointments/:id/reject` | House Owner | Landlord declines request `{ reason }`. |
| **25**| Bookings | `PATCH` | `/api/appointments/:id/complete`| Owner / Finder| Mark viewing as completed to unlock review capability. |
| **26**| Chat | `GET` | `/api/chat/rooms` | Authenticated | Retrieve active conversation threads. |
| **27**| Chat | `POST` | `/api/chat/rooms/:id/messages`| Authenticated | Send message `{ text, imageUrl }`. |
| **28**| Reviews | `POST` | `/api/reviews` | House Finder | Create review `{ listingId, rating, comment }` (Must have completed viewing). |
| **29**| Admin | `GET` | `/api/admin/dashboard` | Admin | Retrieve operational KPIs (active users, pending posts, reports). |
| **30**| Admin | `PATCH` | `/api/admin/listings/:id/approve`| Admin | Approve pending listing. |
| **31**| Admin | `PATCH` | `/api/admin/listings/:id/reject` | Admin | Reject listing `{ reason }`. |
| **32**| Admin | `PATCH` | `/api/admin/users/:id/verify-host`| Admin | Approve host KYC verification and upgrade role to Owner. |
| **33**| Admin | `PATCH` | `/api/admin/users/:id/ban` | Admin | Suspend user account and auto-hide posts `{ reason, durationDays }`. |

---

### 6. Business Rules & Application Messages

#### 6.1 Business Rules
* **BR-01 (Mandatory Post Verification):** All newly submitted or edited room posts must be reviewed and approved by an Administrator before appearing in search results.
* **BR-02 (Transparent Utility Pricing):** Every listing must explicitly state electricity (per kWh or shared) and water costs (per m3 or person).
* **BR-03 (Photo Authenticity):** Listings require at least 3 genuine room photos stored on Cloudflare R2.
* **BR-04 (Host Certification):** Only users who have completed KYC verification may publish listings.
* **BR-05 (Appointment Scheduling Window):** Appointments must be scheduled at least 2 hours in advance and within 7 calendar days.
* **BR-06 (Review Eligibility):** Only House Finders who have an appointment marked `completed` with that landlord can rate and review the property.
* **BR-07 (Banned Account Cascade):** When an account is banned by an Administrator, all active listings owned by that account are immediately hidden from public view.
* **BR-08 (Listing Expiration):** Approved listings expire automatically after 30 days unless renewed by the landlord.
