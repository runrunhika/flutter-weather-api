import 'dart:convert';

import 'package:http/http.dart';
import 'package:intl/date_time_patterns.dart';

class Weather {
  int? temp; //気温
  int? tempMax; //最高気温
  int? tempMin; //最低気温
  String? description; //天気状態
  double? lon; //経度
  double? lat; //緯度
  String? icon; //天気情報のアイコン画像
  DateTime? time; //日時
  int? rainyPercent; //降水確率
  Weather({
    this.temp,
    this.tempMax,
    this.tempMin,
    this.description,
    this.lon,
    this.lat,
    this.icon,
    this.time,
    this.rainyPercent,
  });

  static String publicParameter =
      '&appid=fa921e9392b821e5a75eb1a6331f054d&lang=ja&units=metric';

  static Future<Weather?> getCurrentWeather(String zipCode) async {
    String _zipCode;
    //受け取ったzipCodeにハイフン'-'を含む場合
    //contains 文字(今回は、ハイフン'-')を探す
    if (zipCode.contains('-')) {
      _zipCode = zipCode;
    } else {
      //substring(0, 3) : 0〜3番目の文字以降にハイフン'-'を付与
      _zipCode = zipCode.substring(0, 3) + '-' + zipCode.substring(3);
    }
    String url =
        'https://api.openweathermap.org/data/2.5/weather?zip=$_zipCode,JP$publicParameter';
    try {
      /* 以下詳細は zip_code.dart で確認 */
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      // print(data);
      Weather currentWeather = Weather(
          description: data['weather'][0]['description'],
          //気温は double型なので toInt() でInt型に変化
          temp: data['main']['temp'].toInt(),
          tempMax: data['main']['temp_max'].toInt(),
          tempMin: data['main']['temp_min'].toInt(),
          lon: data['coord']['lon'],
          lat: data['coord']['lat']);
      return currentWeather;
    } catch (e) {
      print(e);
    }
  }

  // ({名前つきの引数にする})
  static Future<Map<String, List<Weather>>?> getForcast(
      {required double lon, required double lat}) async {
    Map<String, List<Weather>> response = {};

    String url =
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely$publicParameter';
    try {
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      //hourlyはList型
      List<dynamic> hourlyWeatherData = data['hourly'];
      List<dynamic> dailyWeatherData = data['daily'];
      List<Weather> hourlyWeather = hourlyWeatherData.map((weather) {
        return Weather(
            //ユニックスタイム　13桁必要
            time: DateTime.fromMillisecondsSinceEpoch(weather['dt'] * 1000),
            temp: weather['temp'].toInt(),
            icon: weather['weather'][0]['icon']);
      }).toList();
      List<Weather> dailyWeather = dailyWeatherData.map((weather) {
        return Weather(
            time: DateTime.fromMillisecondsSinceEpoch(weather['dt'] * 1000),
            icon: weather['weather'][0]['icon'],
            tempMax: weather['temp']['max'].toInt(),
            tempMin: weather['temp']['min'].toInt(),
            //降水確率が0の時は、Jsonデータにないから、ない場合は　0 を表示させる
            rainyPercent:
                weather.containsKey('rain') ? weather['rain'].toInt() : 0);
      }).toList();

      print(dailyWeather[0].rainyPercent);
      response['hourly'] = hourlyWeather;
      response['daily'] = dailyWeather;
      return response;
    } catch (e) {
      print(e);
    }
  }
}

/*
  Postman.com　＜　HttpRequestより
  getCurrentWeatherで使用
    https://api.openweathermap.org/data/2.5/weather?zip=737-0811,JP&appid=fa921e9392b821e5a75eb1a6331f054d&lang=ja&utils=metric

  URLの取得結果 (Json)
  {
    "coord": {
        "lon": 132.5599,
        "lat": 34.2489
    },
    "weather": [
        {
            "id": 800,
            "main": "Clear",
            "description": "晴天",
            "icon": "01n"
        }
    ],
    "base": "stations",
    "main": {
        "temp": 283.3,
        "feels_like": 282.38,
        "temp_min": 282.09,
        "temp_max": 283.99,
        "pressure": 1024,
        "humidity": 77,
        "sea_level": 1024,
        "grnd_level": 1023
    },
    "visibility": 10000,
    "wind": {
        "speed": 2.07,
        "deg": 31,
        "gust": 2.03
    },
    "clouds": {
        "all": 1
    },
    "dt": 1639156652,
    "sys": {
        "type": 2,
        "id": 20483,
        "country": "JP",
        "sunrise": 1639173936,
        "sunset": 1639209625
    },
    "timezone": 32400,
    "id": 0,
    "name": "Nishichuuou",
    "cod": 200
}
--------------------------------------
    getHourlyWeatherで使用
      https://api.openweathermap.org/data/2.5/onecall?lat=35.6355&lon=139.3316&appid=fa921e9392b821e5a75eb1a6331f054d&lang=ja&utils=metric&exclude=minutely

  {
    "lat": 35.6355,
    "lon": 139.3316,
    "timezone": "Asia/Tokyo",
    "timezone_offset": 32400,
    "hourly": [
        {
            "dt": 1639155600,
            "temp": 277.2,
            "weather": [
                {
                    "id": 800,
                    "main": "Clear",
                    "description": "晴天",
                    "icon": "01n"
                }
            ],
            "pop": 0
        },
        {
            "dt": 1639159200,
            "temp": 276.5,
            "weather": [
                {
                    "id": 800,
                    "main": "Clear",
                    "description": "晴天",
                    "icon": "01n"
                }
            ],
            "pop": 0
        },
      ].
  }
*/