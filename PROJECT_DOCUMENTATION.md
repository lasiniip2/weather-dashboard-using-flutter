# Weather Dashboard - Flutter Application
## IN 3510 Wireless Communication & Mobile Networks - Final Assignment

---

## 📱 Project Overview

This is a **Personalized Weather Dashboard** built with Flutter that:
1. Takes a student index as input (e.g., 224143B)
2. Derives latitude and longitude coordinates from the index
3. Fetches real-time weather data from Open-Meteo API (no API key required)
4. Displays current weather conditions including temperature, wind speed, and weather code
5. Caches the last successful result for offline viewing
6. Shows the exact API request URL for verification

---

## 🎯 Key Features Implemented

### ✅ All Required Functionality

1. **Student Index Input**
   - Text field pre-filled with example index "224143"
   - Validates that first 4 characters are digits

2. **Coordinate Calculation**
   - Formula: 
     - `lat = 5.0 + (firstTwo / 10.0)` → Range: 5.0 to 15.9
     - `lon = 79.0 + (nextTwo / 10.0)` → Range: 79.0 to 89.9
   - Displays coordinates to 2 decimal places

3. **Weather API Integration**
   - Uses Open-Meteo API: `https://api.open-meteo.com/v1/forecast`
   - No API key required
   - 10-second timeout for network requests

4. **Data Display**
   - Temperature in °C
   - Wind speed in km/h
   - Weather code (raw number)
   - Last updated timestamp

5. **Request URL Display**
   - Shows complete API URL in small text
   - Selectable for easy copying
   - Visible on screen for verification

6. **Loading & Error Handling**
   - Circular progress indicator during fetch
   - Friendly error messages for network issues
   - Button disabled while loading

7. **Offline Caching**
   - Uses `shared_preferences` package
   - Saves last successful weather data
   - Shows "(cached)" tag when displaying offline data
   - Automatically loads cached data on app startup

---

## 🏗️ Project Structure

```
lib/
└── main.dart          # Complete application code (575 lines)

Key Dependencies:
- http: ^1.1.0                    # For API calls
- shared_preferences: ^2.2.2      # For local caching
- intl: ^0.19.0                   # For date formatting
```

---

## 🔧 Implementation Details

### 1. **Coordinate Calculation Logic**
```dart
void _calculateCoordinates() {
  String index = _indexController.text.trim();
  
  // Extract first two and next two digits
  int firstTwo = int.parse(index.substring(0, 2));  // e.g., 22
  int nextTwo = int.parse(index.substring(2, 4));   // e.g., 41
  
  // Calculate coordinates
  _latitude = 5.0 + (firstTwo / 10.0);   // 5.0 + 2.2 = 7.2
  _longitude = 79.0 + (nextTwo / 10.0);  // 79.0 + 4.1 = 83.1
}
```

**Example:**
- Index: `224143B`
- First two digits: `22`
- Next two digits: `41`
- Latitude: `5.0 + 2.2 = 7.20`
- Longitude: `79.0 + 4.1 = 83.10`

### 2. **API Call Implementation**
```dart
Future<void> _fetchWeather() async {
  // Build API URL
  _requestUrl = 'https://api.open-meteo.com/v1/forecast?'
                'latitude=${_latitude!.toStringAsFixed(1)}&'
                'longitude=${_longitude!.toStringAsFixed(1)}&'
                'current_weather=true';
  
  // Make HTTP GET request with timeout
  final response = await http.get(
    Uri.parse(_requestUrl!),
    headers: {'Accept': 'application/json'},
  ).timeout(const Duration(seconds: 10));
  
  // Parse JSON response
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final currentWeather = data['current_weather'];
    
    _temperature = currentWeather['temperature']?.toDouble();
    _windSpeed = currentWeather['windspeed']?.toDouble();
    _weatherCode = currentWeather['weathercode']?.toInt();
    _lastUpdated = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    // Save to cache
    await _saveToCache();
  }
}
```

### 3. **Caching Mechanism**
```dart
// Save to SharedPreferences
Future<void> _saveToCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('index', _indexController.text);
  await prefs.setDouble('temperature', _temperature!);
  await prefs.setDouble('windSpeed', _windSpeed!);
  await prefs.setInt('weatherCode', _weatherCode!);
  await prefs.setString('lastUpdated', _lastUpdated!);
}

// Load from cache on startup or when offline
Future<void> _loadCachedData() async {
  final prefs = await SharedPreferences.getInstance();
  
  if (prefs.containsKey('temperature')) {
    _temperature = prefs.getDouble('temperature');
    _windSpeed = prefs.getDouble('windSpeed');
    _weatherCode = prefs.getInt('weatherCode');
    _isCached = true;  // Show "(cached)" tag
  }
}
```

### 4. **Error Handling**
- Network timeout after 10 seconds
- Invalid index format validation
- API response status code checking
- Fallback to cached data on network error
- User-friendly error messages displayed in red card

---

## 🎨 UI Components

### Cards Used:
1. **Student Index Card** (White)
   - Text input field with validation
   
2. **Coordinates Card** (Blue)
   - Displays calculated lat/lon with icons
   
3. **Fetch Button**
   - Loading indicator when active
   - Disabled during fetch operation
   
