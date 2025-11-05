# Quick Start Guide - Weather Dashboard

## 🚀 Running the Application

### Step 1: Install Dependencies
```bash
cd "c:\Users\D E L L\OneDrive\Desktop\Wireless project\project_224143t"
flutter pub get
```

### Step 2: Run on Android Emulator/Device
```bash
flutter run
```

### Step 3: Testing the App

#### Test 1: Online Weather Fetch
1. Open the app
2. The index "224143" is pre-filled
3. Tap **"Fetch Weather"** button
4. Observe:
   - Loading indicator appears
   - Coordinates displayed: Lat: 7.20, Lon: 83.10
   - Weather data appears with temperature, wind speed, weather code
   - Last updated time shown
   - Request URL visible at bottom

#### Test 2: Offline/Cached Mode
1. After successful fetch, enable **Airplane Mode** on your device
2. Tap **"Fetch Weather"** button again
3. Observe:
   - Error message appears (network error)
   - Cached weather data still visible
   - Orange **(cached)** tag appears next to "Weather Data"

#### Test 3: Different Index
1. Change the index to "194174" (or any other)
2. Tap **"Fetch Weather"**
3. Observe new coordinates:
   - Lat: 6.90 (from 19)
   - Lon: 83.10 (from 41)
4. New weather data fetched for that location

## 📸 Screenshot Checklist

Take these screenshots for your report:

1. **Screenshot 1**: App showing index "224143" with calculated coordinates
2. **Screenshot 2**: Weather data displayed with request URL visible at bottom
3. **Screenshot 3**: Offline mode showing error + cached data with "(cached)" tag

## 🎥 Video Recording Steps (60 seconds)

**Script:**
1. (0-10s) Show app, type/confirm index "224143"
2. (10-20s) Tap "Fetch Weather", show loading indicator
3. (20-35s) Show weather results: temperature, wind, code, and request URL
4. (35-45s) Enable Airplane Mode (show settings or swipe down)
5. (45-55s) Return to app, tap "Fetch Weather" again
6. (55-60s) Show error message + cached data with "(cached)" tag

## 📋 Features Verification

### ✅ Required Features:
- [x] Text input for student index (pre-filled)
- [x] Computed lat/lon displayed (2 decimals)
- [x] "Fetch Weather" button
- [x] Temperature (°C) displayed
- [x] Wind speed displayed
- [x] Weather code (raw number) displayed
- [x] Last updated time shown
- [x] Request URL visible in small text
- [x] Loading indicator while fetching
- [x] Friendly error messages
- [x] Cached data with "(cached)" tag
- [x] Works offline after first fetch

## 🐛 Troubleshooting

### Issue: "No devices found"
**Solution:** 
- Start Android emulator: Android Studio → Device Manager → Play button
- Or connect physical device with USB debugging enabled

### Issue: "Gradle build failed"
**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "Network error" on first fetch
**Solution:**
- Check internet connection
- Verify firewall isn't blocking Open-Meteo API
- Try from mobile data instead of university WiFi

### Issue: App doesn't show cached data
**Solution:**
- Make sure to fetch weather successfully at least once
- Check that Airplane Mode is enabled properly
- Restart app to load cached data on startup

## 📊 Expected Output Examples

### Index: 224143
- **Latitude:** 7.20
- **Longitude:** 83.10
- **Request URL:** `https://api.open-meteo.com/v1/forecast?latitude=7.2&longitude=83.1&current_weather=true`

### Index: 194174
- **Latitude:** 6.90
- **Longitude:** 83.10
- **Request URL:** `https://api.open-meteo.com/v1/forecast?latitude=6.9&longitude=83.1&current_weather=true`

## 🎯 Testing on Different Networks

1. **WiFi:** Should work normally
2. **Mobile Data:** Should work normally
3. **Airplane Mode:** Should show cached data + error
4. **No Internet (first launch):** Shows error, no cached data yet

## 📝 Notes for Report

**Include these points:**

1. **Index Used:** 224143
2. **Formula Explanation:**
   - First two digits: 22
   - Next two digits: 41
   - Latitude: 5 + (22/10.0) = 7.20
   - Longitude: 79 + (41/10.0) = 83.10

3. **API Used:** Open-Meteo (https://open-meteo.com)
4. **Packages:** http, shared_preferences, intl

**Reflection (3-5 sentences):**
- What you learned about REST APIs in Flutter
- How you implemented offline caching
- Challenges faced (network handling, JSON parsing)
- What you would improve (better UI, more weather details)

Good luck with your assignment! 🎓
