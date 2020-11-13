import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

List<Weather> weather = List();

showDialogWeather(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder(
        future: weatherReport(),
        builder: (context, snapshot) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[100],
            scrollable: true,
            title: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.blue)),
                  child: weather.length == 0
                      ? CircularProgressIndicator(
                    backgroundColor: Colors.cyan,
                    strokeWidth: 5,
                  )
                      :ListView.builder(
                    shrinkWrap: true,
                    itemCount: weather.length,
                    itemBuilder: (BuildContext context, int index) {
                      return
                        ListTile(
                          leading: Image.network(
                            'http://openweathermap.org/img/wn/${weather[index].weatherIcon}@2x.png',
                            fit: BoxFit.contain,
                            height: 32,
                          ),
                          title: Text('${DateFormat('EEEE').format(weather[index].date)} ${weather[index].date.hour}:00\n${weather[index].weatherDescription}\n${weather[index].tempMax}\nWIND ${weather[index].windSpeed}m/s'),
                        );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future weatherReport() async {
  WeatherStation weatherStation =
  new WeatherStation("996cc4f3b136aea607960591dd64e7a5");
  weather.clear();
  weather = await weatherStation.fiveDayForecast();


}