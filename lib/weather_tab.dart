import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final String country;
  final String lastUpdated;
  final double tempC;
  final double tempF;
  final double feelsLikeC;
  final double feelsLikeF;
  final double windKph;
  final double windMph;
  final int humidity;
  final int uv;
  final Condition condition;

  WeatherData({
    required this.city,
    required this.country,
    required this.lastUpdated,
    required this.tempC,
    required this.tempF,
    required this.feelsLikeC,
    required this.feelsLikeF,
    required this.windKph,
    required this.windMph,
    required this.humidity,
    required this.uv,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['city'],
      country: json['country'],
      lastUpdated: json['lastUpdated'],
      tempC: json['tempC'].toDouble(),
      tempF: json['tempF'].toDouble(),
      feelsLikeC: json['feelsLikeC'].toDouble(),
      feelsLikeF: json['feelsLikeF'].toDouble(),
      windKph: json['windKph'].toDouble(),
      windMph: json['windMph'].toDouble(),
      humidity: json['humidity'],
      uv: json['uv'],
      condition: Condition.fromJson(json['condition']),
    );
  }
}

class Condition {
  final String text;
  final String icon;
  final int code;

  Condition({
    required this.text,
    required this.icon,
    required this.code,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      text: json['text'],
      icon: json['icon'],
      code: json['code'],
    );
  }
}

class WeatherTab extends StatefulWidget {
  final String city;

  const WeatherTab({
    Key? key,
    required this.city,
  }) : super(key: key);

  @override
  _WeatherTabState createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  Future<WeatherData?> fetchWeatherData() async {
    final response = await http.get(Uri.parse(
        'https://cpsu-test-api.herokuapp.com/api/1_2566/weather/current?city=${widget.city}'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return WeatherData.fromJson(jsonData);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(
          255, 210, 231, 248),
      child: FutureBuilder<WeatherData?>(
        future: fetchWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final weatherData = snapshot.data!;
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.center, // Center text horizontally
                    children: [
                      Text(
                        '${weatherData.city}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${weatherData.lastUpdated}',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      Image.network(weatherData.condition.icon),
                      Text(
                        '${weatherData.condition.text}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        '${weatherData.tempC.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 48.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Feel like ${weatherData.feelsLikeC.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Wind'),
                          Text(
                              '${weatherData.windKph.toStringAsFixed(1)} km/h'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Humidity'),
                          Text('${weatherData.humidity}%'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('UV Index'),
                          Text('${weatherData.uv}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}