import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

class Fund {
  Fund({
    required this.amount,
    required this.date,
  }) : id = uuid.v4();

  final String id;
  final double amount;
  final DateTime date;

  get formattedDate {
    return formatter.format(date);
  }
}

class FundBucket {
  const FundBucket({
    required this.funds,
  });

  final List<Fund> funds;

  double get totalfunds {
    double sum = 0;

    for (final fund in funds) {
      sum += fund.amount;
    }
    return sum;
  }
}
