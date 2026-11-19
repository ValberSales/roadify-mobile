import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/features/gravacao/services/sensor_trace_buffer.dart';

void main() {
  test('keeps a fixed-size chronological window after wrapping', () {
    final buffer = SensorTraceBuffer();

    for (var sample = 1; sample <= SensorTraceBuffer.capacity + 2; sample++) {
      buffer.add(sample.toDouble(), sample * 2.0, sample * 3.0);
    }

    expect(buffer.xSamples, hasLength(SensorTraceBuffer.capacity));
    expect(buffer.xSamples.first, 3);
    expect(buffer.xSamples.last, SensorTraceBuffer.capacity + 2);
    expect(buffer.ySamples.first, 6);
    expect(buffer.zSamples.last, (SensorTraceBuffer.capacity + 2) * 3.0);
  });
}
