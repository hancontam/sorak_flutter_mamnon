/// One WHO reference curve point from GET /health-assessments/who-curves.
/// Shape: { month, sd3neg, sd2neg, median, sd2, sd3 }
class WhoCurvePoint {
  const WhoCurvePoint({
    required this.month,
    required this.sd3neg,
    required this.sd2neg,
    required this.median,
    required this.sd2,
    required this.sd3,
  });

  final int month;
  final double sd3neg;
  final double sd2neg;
  final double median;
  final double sd2;
  final double sd3;

  factory WhoCurvePoint.fromJson(Map<String, dynamic> json) {
    return WhoCurvePoint(
      month: _readInt(json['month']),
      sd3neg: _readDouble(json['sd3neg']),
      sd2neg: _readDouble(json['sd2neg']),
      median: _readDouble(json['median']),
      sd2: _readDouble(json['sd2']),
      sd3: _readDouble(json['sd3']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }
}
