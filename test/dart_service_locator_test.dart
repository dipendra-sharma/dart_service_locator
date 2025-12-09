import 'package:dart_service_locator/dart_service_locator.dart';
import 'package:test/test.dart';

class TestService {
  String getData() => 'Test Data';
}

class DisposableService {
  bool disposed = false;
  void close() => disposed = true;
}

void main() {
  setUp(() => clear());

  group('Basic functionality', () {
    test('Register and locate singleton', () {
      register<TestService>(() => TestService());
      final service1 = locate<TestService>();
      final service2 = locate<TestService>();
      expect(service1, isA<TestService>());
      expect(service1, same(service2));
    });

    test('Create new instance each time', () {
      register<TestService>(() => TestService());
      final service1 = create<TestService>();
      final service2 = create<TestService>();
      expect(service1, isA<TestService>());
      expect(service1, isNot(same(service2)));
    });

    test('Remove singleton', () {
      register<TestService>(() => TestService());
      final service1 = locate<TestService>();
      remove<TestService>();
      final service2 = locate<TestService>();
      expect(service1, isNot(same(service2)));
    });

    test('Register and locate Future', () async {
      register<Future<String>>(() async => 'Async Data');
      final futureData = await locate<Future<String>>();
      expect(futureData, equals('Async Data'));
    });
  });

  group('Named instances', () {
    test('Register and locate named instances', () {
      register<String>(() => 'default');
      register<String>(() => 'prod', instanceName: 'prod');
      register<String>(() => 'dev', instanceName: 'dev');

      expect(locate<String>(), equals('default'));
      expect(locate<String>(instanceName: 'prod'), equals('prod'));
      expect(locate<String>(instanceName: 'dev'), equals('dev'));
    });

    test('Named instances are independent singletons', () {
      register<TestService>(() => TestService(), instanceName: 'a');
      register<TestService>(() => TestService(), instanceName: 'b');

      final a1 = locate<TestService>(instanceName: 'a');
      final a2 = locate<TestService>(instanceName: 'a');
      final b1 = locate<TestService>(instanceName: 'b');

      expect(a1, same(a2));
      expect(a1, isNot(same(b1)));
    });

    test('Remove named instance only', () {
      register<TestService>(() => TestService());
      register<TestService>(() => TestService(), instanceName: 'named');

      final default1 = locate<TestService>();
      final named1 = locate<TestService>(instanceName: 'named');

      remove<TestService>(instanceName: 'named');

      final default2 = locate<TestService>();
      final named2 = locate<TestService>(instanceName: 'named');

      expect(default1, same(default2));
      expect(named1, isNot(same(named2)));
    });

    test('Create with named instance', () {
      register<TestService>(() => TestService(), instanceName: 'factory');
      final s1 = create<TestService>(instanceName: 'factory');
      final s2 = create<TestService>(instanceName: 'factory');
      expect(s1, isNot(same(s2)));
    });
  });

  group('isRegistered', () {
    test('Returns true for registered service', () {
      register<TestService>(() => TestService());
      expect(isRegistered<TestService>(), isTrue);
    });

    test('Returns false for unregistered service', () {
      expect(isRegistered<TestService>(), isFalse);
    });

    test('Works with named instances', () {
      register<TestService>(() => TestService(), instanceName: 'named');
      expect(isRegistered<TestService>(), isFalse);
      expect(isRegistered<TestService>(instanceName: 'named'), isTrue);
      expect(isRegistered<TestService>(instanceName: 'other'), isFalse);
    });
  });

  group('Disposal', () {
    test('Dispose called on remove', () {
      final service = DisposableService();
      register<DisposableService>(() => service, dispose: (s) => s.close());
      locate<DisposableService>();
      expect(service.disposed, isFalse);
      remove<DisposableService>();
      expect(service.disposed, isTrue);
    });

    test('Dispose called on clear', () {
      final service1 = DisposableService();
      final service2 = DisposableService();
      register<DisposableService>(() => service1, dispose: (s) => s.close());
      register<DisposableService>(() => service2,
          instanceName: 'named', dispose: (s) => s.close());

      locate<DisposableService>();
      locate<DisposableService>(instanceName: 'named');

      expect(service1.disposed, isFalse);
      expect(service2.disposed, isFalse);

      clear();

      expect(service1.disposed, isTrue);
      expect(service2.disposed, isTrue);
    });

    test('Dispose only called if instance was created', () {
      var disposeCalled = false;
      register<TestService>(() => TestService(),
          dispose: (_) => disposeCalled = true);
      remove<TestService>();
      expect(disposeCalled, isFalse);
    });

    test('Named instance dispose is independent', () {
      final service1 = DisposableService();
      final service2 = DisposableService();
      register<DisposableService>(() => service1, dispose: (s) => s.close());
      register<DisposableService>(() => service2,
          instanceName: 'named', dispose: (s) => s.close());

      locate<DisposableService>();
      locate<DisposableService>(instanceName: 'named');

      remove<DisposableService>();
      expect(service1.disposed, isTrue);
      expect(service2.disposed, isFalse);
    });
  });

  group('Error handling', () {
    test('Throws when service not registered', () {
      expect(() => locate<TestService>(), throwsException);
    });

    test('Throws with service name in error', () {
      expect(
        () => locate<TestService>(instanceName: 'myName'),
        throwsA(predicate((e) => e.toString().contains('myName'))),
      );
    });
  });
}
