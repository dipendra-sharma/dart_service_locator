import 'package:dart_service_locator/dart_service_locator.dart';
import 'package:test/test.dart';

class BenchService {
  final int id;
  BenchService(this.id);
}

void main() {
  group('Performance benchmarks', () {
    setUp(() => clear());

    test('locate() is O(1) - constant time regardless of registry size', () {
      final times = <int, double>{};

      for (final n in [10, 100, 1000, 10000]) {
        clear();

        for (var i = 0; i < n; i++) {
          register<BenchService>(() => BenchService(i), instanceName: 'svc_$i');
        }

        // Pre-locate to cache singleton
        locate<BenchService>(instanceName: 'svc_0');

        // Measure locate time (average of 1000 calls)
        final sw = Stopwatch()..start();
        for (var i = 0; i < 1000; i++) {
          locate<BenchService>(instanceName: 'svc_0');
        }
        sw.stop();

        times[n] = sw.elapsedMicroseconds / 1000;
        print('N=$n: locate avg=${times[n]!.toStringAsFixed(3)}µs');
      }

      // Time ratio between smallest and largest N should be < 3x (O(1))
      final ratio = times[10000]! / times[10]!;
      print('Ratio (N=10000/N=10): ${ratio.toStringAsFixed(2)}x');
      expect(ratio, lessThan(3), reason: 'locate should be O(1)');
    });

    test('register() is O(1)', () {
      final times = <int, double>{};

      for (final n in [100, 1000, 5000]) {
        clear();

        // Pre-fill registry
        for (var i = 0; i < n; i++) {
          register<BenchService>(() => BenchService(i), instanceName: 'pre_$i');
        }

        // Measure time to register more
        final sw = Stopwatch()..start();
        for (var i = 0; i < 1000; i++) {
          register<BenchService>(() => BenchService(i), instanceName: 'new_$i');
        }
        sw.stop();

        times[n] = sw.elapsedMicroseconds / 1000;
        print('N=$n: register avg=${times[n]!.toStringAsFixed(3)}µs');
      }

      final ratio = times[5000]! / times[100]!;
      print('Ratio (N=5000/N=100): ${ratio.toStringAsFixed(2)}x');
      expect(ratio, lessThan(3), reason: 'register should be O(1)');
    });

    test('isRegistered() is O(1)', () {
      final times = <int, double>{};

      for (final n in [10, 100, 1000, 10000]) {
        clear();

        for (var i = 0; i < n; i++) {
          register<BenchService>(() => BenchService(i), instanceName: 'svc_$i');
        }

        final sw = Stopwatch()..start();
        for (var i = 0; i < 1000; i++) {
          isRegistered<BenchService>(instanceName: 'svc_0');
        }
        sw.stop();

        times[n] = sw.elapsedMicroseconds / 1000;
        print('N=$n: isRegistered avg=${times[n]!.toStringAsFixed(3)}µs');
      }

      final ratio = times[10000]! / times[10]!;
      print('Ratio (N=10000/N=10): ${ratio.toStringAsFixed(2)}x');
      expect(ratio, lessThan(3), reason: 'isRegistered should be O(1)');
    });

    test('Throughput benchmark - operations per second', () {
      register<BenchService>(() => BenchService(1));
      locate<BenchService>(); // Prime singleton

      const iterations = 100000;

      // locate (cached singleton)
      var sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        locate<BenchService>();
      }
      sw.stop();
      final locateOps = sw.elapsedMicroseconds > 0
          ? iterations * 1000000 ~/ sw.elapsedMicroseconds
          : iterations * 1000000;
      print(
          'locate: $locateOps ops/sec (${(sw.elapsedMicroseconds / iterations).toStringAsFixed(3)}µs/op)');

      // create (factory)
      sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        create<BenchService>();
      }
      sw.stop();
      final createOps = sw.elapsedMicroseconds > 0
          ? iterations * 1000000 ~/ sw.elapsedMicroseconds
          : iterations * 1000000;
      print(
          'create: $createOps ops/sec (${(sw.elapsedMicroseconds / iterations).toStringAsFixed(3)}µs/op)');

      // isRegistered
      sw = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        isRegistered<BenchService>();
      }
      sw.stop();
      final isRegOps = sw.elapsedMicroseconds > 0
          ? iterations * 1000000 ~/ sw.elapsedMicroseconds
          : iterations * 1000000;
      print(
          'isRegistered: $isRegOps ops/sec (${(sw.elapsedMicroseconds / iterations).toStringAsFixed(3)}µs/op)');

      // Expect high throughput
      expect(locateOps, greaterThan(100000), reason: 'locate should be fast');
      expect(isRegOps, greaterThan(100000),
          reason: 'isRegistered should be fast');
    });

    test('Minimal overhead - locate vs direct map access baseline', () {
      register<BenchService>(() => BenchService(1));
      locate<BenchService>();

      const iterations = 100000;

      // ServiceLocator locate
      final sw1 = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        locate<BenchService>();
      }
      sw1.stop();

      // Direct Map baseline
      final map = <Type, Object>{BenchService: BenchService(1)};
      final sw2 = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        map[BenchService];
      }
      sw2.stop();

      final overhead = sw2.elapsedMicroseconds > 0
          ? sw1.elapsedMicroseconds / sw2.elapsedMicroseconds
          : 1.0;
      print('locate time: ${sw1.elapsedMicroseconds}µs ($iterations ops)');
      print('direct map time: ${sw2.elapsedMicroseconds}µs ($iterations ops)');
      print('overhead ratio: ${overhead.toStringAsFixed(2)}x');

      // Should be < 10x overhead vs raw map access
      expect(overhead, lessThan(10), reason: 'Overhead should be minimal');
    });

    test('remove() is O(1)', () {
      final times = <int, double>{};

      for (final n in [100, 1000, 5000]) {
        clear();

        // Pre-fill and locate all to create singletons
        for (var i = 0; i < n; i++) {
          register<BenchService>(() => BenchService(i), instanceName: 'svc_$i');
          locate<BenchService>(instanceName: 'svc_$i');
        }

        // Measure remove time
        final sw = Stopwatch()..start();
        for (var i = 0; i < 100; i++) {
          remove<BenchService>(instanceName: 'svc_$i');
        }
        sw.stop();

        times[n] = sw.elapsedMicroseconds / 100;
        print('N=$n: remove avg=${times[n]!.toStringAsFixed(3)}µs');
      }

      final ratio = times[5000]! / times[100]!;
      print('Ratio (N=5000/N=100): ${ratio.toStringAsFixed(2)}x');
      expect(ratio, lessThan(3), reason: 'remove should be O(1)');
    });
  });
}
