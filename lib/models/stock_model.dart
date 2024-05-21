class Stock {
  final DateTime date;
  final double close;

  Stock({required this.date, required this.close});

  factory Stock.fromJson(Map<String, dynamic> json, String date) {
    return Stock(
      date: DateTime.parse(date),
      close: double.parse(json['4. close']),
    );
  }
}
