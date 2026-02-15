# Mini E-Commerce Frontend (Flutter)

Flutter mobile app for browsing products, adding to cart, and guest checkout.

## Tech Stack
- Flutter (Dart)
- HTTP package for API calls
- Android APK built

## Features
- Product list from Django backend API
- Add to cart (local state)
- Cart summary with total
- Guest checkout with full name field
- Dummy order placement (clears cart)

## Setup & Run

1. Clone the repo
2. Install dependencies:

flutter pub get
text3. Run in Chrome (web):
flutter run -d chrome
text4. Build Android release APK:
flutter build apk --release
textAPK location: `build/app/outputs/flutter-apk/app-release.apk`

## Backend API used
`http://127.0.0.1:8000/api/products/` (local development)

