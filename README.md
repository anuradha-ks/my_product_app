# Firebase Authentication – In-Class Activity 13

## Project Overview

This is a Flutter application developed for In-Class Activity 13. It uses Firebase Authentication to allow users to register with an email and password, sign in, view their profile, update their password, and sign out.

The application uses Firebase Authentication to manage user sessions and automatically switches between the authentication screen and profile screen depending on whether the user is signed in.

## Features

- **Register:** Create a new account using an email address and password.
- **Sign In:** Authenticate using an existing email and password.
- **Input Validation:** Validate required fields and display helpful error messages.
- **Password Visibility:** Show or hide the password while entering it.
- **Authentication State:** Use `authStateChanges()` to automatically display the appropriate screen.
- **Profile:** Display the email address of the currently signed-in user.
- **Update Password:** Request the current password, reauthenticate the user, and update the password.
- **Sign Out:** Sign out of the application and return to the authentication screen.

## Project Structure

```text
lib/
├── main.dart
├── firebase_options.dart
├── screens/
│   ├── authentication_screen.dart
│   └── profile_screen.dart
└── services/
    └── auth_service.dart
```

- **main.dart:** Initializes Firebase and listens for authentication-state changes using `StreamBuilder`.
- **firebase_options.dart:** Contains Firebase configuration generated using FlutterFire CLI.
- **auth_service.dart:** Handles Firebase Authentication operations, including registration, sign-in, sign-out, and password updates.
- **authentication_screen.dart:** Provides the login and registration interface with input validation and error handling.
- **profile_screen.dart:** Displays the signed-in user's email and provides options to update the password and sign out.

## How to Run

1. Install Flutter and configure an Android emulator or connected device.
2. Clone the repository:

   ```bash
   git clone https://github.com/anuradha-ks/my_product_app.git
   cd my_product_app
   ```

3. Install the required dependencies:

   ```bash
   flutter pub get
   ```

4. Make sure the application is configured with the Firebase project and that Email/Password authentication is enabled in Firebase Console. If configuring a new Firebase project, use:

   ```bash
   flutterfire configure
   ```

5. Run the application:

   ```bash
   flutter run
   ```

6. To build the Android release APK:

   ```bash
   flutter build apk --release
   ```

   The generated APK will be available at:

   ```text
   build/app/outputs/flutter-apk/app-release.apk
   ```

## Testing

The application was tested using the iPhone simulator. The following authentication features were checked:

| Test | Observation |
|---|---|
| Sign in with valid credentials | Successfully opened the profile screen and displayed the user's email. |
| Enter incorrect login credentials | Displayed the error message "Incorrect email or password." |
| Password update | Displayed the password update dialog and the success message after updating. |
| Sign out | Returned to the authentication screen. |
| Registration interface | The Create Account screen was displayed. A separate successful new-user registration was not documented. |

Additional useful tests include creating a new account, checking session persistence after restarting the application, and verifying that the old password no longer works after a password update.

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Firebase Core
- Cloud Firestore (existing project dependency)

## AI Disclosure

ChatGPT (GPT-6) was used on November 5, 2026, to assist with reviewing the application design, authentication implementation, and testing considerations.