# 🍜 Smart Restaurant & Food Delivery System Template

This is a complete, multi-app template powering a full restaurant ecosystem from a single codebase structure. 

## 📂 Codebase Structure

```text
├── shared/                   # Shared Dart package containing models, API services, localizations, and UI widgets
├── customer_app/             # Customer mobile/web client (Stripe, 3D showcases, AI suggestions, QR scan, chat)
├── rider_app/                # Rider mobile client (GPS tracking stream, earnings wallet)
├── admin_panel/              # Restaurant Web control panel (Analytics charts, menu/reservation manager)
├── kitchen_display/          # Kitchen Tablet/Desktop client (Kanban prep queue, audio notifications)
└── backend/                  # Node.js + Express API + Socket.io Server
```

---

## 🚀 Running the Apps

### 1. Launch the Backend
Navigate to the `backend/` directory, install dependencies, and start the local development server:
```bash
cd backend
npm install
npm run dev
```
The server will run on `http://localhost:3000`.

### 2. Configure & Run Flutter Apps
Make sure your Flutter development environment is configured. Run `flutter pub get` in the shared folder first, then inside any of the app folders:

#### Get Dependencies:
```bash
cd shared && flutter pub get
cd ../customer_app && flutter pub get
cd ../rider_app && flutter pub get
cd ../admin_panel && flutter pub get
cd ../kitchen_display && flutter pub get
```

#### Run Customer App:
```bash
cd customer_app
flutter run -d chrome # Or your emulator/device ID
```

#### Run Rider App:
```bash
cd rider_app
flutter run -d chrome
```

#### Run Admin Panel (Web):
```bash
cd admin_panel
flutter run -d chrome
```

#### Run Kitchen Display System:
```bash
cd kitchen_display
flutter run -d chrome
```

---

## 🌟 Key Client-Impressing Features Included

1. **3D Food Showcase**: Custom mathematical projections rendered on a Flutter Canvas, allowing dragging/rotating 3D food items in real-time.
2. **AI Food Recommendations**: Simulated offline engine analyzing current cart content and time settings to upsell items dynamically.
3. **Live Order Tracking**: Dynamic vector road map rendering real-time animated rider progress updating along custom coordinate segments.
4. **QR Table Ordering**: Table scan simulation allowing instantly connecting to specific seating tables.
5. **Multi-language**: Immediate hot-swappable toggle support for English, Sinhala, and Tamil.
6. **Loyalty Points & Online Reservations**: Built-in tables scheduling and point multiplier wallets synced directly to backend pipelines.
