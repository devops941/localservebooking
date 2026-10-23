# Local Service Booking System

Full-stack application for Local Service Booking featuring 3 dedicated modules:
1. **Customer Module** (Mobile App Experience)
2. **Service Provider Module** (Mobile App Experience)
3. **Admin Module** (Web View / Responsive Web Portal)

---

## 📁 Repository Structure

```
local_service_booking_mobileapp/
├── backend/                       # Node.js + Express + MongoDB REST API
│   ├── config/db.js               # MongoDB connection
│   ├── controllers/               # Auth, User, Category, Provider, Booking, Admin
│   ├── middleware/                # JWT Auth & Role-based Authorization
│   ├── models/                    # User, Category, ProviderProfile, Booking
│   ├── routes/                    # API endpoints
│   ├── utils/                     # JWT & Response utilities
│   ├── server.js                  # Main server entrypoint
│   └── package.json
│
└── frontend/                      # Flutter Application (Mobile + Web)
    ├── lib/
    │   ├── main.dart
    │   ├── models/                # Customer, Category, Provider, Booking
    │   ├── services/              # Auth, Provider, Booking services
    │   ├── widgets/               # Custom button, textfield, provider card
    │   └── views/
    │       ├── role_selector_screen.dart   # Interactive 3-in-1 Module Launcher
    │       ├── auth/                       # Splash, Login, Register, Forgot Password
    │       ├── customer/                   # 12 Customer Screens (Home, Categories, Booking, etc.)
    │       ├── provider/                   # 7 Provider Screens (Online Toggle, Requests, Jobs, Wallet)
    │       └── admin/                      # 6 Admin Web Screens (Dashboard, KYC, Bookings, Analytics)
    └── pubspec.yaml
```

---

## 🚀 Getting Started

### 1. Run the Backend Server
```bash
cd backend
npm install
npm start
```
API runs on `http://localhost:5000`.

### 2. Run the Frontend App
```bash
cd frontend
flutter pub get
flutter run
```
On launch, the interactive **Role Selector** enables you to open the **Customer**, **Service Provider**, or **Admin Web View** module directly.
# localservebooking
