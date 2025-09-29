import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  DateTime _today = DateTime.now();
  bool _isLoading = true;

  Map<String, dynamic> _todayWeather = {"status": "No Data", "temp": "--"};

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Step 1: Get location from IP
      final ipRes = await http.get(Uri.parse("http://ip-api.com/json/"));
      double lat = 14.5995; // fallback Manila
      double lon = 120.9842;

      if (ipRes.statusCode == 200) {
        final data = json.decode(ipRes.body);
        lat = (data["lat"] as num).toDouble();
        lon = (data["lon"] as num).toDouble();
      }

      // Step 2: Fetch only today’s forecast
      final url =
          "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto";
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final forecast = json.decode(res.body);
        final daily = forecast["daily"];

        final dates = List<String>.from(daily["time"]);
        final maxTemps = List<num>.from(daily["temperature_2m_max"]);
        final minTemps = List<num>.from(daily["temperature_2m_min"]);
        final codes = List<num>.from(daily["weathercode"]);

        // Find today’s entry
        final todayString =
            "${_today.year.toString().padLeft(4, '0')}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}";
        final idx = dates.indexOf(todayString);

        if (idx != -1) {
          final avgTemp = ((minTemps[idx] + maxTemps[idx]) / 2).round();
          setState(() {
            _todayWeather = {
              "status": _mapWeatherCode(codes[idx]),
              "temp": "$avgTemp°C",
            };
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _mapWeatherCode(num code) {
    if (code == 0) return "Clear";
    if ([1, 2, 3].contains(code)) return "Partly Cloudy";
    if ([45, 48].contains(code)) return "Foggy";
    if ([51, 53, 55].contains(code)) return "Drizzle";
    if ([61, 63, 65].contains(code)) return "Rain";
    if ([71, 73, 75].contains(code)) return "Snow";
    if ([95].contains(code)) return "Thunderstorm";
    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        // Custom Header
        Container(
          color: Colors.blue,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Text(
            "${_today.month.toString().padLeft(2, '0')}/${_today.year}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Calendar (disabled selection)
        Expanded(
          child: Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _today,
              selectedDayPredicate: (day) => isSameDay(day, _today),
              onDaySelected: (_, __) {}, // disable selection
              headerVisible: false,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        // Weather Info
        Container(
          width: double.infinity,
          color: Colors.blue,
          padding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Predicted Status
              Text(
                "Predicted:\n${_todayWeather["status"]}",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Temperature (Avg)
              Text(
                _todayWeather["temp"],
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
