class SensorTraceBuffer {
  static const int capacity = 60;

  final List<double> _x = List<double>.filled(capacity, 0);
  final List<double> _y = List<double>.filled(capacity, 0);
  final List<double> _z = List<double>.filled(capacity, 9.81);
  int _nextWriteIndex = 0;

  void add(double x, double y, double z) {
    _x[_nextWriteIndex] = x;
    _y[_nextWriteIndex] = y;
    _z[_nextWriteIndex] = z;
    _nextWriteIndex = (_nextWriteIndex + 1) % capacity;
  }

  List<double> get xSamples => _ordered(_x);

  List<double> get ySamples => _ordered(_y);

  List<double> get zSamples => _ordered(_z);

  List<double> _ordered(List<double> values) => List<double>.generate(
    capacity,
    (index) => values[(_nextWriteIndex + index) % capacity],
    growable: false,
  );
}
