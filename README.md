# mymetrquot

Flutter + PHP/MySQL MVP for a ride-hailing style taxi meter platform.

## Implemented MVP modules

- Authentication with JWT (`register.php`, `login.php`) and role claims (`rider`, `driver`, `admin`).
- Rider ride-request flow (`create_ride_request.php`, `get_ride_requests.php`).
- Driver offer flow (`create_offer.php`, `get_offers.php`, `update_offer_status.php`).
- Trip lifecycle (`add_trip.php`, `get_trips.php`, `update_trip_status.php`, `delete_trip.php`).
- Chat negotiation (`send_message.php`, `get_messages.php`).
- Ratings (`submit_rating.php`).
- Notifications (`get_notifications.php`, `mark_notification_read.php`) with server-side notification creation hooks.
- Admin audit endpoint (`admin_get_audit_logs.php`).
- Live tracking data APIs (`update_location.php`, `get_trip_route.php`) for map route rendering and playback.

## Flutter notes

- `lib/services/api_client.dart` includes endpoint helpers for:
  - auth
  - ride requests
  - offers
  - trips
  - messages
  - ratings
  - notifications
  - live location route retrieval
- Backend URL is configured via `--dart-define API_BASE_URL=...` with default `https://alalameyaforcontracting.iceiy.com/backend
`.

## Database

Import `backend/schema.sql` to create these requirement-aligned tables:

- `Users`
- `DriverProfiles`
- `Vehicles`
- `RideRequests`
- `Offers`
- `Trips`
- `Messages`
- `Ratings`
- `Disputes`
- `Documents`
- `Notifications`
- `AuditLogs`
- `Locations`
- `Settings`

## CI

GitHub Actions workflow `.github/workflows/flutter-build.yml` now runs tests before Android/iOS builds.
