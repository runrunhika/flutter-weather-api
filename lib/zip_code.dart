import 'dart:convert';

import 'package:http/http.dart';

class ZipCode {
  //Future : 時間のかかる処理
  static Future<Map<String, String>?> searchAddressFromZipCode(
      String zipCode) async {
    String url = 'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode';
    try {
      //urlを取得
      var result = await get(Uri.parse(url));

      ///urlで取得するデータはJson型なので
      ///Json型をMap型に変換する
      ///(result.body)をMap型にする
      Map<String, dynamic> data = jsonDecode(result.body);
      Map<String, String>? response = {};
      /* Error処理 */
      //郵便番号が7桁ではないとき
      if (data['message'] != null) {
        //response['message'] = data['message']; //デフォルトのErrorメッセージ
        response['message'] = '郵便番号の桁数が不正です';
      } else {
        //郵便番号が7桁で、正しくないとき
        if (data['results'] == null) {
          response['message'] = '正しい郵便番号を入力してください';
        }
        /* 正常 */
        else {
          ///PostMan より
          ///results
          ///＜ [{ ここだよ！ },{}...] (1番目の要素)
          ///＜ address2 の値をaddressに取得
          response['address'] = data['results'][0]['address1'];

          response['subAddress'] =
              data['results'][0]['address2'] + data['results'][0]['address3'];
        }
      }
      return response;
    } catch (e) {
      print(e);
    }
  }
}
/*
  Postman.com　＜　HttpRequestより
    https://zipcloud.ibsnet.co.jp/api/search?zipcode=7830060

  URLの取得結果 (Json)
  {
	"message": null,
	"results": [
		{
			"address1": "高知県",
			"address2": "南国市",
			"address3": "蛍が丘",
			"kana1": "ｺｳﾁｹﾝ",
			"kana2": "ﾅﾝｺｸｼ",
			"kana3": "ﾎﾀﾙｶﾞｵｶ",
			"prefcode": "39",
			"zipcode": "7830060"
		}
	],
	"status": 200
}
*/
