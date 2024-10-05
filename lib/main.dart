import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherFactory wf = WeatherFactory("25ea4ddc425fd290784d241f12f46d46");
  Weather? weather;
  final TextEditingController _controller = TextEditingController();

  Future<void> getWeather(String cityName) async {
    try {
      Weather data = await wf.currentWeatherByCityName(cityName);
      setState(() {
        weather = data;
      });
      FocusScope.of(context).unfocus(); // Keyboard ko hide karein
    } catch (e) {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
              'City not found. Please enter a valid city name. If you enter valid city name then Check internet connection... '),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog ko band karein
                _controller.clear(); // Text field ko clear karein
              },
              child: Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime); // Only date format
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime); // Only time format
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return CupertinoIcons.cloud;

    switch (condition.toLowerCase()) {
      case 'clear':
        return CupertinoIcons.sun_max;
      case 'rain':
        return CupertinoIcons.cloud_rain;
      case 'cloudy':
        return CupertinoIcons.cloud;
      case 'storm':
        return CupertinoIcons.cloud_bolt;
      default:
        return CupertinoIcons.cloud;
    }
  }

  Color _getTemperatureColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp < 12) {
      return Colors.blue;
    } else if (temp >= 12 && temp <= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getWeatherConditionColor(String? condition) {
    if (condition == null)
      return Colors.grey; // Agar condition na ho to grey color
    switch (condition.toLowerCase()) {
      case 'clear sky':
        return Colors.yellow; // Clear weather ke liye yellow color
      case 'shower rain':
        return Colors.blue; // Rainy weather ke liye blue color
      case 'cloudy':
        return Colors.grey; // Cloudy weather ke liye grey color
      case 'storm':
        return Colors.deepPurple; // Stormy weather ke liye deep purple color
      default:
        return Colors.grey; // Default color for unknown condition
    }
  }

  Color _getHumidityColor(double? humidity) {
    if (humidity == null) return Colors.grey;
    if (humidity < 30) {
      return Colors.red; // Low humidity ke liye red color
    } else if (humidity >= 30 && humidity < 60) {
      return Colors.orange; // Moderate humidity ke liye orange color
    } else {
      return Colors.blue; // High humidity ke liye blue color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Weather Information')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter city name',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Colors.blue), // Correct way to set background color
              ),
              onPressed: () {
                String cityName = _controller.text;
                if (cityName.isNotEmpty) {
                  getWeather(cityName);
                }
              },
              child: Text('Get Weather',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            SizedBox(height: 10),
            Expanded(
              child: weather == null
                  ? Text('Enter a city to get weather information.')
                  : ListView(
                      children: [
                        Center(
                          child: ListTile(
                            leading: Icon(CupertinoIcons.time,
                                color: Colors.blueGrey),
                            title: Text(
                              'Current Time: ${formatTime(DateTime.now())}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(
                            CupertinoIcons.globe,
                            color: Colors.blue,
                          ),
                          title: Text(
                            'Country:- ${weather!.country ?? 'N/A'}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ListTile(
                          leading:
                              Icon(CupertinoIcons.location, color: Colors.red),
                          title: Text('City:- ${weather!.areaName}',
                              style: TextStyle(fontSize: 20)),
                        ),
                        ListTile(
                          leading: Icon(CupertinoIcons.thermometer,
                              color: _getTemperatureColor(
                                  weather!.temperature?.celsius)),
                          title: Text(
                              'Temperature:- ${weather!.temperature?.celsius?.toStringAsFixed(1) ?? 'N/A'} °C',
                              style: TextStyle(fontSize: 20)),
                        ),
                        ListTile(
                          leading: Icon(
                            _getWeatherIcon(weather!.weatherDescription),
                            color: _getWeatherConditionColor(
                                weather!.weatherDescription),
                          ),
                          title: Text(
                              'Weather:- ${weather!.weatherDescription}',
                              style: TextStyle(fontSize: 20)),
                        ),
                        ListTile(
                          leading: Icon(
                            CupertinoIcons.drop,
                            color: _getHumidityColor(weather!.humidity),
                          ),
                          title: Text(
                            'Humidity:- ${weather!.humidity ?? 'N/A'}%',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            CupertinoIcons.sunrise,
                            color: Colors.orange,
                          ),
                          title: Text(
                            'Sunrise: ${weather!.sunrise != null ? formatTime(weather!.sunrise!.toLocal()) : 'N/A'}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            CupertinoIcons.sunset,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Sunset: ${weather!.sunset != null ? formatTime(weather!.sunset!.toLocal()) : 'N/A'}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ListTile(
                          leading:
                              Icon(CupertinoIcons.calendar, color: Colors.blue),
                          title: Text(
                            'Date: ${weather!.sunset != null ? formatDate(weather!.sunset!.toLocal()) : 'N/A'}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
