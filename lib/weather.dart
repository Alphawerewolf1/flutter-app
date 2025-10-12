import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = true;

  Map<String, dynamic> _weather = {"status": "Loading...", "temp": "--"};

  final String _apiKey = "e3dcb7020205451fa5c52702250710"; // WeatherAPI key

  @override
  void initState() {
    super.initState();
    _fetchWeather(_selectedDay, showLoading: true);
  }

  Future<Map<String, double>> _getCoordinates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          throw Exception("Permission denied");
        }

        final pos = await Geolocator.getCurrentPosition();
        return {"lat": pos.latitude, "lon": pos.longitude};
      } else {
        throw Exception("GPS disabled");
      }
    } catch (_) {
      final ipRes = await http.get(Uri.parse("http://ip-api.com/json/"));
      if (ipRes.statusCode == 200) {
        final data = json.decode(ipRes.body);
        return {
          "lat": (data["lat"] as num).toDouble(),
          "lon": (data["lon"] as num).toDouble()
        };
      } else {
        return {"lat": 14.5995, "lon": 120.9842}; // Manila fallback
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

  Future<void> _fetchWeather(DateTime date, {bool showLoading = false}) async {
    if (showLoading) setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      // WeatherAPI free tier: only supports past + up to 14 days forecast
      if (difference > 14) {
        setState(() {
          _weather = {
            "status": "No Forecast Available",
            "temp": "--"
          };
          _isLoading = false;
        });
        return;
      }

      final coords = await _getCoordinates();
      final lat = coords["lat"];
      final lon = coords["lon"];

      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final url =
          "https://api.weatherapi.com/v1/forecast.json?key=$_apiKey&q=$lat,$lon&dt=$dateString";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final forecast = data["forecast"]["forecastday"][0];
        final condition = forecast["day"]["condition"]["text"];
        final avgTemp = forecast["day"]["avgtemp_c"].toString();

        setState(() {
          _weather = {
            "status": _simplifyCondition(condition),
            "temp": "$avgTemp°C"
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _weather = {"status": "No Data", "temp": "--"};
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _weather = {"status": "Network Error", "temp": "--"};
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
                _fetchWeather(selectedDay); // instant update
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
                "Forecast:\n${_weather["status"]}",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _weather["temp"],
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
