import 'package:weather/weather.dart';

WeatherStation weatherStation =
new WeatherStation("996cc4f3b136aea607960591dd64e7a5");

Future weatherGet() async {
  Weather weather = (await weatherStation.currentWeather());
  String weatherToday = "MyThreads";
  if ('${weather.weatherMain}' != null &&
      '${weather.tempMin.celsius.round()}' != null &&
      '${weather.tempMax.celsius.round()}' != null) {
    weatherToday =
    '${weather.weatherMain} ${weather.tempMin.celsius.round()}°C/${weather.tempMax.celsius.round()}°C';
  }
  String weatherIcon = '';
  if ('${weather.weatherIcon}' != null) {
    weatherIcon = weather.weatherIcon;
  }
  List<String> weatherList = [weatherToday, weatherIcon];
  return weatherList;
}