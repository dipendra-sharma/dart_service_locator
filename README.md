# Flutter Service Locator

A lightweight and easy-to-use dependency injection package for Flutter applications.

## Features

- Simple API for registering and resolving dependencies
- Support for both synchronous and asynchronous dependency resolution
- Singleton and factory instance management
- Built-in disposal mechanism for cleaning up resources
- Minimal boilerplate code required

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_service_locator: any
```

Then run:

```
$ flutter pub get
```

## Usage

### Setting up dependencies

```dart
import 'package:dart_service_locator/dart_service_locator.dart';

void setupDependencies() {
  // Register a synchronous dependency
  register<Logger>(() => ConsoleLogger());
  register<User>(() => User());

  // Register an asynchronous dependency
  register<Future<Database>>(() async {
    final db = Database();
    await db.initialize();
    return db;
  });

  // Register a dependency that relies on other dependencies
  register<Future<UserRepository>>(() async {
    final db = await locate<Future<Database>>();
    return UserRepository(db);
  });
}
```

### Using dependencies

```dart
import 'package:flutter/material.dart';
import 'package:dart_service_locator/dart_service_locator.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRepository>(
      future: locate<Future<UserRepository>>(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final userRepo = snapshot.data!;
          // Use userRepo
          return Text('User count: ${userRepo.getUserCount()}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
```

### Cleaning up

```dart
import 'package:dart_service_locator/dart_service_locator.dart';

clear();
```

## API Reference

- `register<T>(T Function() creator)`: Register a synchronous dependency
- `locate<T>()`: Get or create a locate instance of a dependency
- `create<T>()`: Create a new instance of a dependency
- `remove<T>()`: Remove a locate instance of a dependency
- `clear()`: Clear all registered dependencies

## Examples

For more advanced usage and examples, check out the [example](example) folder in the package repository.

## Additional Information

For more information on using this package, please refer to the [API documentation](https://pub.dev/documentation/watchable/latest/).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the BSD-3-Clause license - see the [LICENSE](LICENSE) file for details.