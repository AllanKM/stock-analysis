import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockService {
  final String _apiKey = dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? '';

  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final response = await http.get(Uri.parse(
        'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$_apiKey'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  List<Map<String, dynamic>> getLast7TradingDays(
      Map<String, dynamic> timeSeries) {
    List<Map<String, dynamic>> last7Days = [];
    timeSeries.entries.take(7).forEach((entry) {
      last7Days.add({'date': entry.key, 'close': entry.value['4. close']});
    });
    return last7Days;
  }
}
