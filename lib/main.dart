import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stock_analyzer/services/stock_service.dart';
import 'package:fl_chart/fl_chart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StockService _stockService = StockService();
  final List<String> _companies = [
    'AAPL',
    'IBM',
    'HPQ',
    'MSFT',
    'ORCL',
    'GOOGL',
    'META',
    'TWTR',
    'INTC',
    'AMZN'
  ];
  String? _selectedCompany1;
  String? _selectedCompany2;
  List<FlSpot> _company1Data = [];
  List<FlSpot> _company2Data = [];

  Future<void> _fetchData() async {
    if (_selectedCompany1 == null) return;

    var data1 = await _stockService.fetchStockData(_selectedCompany1!);
    var timeSeries1 = data1['Time Series (Daily)'] as Map<String, dynamic>;
    var last7Days1 = _stockService.getLast7TradingDays(timeSeries1);

    List<FlSpot> company1Spots = last7Days1.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), double.parse(entry.value['close']));
    }).toList();

    List<FlSpot> company2Spots = [];
    if (_selectedCompany2 != null) {
      var data2 = await _stockService.fetchStockData(_selectedCompany2!);
      var timeSeries2 = data2['Time Series (Daily)'] as Map<String, dynamic>;
      var last7Days2 = _stockService.getLast7TradingDays(timeSeries2);

      company2Spots = last7Days2.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), double.parse(entry.value['close']));
      }).toList();
    }

    setState(() {
      _company1Data = company1Spots;
      _company2Data = company2Spots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Analyzer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Company 1'),
              value: _selectedCompany1,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCompany1 = newValue;
                });
              },
              items: _companies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              hint: Text('Select Company 2'),
              value: _selectedCompany2,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCompany2 = newValue;
                });
              },
              items: _companies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('Show Stock Data'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _company1Data,
                        isCurved: true,
                        color: Colors.blue, // Use color instead of colors
                        barWidth: 4,
                        belowBarData: BarAreaData(show: false),
                      ),
                      if (_selectedCompany2 != null)
                        LineChartBarData(
                          spots: _company2Data,
                          isCurved: true,
                          color: Colors.red, // Use color instead of colors
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                        ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toString());
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            final date = DateTime.now()
                                .subtract(Duration(days: 6 - index));
                            return Text(
                              '${date.month}/${date.day}',
                              style: TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