4. **Error Card** (Red)
   - Shows friendly error messages
   - Only visible when errors occur
   
5. **Weather Data Card** (Green)
   - Temperature with thermometer icon
   - Wind speed with air icon
   - Weather code with code icon
   - Last updated timestamp
   - "(cached)" tag when showing offline data
   
6. **Request URL Card** (Grey)
   - Small monospace font
   - Selectable text for copying

---

## 📊 Testing Scenarios

### 1. **Online Mode - Fresh Fetch**
- Enter index → Tap "Fetch Weather"
- See loading indicator
- Display live weather data
- Show request URL
- Cache data automatically

### 2. **Offline Mode - Cached Data**
- Turn on Airplane Mode
- Tap "Fetch Weather"
- See network error message
- Display last cached data with "(cached)" tag

### 3. **Invalid Input**
- Enter index with < 4 digits
- See error: "Index must be at least 4 characters long"
- Enter non-numeric characters
- See error: "Invalid index format"

---

## 🚀 How to Run

### Prerequisites:
- Flutter SDK installed
- Android emulator or physical device
- Internet connection (for first fetch)

### Commands:
```bash
# Navigate to project directory
cd project_224143t

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📦 Deliverables Checklist

### ✅ Code Implementation
- [x] Student index input
- [x] Coordinate calculation and display
- [x] Open-Meteo API integration
- [x] Temperature, wind speed, weather code display
- [x] Request URL visible on screen
- [x] Loading indicator
- [x] Error handling
- [x] Offline caching with SharedPreferences
- [x] "(cached)" tag for offline data

### ✅ UI/UX Features
- [x] Clean, readable layout
- [x] Proper labels for all data
- [x] Icons for visual clarity
- [x] Color-coded cards
- [x] Material Design 3

### 📄 For Report (report_224143.pdf):
- Index: **224143**
- Formula: 
  - `lat = 5 + (22 / 10.0) = 7.20`
  - `lon = 79 + (41 / 10.0) = 83.10`
- Screenshots: Take screenshots showing:
  1. Index input and coordinates
  2. Weather data with request URL visible
  3. Cached data with "(cached)" tag

### 🎥 For Video (video_224143.mp4):
1. Type/confirm index
2. Tap "Fetch Weather"
3. Show live weather result with URL
4. Enable Airplane Mode
5. Tap "Fetch Weather" again
6. Show error + cached data

---

## 📝 Reflection Points (for report)

**What I Learned:**
1. How to integrate REST APIs in Flutter using the `http` package
2. Implementing offline-first architecture with local caching
3. Proper error handling for network requests
4. Deriving geographic coordinates from numeric patterns
5. Building responsive UI with Material Design 3

**Issues Faced:**
1. Understanding Open-Meteo API response structure
2. Handling null safety in Dart for optional data
3. Implementing proper state management for loading/error states
4. Testing offline scenarios with cached data

**Solutions:**
1. Used JSON parsing with null-aware operators (`?.`)
2. Implemented comprehensive error handling with try-catch
3. Created separate state variables for loading, error, and cached states
4. Used SharedPreferences for persistent local storage

---

## 🔍 Sample API Request

**For Index: 224143**

URL:
```
https://api.open-meteo.com/v1/forecast?latitude=7.2&longitude=83.1&current_weather=true
```

**Sample Response:**
```json
{
  "current_weather": {
    "temperature": 27.5,
    "windspeed": 12.3,
    "weathercode": 3,
    "time": "2025-11-05T14:30"
  }
}
```

---

## 🎓 Marking Criteria Coverage

| Area | Points | Status |
|------|--------|--------|
| Correct index→coords & shown in UI | 15 | ✅ Complete |
| Working API call & JSON parsing | 25 | ✅ Complete |
| Loading, error handling, offline cache | 25 | ✅ Complete |
| Clean UI (labels, layout, readability) | 15 | ✅ Complete |
| Report (clear + screenshots + URL) | 10 | 📝 Ready for creation |
| Video demo (≤60s, online + cached) | 10 | 🎥 Ready for recording |

---

## 📱 App Screenshots Guide

**Screenshot 1: Initial State**
- Shows student index input
- Displays calculated coordinates

**Screenshot 2: Live Weather Data**
- Temperature, wind speed, weather code
- Request URL visible at bottom
- Last updated timestamp

**Screenshot 3: Offline/Cached State**
- Same data with "(cached)" orange tag
- Error message showing network issue

---

## 🛠️ Technologies Used

- **Flutter 3.9.0+** - Cross-platform mobile framework
- **Dart 3.9.0+** - Programming language
- **http 1.1.0** - HTTP client for API calls
- **shared_preferences 2.2.2** - Local data persistence
- **intl 0.19.0** - Date/time formatting
- **Material Design 3** - UI design system

---

## 📞 Support & Documentation

- Open-Meteo API Docs: https://open-meteo.com/en/docs
- Flutter HTTP Package: https://pub.dev/packages/http
- SharedPreferences: https://pub.dev/packages/shared_preferences

---

**Student Index:** 224143  
**Course:** IN 3510 - Wireless Communication & Mobile Networks  
**Platform:** Android  
**Date:** November 2025
