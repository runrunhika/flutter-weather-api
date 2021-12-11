import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_api_app/weather.dart';
import 'package:weather_api_app/zip_code.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  String? address = '-';
  String? subAddress = '';
  String? errorMessage;

  Weather? currentWeather;

  List<Weather>? hourlyWeather;

  List<Weather>? dailyWeath;

  List<String> weekDay = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(
            width: 200,
            child: TextField(
              //入力された値を確定ボタンを押したとき (value) に値が入る
              onSubmitted: (value) async {
                Map<String, String>? response = {};
                //郵便APIを叩く
                response = await ZipCode.searchAddressFromZipCode(value);

                //Error処理
                errorMessage = response!['message'];
                //address というKeyを持っている場合 (正常)、上書き
                if (response.containsKey('address')) {
                  address = response['address'];
                  subAddress = response['subAddress'];
                  //WeatherAPIを叩く
                  currentWeather = await Weather.getCurrentWeather(value);
                  Map<String, List<Weather>>? weatherForcast =
                      await Weather.getForcast(
                          //名前つきの引数にすることで、受け渡しを指定できる
                          lon: currentWeather!.lon!,
                          lat: currentWeather!.lat!);
                  hourlyWeather = weatherForcast!['hourly'];
                  dailyWeath = weatherForcast['daily'];
                }
                setState(() {});
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "郵便番号を入力"),
            ),
          ),
          Text(
            errorMessage == null ? '' : errorMessage.toString(),
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(
            height: 50,
          ),
          Text(
            address!,
            style: TextStyle(fontSize: 18),
          ),
          Text(
            subAddress!,
            style: TextStyle(fontSize: 25),
          ),
          Text(
            currentWeather == null ? '-' : currentWeather!.description!,
            style: TextStyle(fontSize: 25),
          ),
          Text(
            currentWeather == null ? '-' : '${currentWeather!.temp}°',
            style: TextStyle(fontSize: 80),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  currentWeather == null
                      ? '-'
                      : '最高:${currentWeather!.tempMax}°',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Text(
                currentWeather == null ? '-' : '最低:${currentWeather!.tempMin}°',
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          const Divider(
            height: 5,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: hourlyWeather == null
                ? Container()
                : Row(
                    ///*hourlyWeather.map : List hourlyWeatherの中の要素数分、繰り返し処理を行う
                    ///*(weather)に繰り返すたび、要素内の値が入る
                    /// ex) Weather.temp = 0番目の要素内の気温の値を取得できる
                    children: hourlyWeather!.map((weather) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8.0),
                        child: Column(
                          children: [
                            Text("${DateFormat('H').format(weather.time!)}時"),
                            Image.network(
                              'https://openweathermap.org/img/wn/${weather.icon}.png',
                              width: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "${weather.temp}°",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      );
                      //toList() : Column&Row　Widgetをどう的に表現できる
                    }).toList(),
                  ),
          ),
          const Divider(
            height: 5,
          ),
          //Expanded Padding以下の範囲にSingleChildScrollViewを付与するということを明確化
          dailyWeath == null
              ? Container()
              : Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                          //dailyWeath Listの中の値をweatherへ入れる
                          children: dailyWeath!.map((weather) {
                        return Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // *曜日と最高・最低気温のText WidgetにContainerをつけることにより、spaceBetweenが可能になる
                              Container(
                                  width: 50,
                                  child: Text(
                                      '${weekDay[weather.time!.weekday - 1]}曜日')),
                              Row(
                                children: [
                                  //contsinerで挟んでUIを崩れないようにする
                                  Container(
                                    width: 35,
                                  ),
                                  Image.network(
                                    'https://openweathermap.org/img/wn/${weather.icon}.png',
                                    width: 30,
                                  ),
                                  Container(
                                    width: 35,
                                    child: Text(
                                      '${weather.rainyPercent!}％',
                                      style: TextStyle(
                                          color: Colors.lightBlueAccent),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${weather.tempMax}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      '${weather.tempMin}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black.withOpacity(.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList()),
                    ),
                  ),
                )
        ],
      )),
    );
  }
}
