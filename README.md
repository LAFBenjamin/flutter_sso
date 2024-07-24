# Flutter SSO Project

This project demonstrates Single Sign-On (SSO) implementation in a Flutter application using Keycloak as the authentication server.

## Features

- Login with Keycloak using AppAuth
- Login with Keycloak using WebView
- Secure token storage
- Multiple app demonstrations (Simple App 1, Simple App 2)
- In-app WebView integration

## Setup

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Keycloak server settings in `lib/login_page.dart`

## Usage

Run the app using `flutter run`. The main login page offers various authentication options and demo apps.

## Key Components

- `login_page.dart`: Main authentication logic and UI
- `keycloak_auth_wrapper.dart`: Custom Keycloak authentication wrapper
- `simple_app_1.dart`, `simple_app_2.dart`: Demo applications
- `simple_app_inapp_2.dart`: In-app WebView demo

## Dependencies

- flutter_appauth
- flutter_secure_storage
- http

## Configuration

Update the following variables in `login_page.dart` with your Keycloak server details:

```dart
final String _clientId = 'mobile';
final String _redirectUrl = 'myapp://callback';
final String _issuer = 'http://localhost:8080//realms/sso';
final String _discoveryUrl = 'http://localhost:8080/realms/sso/.well-known/openid-configuration';
