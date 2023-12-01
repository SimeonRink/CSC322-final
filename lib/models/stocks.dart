import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final format = DateFormat.yMd();

const uuid = Uuid();

class Stocks {
  Stocks({
    required this.shares,
    required this.date,
    required this.ticker,
  });

  final String ticker;
  final int shares;
  final DateTime date;

  get formattedDate {
    return format.format(date);
  }
}
