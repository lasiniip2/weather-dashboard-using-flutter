import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  // Controllers and state variables
  final TextEditingController _indexController = TextEditingController(
    text: '224143',
  );

  double? _latitude;
  double? _longitude;
  String? _requestUrl;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isCached = false;

  // Weather data
  double? _temperature;
  double? _windSpeed;
  int? _weatherCode;
  String? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  // Calculate coordinates from student index
  void _calculateCoordinates() {
    String index = _indexController.text.trim();

    if (index.length < 4) {
      setState(() {
        _errorMessage = 'Index must be at least 4 characters long';
        _latitude = null;
        _longitude = null;
      });
      return;
    }

    try {
      // Extract first two and next two digits
      int firstTwo = int.parse(index.substring(0, 2));
      int nextTwo = int.parse(index.substring(2, 4));

      // Calculate coordinates using the formula
      _latitude = 5.0 + (firstTwo / 10.0);
      _longitude = 79.0 + (nextTwo / 10.0);

      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Invalid index format. First 4 characters must be digits.';
        _latitude = null;
        _longitude = null;
      });
    }
  }

  // Fetch weather data from Open-Meteo API
  Future<void> _fetchWeather() async {
    _calculateCoordinates();

    if (_latitude == null || _longitude == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isCached = false;
    });

    // Build the API request URL
    _requestUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=${_latitude!.toStringAsFixed(1)}&longitude=${_longitude!.toStringAsFixed(1)}&current_weather=true';

    try {
      final response = await http
          .get(Uri.parse(_requestUrl!), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currentWeather = data['current_weather'];

        setState(() {
          _temperature = currentWeather['temperature']?.toDouble();
          _windSpeed = currentWeather['windspeed']?.toDouble();
          _weatherCode = currentWeather['weathercode']?.toInt();
          _lastUpdated = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.now());
          _isLoading = false;
          _errorMessage = null;
        });

        // Save to cache
        await _saveToCache();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to fetch weather. Status: ${response.statusCode}';
        });

        // Try to load cached data
        await _loadCachedData();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error: ${e.toString()}';
      });

      // Try to load cached data
      await _loadCachedData();
    }
  }

  // Save weather data to local cache
  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('index', _indexController.text);
    await prefs.setDouble('latitude', _latitude!);
    await prefs.setDouble('longitude', _longitude!);
    await prefs.setDouble('temperature', _temperature!);
    await prefs.setDouble('windSpeed', _windSpeed!);
    await prefs.setInt('weatherCode', _weatherCode!);
    await prefs.setString('lastUpdated', _lastUpdated!);
    await prefs.setString('requestUrl', _requestUrl!);
  }

  // Load cached weather data
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('temperature')) {
      setState(() {
        _indexController.text = prefs.getString('index') ?? '';
        _latitude = prefs.getDouble('latitude');
        _longitude = prefs.getDouble('longitude');
        _temperature = prefs.getDouble('temperature');
        _windSpeed = prefs.getDouble('windSpeed');
        _weatherCode = prefs.getInt('weatherCode');
        _lastUpdated = prefs.getString('lastUpdated');
        _requestUrl = prefs.getString('requestUrl');
        _isCached = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Index Input
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Index',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _indexController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your index (e.g., 224143B)',
                        hintText: '224143B',
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Coordinates Display
            if (_latitude != null && _longitude != null)
              Card(
                elevation: 4,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculated Coordinates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue),
                              const SizedBox(height: 4),
                              const Text('Latitude'),
                              Text(
                                _latitude!.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 4),
                              const Text('Longitude'),
                              Text(
                                _longitude!.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Fetch Weather Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchWeather,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_download),
              label: Text(_isLoading ? 'Fetching...' : 'Fetch Weather'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 16),

            // Error Message
            if (_errorMessage != null)
              Card(
                elevation: 4,
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Weather Data Display
            if (_temperature != null)
              Card(
                elevation: 4,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weather Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isCached)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '(cached)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Temperature
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            size: 40,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Temperature'),
                              Text(
                                '${_temperature!.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Wind Speed
                      Row(
                        children: [
                          const Icon(Icons.air, size: 40, color: Colors.blue),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Wind Speed'),
                              Text(
                                '${_windSpeed!.toStringAsFixed(1)} km/h',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Weather Code
                      Row(
                        children: [
                          const Icon(
                            Icons.code,
                            size: 40,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Weather Code'),
                              Text(
                                _weatherCode.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Last Updated
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Last Updated: $_lastUpdated',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Request URL Display
            if (_requestUrl != null)
              Card(
                elevation: 4,
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Request URL:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _requestUrl!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _indexController.dispose();
    super.dispose();
  }
}
