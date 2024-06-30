import 'package:dart_service_locator/dart_service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

class TestService {}

class AsyncTestService {
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

void main() {
  group('ServiceLocator', () {
    setUp(() async {
      // Clear the locator before each test
      await clearLocator();
    });

    test('should register and locate synchronous service', () {
      register<TestService>(() => TestService());

      final instance = singleton<TestService>();

      expect(instance, isA<TestService>());
    });

    test('should register and locate asynchronous service', () async {
      registerAsync<AsyncTestService>(() async {
        final service = AsyncTestService();
        await service.initialize();
        return service;
      });

      final instance = await singletonAsync<AsyncTestService>();

      expect(instance, isA<AsyncTestService>());
    });

    test(
        'should create new synchronous instance without storing it as singleton',
        () {
      register<TestService>(() => TestService());

      final instance1 = create<TestService>();
      final instance2 = create<TestService>();

      expect(instance1, isNot(same(instance2)));
    });

    test(
        'should create new asynchronous instance without storing it as singleton',
        () async {
      registerAsync<AsyncTestService>(() async {
        final service = AsyncTestService();
        await service.initialize();
        return service;
      });

      final instance1 = await createAsync<AsyncTestService>();
      final instance2 = await createAsync<AsyncTestService>();

      expect(instance1, isNot(same(instance2)));
    });

    test('should remove singleton instance', () {
      register<TestService>(() => TestService());
      remove<TestService>();
      expect(() => singleton<TestService>(),
          throwsA(isA<ServiceNotRegisteredException>()));
    });

    test('should clear all registered singletons', () async {
      register<TestService>(() => TestService());
      registerAsync<AsyncTestService>(() async {
        final service = AsyncTestService();
        await service.initialize();
        return service;
      });

      await clearLocator();

      expect(() => singleton<TestService>(),
          throwsA(isA<ServiceNotRegisteredException>()));
      expect(() => singletonAsync<AsyncTestService>(),
          throwsA(isA<ServiceNotRegisteredException>()));
    });

    test('should check if a factory or async factory is registered', () {
      register<TestService>(() => TestService());
      registerAsync<AsyncTestService>(() async {
        final service = AsyncTestService();
        await service.initialize();
        return service;
      });

      expect(isRegistered<TestService>(), isTrue);
      expect(isRegistered<AsyncTestService>(), isTrue);
      expect(isRegistered<String>(), isFalse);
    });
  });
}
