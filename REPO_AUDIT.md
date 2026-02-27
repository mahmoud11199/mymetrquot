# mymetrquot Repository Audit

## 1) Flutter project structure

Status: **Partially complete**.

- Present: `pubspec.yaml`, `lib/main.dart`.
- Missing from repository: `android/` and `ios/` directories.
- Note: CI currently runs `flutter create --platforms=android,ios .` to regenerate those folders during build.

### Suggested fix

Generate and commit native folders so local developers can build/run without relying on CI regeneration:

```bash
flutter create --platforms=android,ios .
```

## 2) Backend API files

Status: **Complete**.

All required files are present:
- `backend/config.php`
- `backend/login.php`
- `backend/add_trip.php`
- `backend/get_trips.php`
- `backend/delete_trip.php`

## 3) Database schema

Status: **Mostly complete with naming mismatch**.

- `users` table includes `username` and `password_hash` (secure form of password storage).
- `trips` table includes `distance`, `duration`, `fare`, `date`.

### Suggested adjustment (if strict field naming is required)

If your requirement is exactly `password` (not recommended), rename the column and update queries. Prefer keeping `password_hash` for security.

## 4) JWT authentication

Status: **Implemented correctly for a lightweight API**.

- JWT creation in `backend/utils.php` (`createJwt`).
- Signature validation + issuer/expiry checks in `validateJwt`.
- Bearer token extraction in `getBearerToken`.
- Protected endpoints call `requireAuth()`.

### Recommended hardening

- Store trips per user by adding `user_id` to `trips` and filtering in `get_trips.php`.
- Rotate `JWT_SECRET` to a long random value and avoid committing secrets.

## 5) Flutter API base URL

Status: **Updated in this patch**.

- Changed `lib/services/api_client.dart` to use a configurable URL via `--dart-define`.
- Default now targets Android emulator loopback (`http://10.0.2.2/backend`) instead of `localhost`.

## 6) GitHub Actions build workflow

Status: **Present and functional**.

- Workflow file exists at `.github/workflows/flutter-build.yml`.
- It installs Flutter, runs `flutter pub get`, builds APK, and uploads artifact.

### Suggested improvement

- Consider running tests before build:

```yaml
- name: Run tests
  run: flutter test
```

## 7) Missing/incomplete/misconfigured items summary

1. Missing committed Flutter platform folders: `android/`, `ios/`.
2. API base URL originally used `localhost` (mobile-incompatible); corrected in this patch.
3. Database requirement wording says `password`; implementation uses `password_hash` (secure, but naming mismatch if strict).
4. Trips are not user-scoped despite JWT authentication.
5. `backend/config.php` contains hardcoded local credentials and placeholder JWT secret; should be environment-based for production.
