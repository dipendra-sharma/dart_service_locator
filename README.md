# Dart Service Locator

[![Pub Version](https://img.shields.io/pub/v/dart_service_locator)](https://pub.dev/packages/dart_service_locator)
[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)

A lightweight, fast **dependency injection (DI) container** for Dart and Flutter applications. Zero dependencies, O(1) performance, ~100 lines of code.

## Quick Start

### Installation

```yaml
dependencies:
  dart_service_locator: any
```

### Basic Usage

```dart
import 'package:dart_service_locator/dart_service_locator.dart';

// 1. Register
register<ApiService>(() => ApiService());

// 2. Locate
final api = locate<ApiService>();

// 3. Done!
```

## Why dart_service_locator?

| Feature | dart_service_locator | get_it |
|---------|---------------------|--------|
| Pure Dart (no Flutter dependency) | ✅ | ❌ |
| Zero external dependencies | ✅ | ❌ |
| Lines of code | ~100 | ~2000+ |
| Named instances | ✅ | ✅ |
| Disposal callbacks | ✅ | ✅ |
| Async factories | ✅ | ✅ |
| O(1) lookup | ✅ | ✅ |
| Learning curve | Minimal | Moderate |

**Perfect for:**
- Small to medium apps
- Microservices & CLI tools
- Projects wanting minimal overhead
- Developers who prefer simplicity

## Core Concepts

### Registration Patterns

```dart
// Lazy singleton (created on first locate)
register<Logger>(() => ConsoleLogger());

// With disposal callback
register<Database>(
  () => Database(),
  dispose: (db) => db.close(),
);

// Named instances for multiple implementations
register<ApiClient>(() => ProdApi(), instanceName: 'prod');
register<ApiClient>(() => MockApi(), instanceName: 'mock');
```

### Resolution Patterns

```dart
// Get singleton (same instance every time)
final logger = locate<Logger>();

// Create new instance each time
final fresh = create<Logger>();

// Named instance
final prod = locate<ApiClient>(instanceName: 'prod');

// Check before registering
if (!isRegistered<Logger>()) {
  register<Logger>(() => ConsoleLogger());
}
```

### Dependency Chains

```dart
register<Logger>(() => ConsoleLogger());
register<Database>(() => Database(locate<Logger>()));
register<UserRepo>(() => UserRepo(locate<Database>()));

// Resolves entire dependency chain
final repo = locate<UserRepo>();
```

### Async Dependencies

```dart
register<Future<Database>>(() async {
  final db = Database();
  await db.initialize();
  return db;
});

final db = await locate<Future<Database>>();
```

## Real-World Examples

### Flutter App Setup

```dart
void main() {
  setupDependencies();
  runApp(MyApp());
}

void setupDependencies() {
  // Core services
  register<Logger>(() => ConsoleLogger());
  register<HttpClient>(() => HttpClient());

  // Repositories
  register<AuthRepository>(() => AuthRepository(
    client: locate<HttpClient>(),
    logger: locate<Logger>(),
  ));

  // Use cases
  register<LoginUseCase>(() => LoginUseCase(
    authRepo: locate<AuthRepository>(),
  ));
}

// In your widgets
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginUseCase = locate<LoginUseCase>();
    // Use the dependency
  }
}
```

### Testing with Mocks

```dart
void main() {
  setUp(() {
    clear(); // Reset before each test

    // Register mocks
    register<AuthRepository>(() => MockAuthRepository());
    register<LoginUseCase>(() => LoginUseCase(
      authRepo: locate<AuthRepository>(),
    ));
  });

  test('login success', () {
    final useCase = locate<LoginUseCase>();
    // Test with mock dependency
  });
}
```

## Performance

Benchmarked on Apple M1:

| Operation | Throughput | Latency |
|-----------|------------|---------|
| `locate()` | **11M ops/sec** | ~0.09µs |
| `create()` | **15M ops/sec** | ~0.06µs |
| `isRegistered()` | **44M ops/sec** | ~0.02µs |
| `register()` | **7M ops/sec** | ~0.13µs |

**O(1) Verified**: Time complexity remains constant from 10 to 10,000+ registered services.

**Minimal Overhead**: Only ~2x slower than direct HashMap access.

## API Reference

### Registration

```dart
void register<T>(
  T Function() factory, {
  String? instanceName,
  void Function(T)? dispose,
})
```

### Resolution

```dart
T locate<T>({String? instanceName})         // Get/create singleton
T create<T>({String? instanceName})         // Always create new
bool isRegistered<T>({String? instanceName}) // Check registration
```

### Cleanup

```dart
void remove<T>({String? instanceName})  // Remove + call dispose
void clear()                             // Remove all + dispose all
```

### Direct Class Access

```dart
ServiceLocator.I.register<T>(...)
ServiceLocator.I.locate<T>(...)
ServiceLocator.I.create<T>(...)
ServiceLocator.I.remove<T>(...)
ServiceLocator.I.isRegistered<T>(...)
ServiceLocator.I.clear()
```

## Examples

See the [example](example) folder for a complete working example.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

BSD-3-Clause - see [LICENSE](LICENSE)
