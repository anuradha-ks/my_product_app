# Firebase Product Manager – In-Class 12

A Flutter product catalogue backed by Cloud Firestore.

## Features
- Create, read, update, and delete products
- Real-time updates with `StreamBuilder`
- Case-insensitive substring search
- Inclusive minimum and maximum price filters
- Combined search and price filtering
- Reset filters
- Product name and numeric price validation
- Firestore error handling

## Firestore schema
Collection: `products`

Each document:
- `name`: String
- `price`: Number (integer or double)

## Setup
1. Install Flutter and configure an Android emulator/device.
2. Install Firebase CLI and FlutterFire CLI.
3. From this project directory run:

   ```bash
   flutter pub get
   flutterfire configure --platforms=android
   ```

4. Ensure `lib/firebase_options.dart` is generated for your own Firebase project.
5. Run:

   ```bash
   flutter run
   ```

## Notes
- Do not copy another student's `firebase_options.dart`.
- Use fictional class data only.
- Firestore test mode is temporary and is not suitable for production.
- Run `flutter analyze` and complete the assignment's T1–T8 tests before submitting.
- Record actual test outcomes in your report; do not claim tests passed unless you observed them.
