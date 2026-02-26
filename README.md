# mymetrquot

Digital taxi meter application built with Flutter.

## Features

- Live meter UI with:
  - Current fare in EGP
  - Elapsed trip time
  - Distance traveled
- Start, Pause, and Reset controls
- Fare calculation with configurable constants:
  - Base fare
  - Per-kilometer rate
  - Per-minute rate
- GPS distance tracking via `geolocator`
- Unit tests for fare calculation logic

## Default fare settings

- Base fare: `10 EGP`
- Per kilometer: `3 EGP/km`
- Per minute: `0.5 EGP/min`

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```
