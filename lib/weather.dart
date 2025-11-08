import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = true;

  String _status = "Loading...";
  String _temp = "--";
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _fetchWeather(showLoading: true);
  }

  Future<String> _getCityFromLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS disabled");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception("Permission denied");
      }

      final pos = await Geolocator.getCurrentPosition();

      // Reverse geocode using OpenWeatherMap API
      final geoUrl =
          "https://api.openweathermap.org/geo/1.0/reverse?lat=${pos.latitude}&lon=${pos.longitude}&limit=1&appid=${_weatherService.apiKey}";
      final geoRes = await http.get(Uri.parse(geoUrl));

      if (geoRes.statusCode == 200) {
        final data = json.decode(geoRes.body);
        if (data.isNotEmpty && data[0]["name"] != null) {
          return data[0]["name"];
        }
      }

      throw Exception("Failed to get city");
    } catch (_) {
      // Fallback via IP geolocation
      final ipRes = await http.get(Uri.parse("http://ip-api.com/json/"));
      if (ipRes.statusCode == 200) {
        final data = json.decode(ipRes.body);
        return data["city"] ?? "Manila";
      } else {
        return "Manila";
      }
    }
  }

  String _simplifyCondition(String condition) {
    final c = condition.toLowerCase();
    if (c.contains("rain")) return "Rainy";
    if (c.contains("cloud")) return "Cloudy";
    if (c.contains("sun") || c.contains("clear")) return "Sunny";
    if (c.contains("storm") || c.contains("thunder")) return "Stormy";
    if (c.contains("snow")) return "Snowy";
    if (c.contains("fog") || c.contains("mist")) return "Foggy";
    return "Unknown";
  }

  Future<void> _fetchWeather({bool showLoading = false}) async {
    if (showLoading) setState(() => _isLoading = true);

    try {
      final city = await _getCityFromLocation();
      final weather = await _weatherService.fetchWeather(city);

      setState(() {
        _status = _simplifyCondition(weather.description);
        _temp = "${weather.temperature.toStringAsFixed(1)}°C";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = "Error loading weather";
        _temp = "--";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        Container(
          color: Colors.blue,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Text(
            "${_focusedDay.month.toString().padLeft(2, '0')}/${_focusedDay.year}",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchWeather(); // refreshes weather for same city
              },
              headerVisible: false,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          color: Colors.blue,
          padding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Forecast:\n$_status",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _temp,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
