# Weather Dashboard - Student Index 224143T

A Flutter-based weather dashboard application that calculates geographical coordinates from a student index number and fetches real-time weather data.

## Features

- Calculate coordinates based on student index (Formula: Lat = 5.0 + first2digits/10, Lon = 79.0 + next2digits/10)
- Fetch real-time weather data from Open-Meteo API
- Modern dark theme UI with sleek black and dark blue design
- Local caching for offline access
- Error handling with user-friendly messages

## Technologies Used

- Flutter
- Open-Meteo Weather API
- SharedPreferences for local storage
- HTTP package for API requests

## Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## API Endpoint

```
https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true
```


