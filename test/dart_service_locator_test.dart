import 'package:dart_service_locator/dart_service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

class TestService {
  String getValue() => 'Test Value';
}

class AsyncTestService {
  Future<String> getValue() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'Async Test Value';
  }
}

class DisposableService implements Disposable {
  bool disposed = false;

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  group('ServiceLocator', () {
    setUp(() async {
      await clearLocator();
    });

    test('register and locate synchronous dependency', () async {
      register<TestService>(() => TestService());
      final service = await singleton<TestService>();
      expect(service, isA<TestService>());
      expect(service.getValue(), equals('Test Value'));
    });

    test('register and locate asynchronous dependency', () async {
      registerAsync<AsyncTestService>(() async => AsyncTestService());
      final service = await singleton<AsyncTestService>();
      expect(service, isA<AsyncTestService>());
      expect(await service.getValue(), equals('Async Test Value'));
    });

    test('singleton returns the same instance', () async {
      register<TestService>(() => TestService());
      final service1 = await singleton<TestService>();
      final service2 = await singleton<TestService>();
      expect(identical(service1, service2), isTrue);
    });

    test('create returns a new instance each time', () async {
      register<TestService>(() => TestService());
      final service1 = await create<TestService>();
      final service2 = await create<TestService>();
      expect(identical(service1, service2), isFalse);
    });

    test('remove deletes the singleton instance', () async {
      register<TestService>(() => TestService());
      final originalInstance = await singleton<TestService>();
      final removed = remove<TestService>();
      expect(removed, isA<TestService>());
      expect(identical(originalInstance, removed), isTrue);
      final newInstance = await singleton<TestService>();
      expect(identical(removed, newInstance), isFalse);
    });

    test('clear removes all singletons', () async {
      register<TestService>(() => TestService());
      registerAsync<AsyncTestService>(() async => AsyncTestService());
      await singleton<TestService>();
      await singleton<AsyncTestService>();
      await clearLocator();
      expect(isRegistered<TestService>(), isFalse);
      expect(isRegistered<AsyncTestService>(), isFalse);
      register<TestService>(() => TestService());
      final newService = await singleton<TestService>();
      expect(newService, isA<TestService>());
    });

    test('isRegistered returns correct status', () {
      expect(isRegistered<TestService>(), isFalse);
      register<TestService>(() => TestService());
      expect(isRegistered<TestService>(), isTrue);
      remove<TestService>();
      expect(isRegistered<TestService>(),
          isFalse); // This should be false after removal
      registerAsync<AsyncTestService>(() async => AsyncTestService());
      expect(isRegistered<AsyncTestService>(), isTrue);
    });

    test('throws exception when locating unregistered dependency', () {
      expect(() => singleton<UnregisteredService>(),
          throwsA(isA<ServiceNotRegisteredException>()));
    });

    test('disposes disposable services on clear', () async {
      final disposableService = DisposableService();
      register<DisposableService>(() => disposableService);
      await singleton<DisposableService>();
      await clearLocator();
      expect(disposableService.disposed, isTrue);
    });

    test('async singleton creation', () async {
      registerAsync<AsyncTestService>(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return AsyncTestService();
      });

      final future1 = singleton<AsyncTestService>();
      final future2 = singleton<AsyncTestService>();

      final instance1 = await future1;
      final instance2 = await future2;

      expect(identical(instance1, instance2), isTrue);
    });

    test('create async instance', () async {
      registerAsync<AsyncTestService>(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return AsyncTestService();
      });
      final service1 = await create<AsyncTestService>();
      final service2 = await create<AsyncTestService>();
      expect(identical(service1, service2), isFalse);
    });
  });
}

class UnregisteredService {}
