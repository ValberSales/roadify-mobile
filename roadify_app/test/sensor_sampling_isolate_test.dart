import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:roadify_app/features/gravacao/services/recording_repository.dart';
import 'package:roadify_app/features/gravacao/services/sensor_sampling_isolate.dart';

void main() {
  test('preserves a 200 Hz batch and flushes it before shutdown', () async {
    final samples = <RecordedSensorSample>[];
    final errors = <Object>[];
    final batchReceived = Completer<void>();
    final sampler = SensorSamplingIsolate(
      batchInterval: const Duration(milliseconds: 50),
    );

    await sampler.start(
      startedAtUtc: DateTime.utc(2026, 11, 18),
      onBatch: (batch) {
        samples.addAll(batch);
        if (samples.length == 200 && !batchReceived.isCompleted) {
          batchReceived.complete();
        }
      },
      onError: (error, _) => errors.add(error),
    );
    sampler.addGyroscope(x: 0.1, y: 0.2, z: 0.3);
    for (var index = 0; index < 200; index++) {
      sampler.addAccelerometer(
        elapsedMicroseconds: index * 5000,
        x: index.toDouble(),
        y: 2.2,
        z: 9.7,
      );
    }

    await batchReceived.future.timeout(const Duration(seconds: 2));
    await sampler.stopAndFlush();

    expect(errors, isEmpty);
    expect(samples, hasLength(200));
    expect(samples.first.recordedAt, DateTime.utc(2026, 11, 18));
    expect(samples.last.accelerometerX, 199);
    expect(samples.first.gyroscopeY, 0.2);
    for (var index = 0; index < samples.length; index++) {
      expect(samples[index].accelerometerX, index.toDouble());
    }
  });
}
