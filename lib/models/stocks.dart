import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final format = DateFormat.yMd();

const uuid = Uuid();

class Stocks {
  Stocks({
    required this.shares,
    required this.date,
    required this.ticker,
    required this.currentPrice,
    required this.totalShares,
  });

  final String ticker;
  final double shares;
  final DateTime date;
  final double currentPrice;
  final double totalShares;

  get formattedDate {
    return format.format(date);
  }
}
