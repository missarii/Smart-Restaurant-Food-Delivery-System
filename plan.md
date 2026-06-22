# Implementation Plan - Smart Restaurant & Food Delivery System Template

We will build a complete, highly-polished template for the restaurant ecosystem. It will use a Flutter monorepo structure for maximum code reuse, combined with a Node.js + Express + Socket.io backend.

## Architecture

We will structure the workspace as follows:

```text
/home/missari/Smart Restaurant & Food Delivery System/
├── shared/                   # Shared Dart package containing models, API services, localizations, and UI widgets
│   ├── lib/
│   │   ├── models/           # Order, User, MenuItem, Table, Review, ChatMessage
│   │   ├── services/         # SocketService, ApiService, LocationService, TranslationService, StorageService
│   │   ├── theme/            # Shared premium dark/light HSL palettes, typography
│   │   └── widgets/          # Shared components (buttons, text fields, cards, custom painters)
│   └── pubspec.yaml
│
├── customer_app/             # Flutter app for Customers (iOS, Android)
│   ├── lib/                  # Browse, 3D Showcase, AI Recommendations, Cart, Stripe Pay, Tracking, QR table order, Chat, Reservations
│   └── pubspec.yaml
│
├── rider_app/                # Flutter app for Delivery Riders (iOS, Android)
│   ├── lib/                  # Order accept, GPS simulation, Location sharing, Earnings, Status update
│   └── pubspec.yaml
│
├── admin_panel/              # Flutter app for Admins (Web)
│   ├── lib/                  # Dashboard, Analytics, Order Management, Category/Menu manager, Promos
│   └── pubspec.yaml
│
├── kitchen_display/          # Flutter app for Kitchen staff (Tablet/Desktop)
│   ├── lib/                  # Queue view, Status updates (Preparing, Ready), Sound alerts
│   └── pubspec.yaml
│
└── backend/                  # Node.js + Express + Socket.io API
    ├── src/
    │   ├── controllers/      # auth, menu, order, reservation, chat, payment, ai
    │   ├── models/           # MongoDB schemas (or mock DB if MongoDB is not running locally)
    │   ├── socket/           # Real-time GPS rider updates, Kitchen preparation updates, chat rooms
    │   └── server.js
    ├── package.json
    └── README.md
```

## Core Features to Implement

### 1. Shared Package (`shared/`)
* **State Management / Dependency Injection**: Simple and robust state management (e.g. `Provider` or lightweight reactive service pattern).
* **Models**: Complete schemas for Menu, Order (with statuses: `placed`, `accepted`, `preparing`, `ready`, `delivered`), User, Reservation, and ChatMessage.
* **Services**:
  * `SocketService`: Socket.io client wrapper for real-time order states and GPS tracking.
  * `TranslationService`: Translation keys for English, Sinhala, and Tamil.
  * `PaymentService`: Stripe mock client with payment flow.

### 2. Customer App (`customer_app/`)
* **Visuals**: Premium UI with rich aesthetics, dark mode, smooth transitions, custom Hero animations.
* **3D Food Showcase**: Built using custom shaders, Canvas/CustomPainter, or an interactive rotating 3D mock renderer representing a high-fidelity dish viewer.
* **AI Food Recommendations**: Simulated AI engine suggesting food based on time, weather, and order history.
* **Live Order Tracking**: Dynamic map interface (or a rich visual tracking dashboard with live coordinates) receiving rider position in real-time.
* **QR Table Ordering**: Table scanner/selector that updates the server with specific table IDs.
* **Online Reservations**: Date-time and slot selector for reservation, synced to backend.

### 3. Rider App (`rider_app/`)
* **Map Tracking**: Periodic GPS coordinate updates sent to Socket.io backend.
* **Acceptance Flow**: Incoming order cards with distance, payout, and map routing.
* **Earnings Dashboard**: Daily/weekly charts showing earnings, distance covered, and ratings.

### 4. Admin Panel (`admin_panel/`)
* **Interactive Dashboard**: Graphs for daily sales, order count, visual charts of popular foods, customer retention.
* **Order Controller**: Real-time incoming order sound/notifications, action buttons (Accept, Start Preparing, Ready, Reject).
* **Menu/Promotions Manager**: Forms to add/edit menu items and customize promo banners.

### 5. Kitchen Display (`kitchen_display/`)
* **Trello-like Kanban Board**: Ordered columns for `Incoming`, `Preparing`, and `Ready`.
* **Sound Alerts**: Audio chime upon new order arrival.
* **Ready notifications**: Button that triggers alerts to both Admin and Rider apps.

### 6. Node.js Backend (`backend/`)
* Express API + Socket.io server.
* Simulation of rider location movements if no active rider is online, enabling instant verification.
* Integration endpoints for menu management, payments (Stripe SDK stub), table reservations, and chat.

---

## Verification Plan

### Automated Checks
* Verify Dart syntax and static analysis in each sub-directory.
* Run Express server locally to verify Socket.io handshake and HTTP routes.

### Manual Verification
* Run the node server.
* Check Web App and Mobile layouts in mock view/browser simulation.
