# 🛠️ Tech Stack & System Architecture

This template is structured to operate as a production-grade template for high-end restaurant systems.

## 📱 Frontend (Flutter Codebase)
* **Framework**: Flutter (Multi-platform: Android, iOS, Web, Desktop)
* **State Management**: Provider (Centralized reactivity pattern)
* **Styling**: Sleek HSL-based Custom Themes (Dark Mode optimized)
* **Real-time Engine**: Socket.io Client
* **Payment Layer**: Stripe (API charge simulations)
* **Dynamic Visuals**: CustomPainter (Interactive rotating 3D models and animated GPS routes)

## ⚙️ Backend (Node.js & Websockets)
* **Runtime**: Node.js
* **Framework**: Express.js
* **Real-time Pipeline**: Socket.io Server
* **Networking**: Cross-Origin Resource Sharing (CORS) configured
* **API Architecture**: REST Endpoints (for menus, orders, reservations) + WebSockets (for active streams)

## 📡 Integrations
* **Payments**: Stripe API SDK Wrapper
* **Notifications**: Firebase Cloud Messaging (Push Notifications) & Twilio SDK (SMS Alerts)
* **Maps**: Google Maps API & custom vector fallback systems
* **Database**: MongoDB / PostgreSQL integration layer ready (in-memory fallbacks included for instant template runtime)
