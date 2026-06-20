import 'dart:convert';

class HistoryItem {
  final String type; // 'sci' or 'matrix'
  final String expression; // e.g. "sin(30) = " or "[1, 2; 3, 4] + [1, 1; 1, 1] ="
  final String result; // formatted result string
  final double? numericResult; // raw double result for retrieval
  final int timestamp; // epoch time

  HistoryItem({
    required this.type,
    required this.expression,
    required this.result,
    this.numericResult,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'expression': expression,
      'result': result,
      'numericResult': numericResult,
      'timestamp': timestamp,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      type: map['type'] ?? 'sci',
      expression: map['expression'] ?? '',
      result: map['result'] ?? '',
      numericResult: map['numericResult'] != null ? (map['numericResult'] as num).toDouble() : null,
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryItem.fromJson(String source) => HistoryItem.fromMap(json.decode(source));
}
