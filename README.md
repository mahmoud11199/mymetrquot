# mymetrquot

Digital taxi meter application built with Flutter, with a secure PHP/MySQL backend for trip persistence.

## Features

- Live meter UI with:
  - Current fare in EGP
  - Elapsed trip time
  - Distance traveled
- Start, Pause, and Reset controls
- Secure login flow against PHP API (`login.php`) returning JWT
- Authenticated trip CRUD over HTTP with `Authorization: Bearer <token>`
- Trips list rendered in Flutter (`ListView`) with delete action
- Fare calculation with configurable constants:
  - Base fare
  - Per-kilometer rate
  - Per-minute rate
- GPS distance tracking via `geolocator`

## Backend setup (`/backend`)

1. Create MySQL database (example: `mymetrquot`) and import schema:

```bash
mysql -u root -p mymetrquot < backend/schema.sql
```

2. Configure DB credentials and JWT secret in `backend/config.php`.
3. Serve backend via Apache/Nginx + PHP (or php built-in server for local testing).

### API endpoints

- `POST /backend/login.php` → `{ username, password }` → returns JWT
- `POST /backend/add_trip.php` (JWT required)
- `GET /backend/get_trips.php` (JWT required)
- `POST /backend/delete_trip.php` (JWT required)

All SQL access uses prepared statements.

## Flutter setup

1. Install dependencies:

```bash
flutter pub get
```

2. Update `ApiClient.baseUrl` in `lib/services/api_client.dart` to match your backend URL.
   - Android emulator typically uses `http://10.0.2.2/<path>` instead of `localhost`.

3. Run app:

```bash
flutter run
```

## Test

```bash
flutter test
```
