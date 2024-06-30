import 'package:dart_service_locator/dart_service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
// Adjust the import according to your file structure

class TestService {
  String getData() => 'Test Data';
}

void main() {
  setUp(() {
    clear();
  });

  test('Register and locate singleton', () {
    register<TestService>(() => TestService());

    final service1 = singleton<TestService>();
    final service2 = singleton<TestService>();

    expect(service1, isA<TestService>());
    expect(service1, same(service2)); // Should be the same instance
  });

  test('Create new instance each time', () {
    register<TestService>(() => TestService());

    final service1 = create<TestService>();
    final service2 = create<TestService>();

    expect(service1, isA<TestService>());
    expect(service1, isNot(same(service2))); // Should be different instances
  });

  test('Remove singleton', () {
    register<TestService>(() => TestService());

    final service1 = singleton<TestService>();
    remove<TestService>();
    final service2 = singleton<TestService>();

    expect(service1,
        isNot(same(service2))); // Should be different instances after removal
  });

  test('Register and locate Future', () async {
    register<Future<String>>(() async => 'Async Data');

    final futureData = await singleton<Future<String>>();
    expect(futureData, equals('Async Data'));
  });
}
