import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/bitly_click_summary_model.dart';
import '../model/bitly_shorten_model.dart';
import '../PRIVATE.dart';

const authority = 'https://api-ssl.bitly.com/v4';

class BitlyApi {
  static Future<BitlyShortenModel> shorten({String url}) async {
    var _jsonBody = {
      "long_url": url,
      "domain": "bit.ly",
      "group_guid": "Bl4628jEmC1"
    };
    var apiResponse = await Dio().post('$authority/shorten',
        options: Options(
          headers: {
            'Authorization': 'Bearer $kBitlyApiToken',
            Headers.contentTypeHeader: Headers.jsonContentType
          },
        ),
        data: _jsonBody);

    switch (apiResponse.statusCode) {
      case HttpStatus.ok:
      case HttpStatus.created:
        return BitlyShortenModel.fromJson(json.decode(apiResponse.toString()));
        break;
      default:
        String errMessage =
            'Error: ${apiResponse.statusCode}: ${apiResponse.statusMessage}';
        Fluttertoast.showToast(msg: errMessage);
        throw errMessage;
    }
  }

  static Future<BitlyClickSummaryModel> clickSummary({String url}) async {
    var apiResponse = await Dio().get('$authority/bitlinks/$url/clicks/summary',
        options: Options(headers: {'Authorization': 'Bearer $kBitlyApiToken'}));
    switch (apiResponse.statusCode) {
      case HttpStatus.ok:
        return BitlyClickSummaryModel.fromJson(
            json.decode(apiResponse.toString()));
        break;
      default:
        var errMessage =
            'Error: ${apiResponse.statusCode}: ${apiResponse.statusMessage}';
        Fluttertoast.showToast(msg: errMessage);
        throw errMessage;
    }
  }
}
