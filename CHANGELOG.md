## 2.0.1

- Updated dependencies: `lints` ^6.0.0, `test` ^1.25.0
- Code quality improvements and lint fixes

## 2.0.0

### Breaking Changes
- Removed Flutter SDK dependency - now pure Dart package
- `clear()` now removes all registrations (not just singletons)

### New Features
- **Named instances**: Register multiple implementations of the same type
  ```dart
  register<Logger>(() => ConsoleLogger(), instanceName: 'console');
  register<Logger>(() => FileLogger(), instanceName: 'file');
  ```
- **Disposal callbacks**: Automatic cleanup when services are removed
  ```dart
  register<Database>(() => Database(), dispose: (db) => db.close());
  ```
- **`isRegistered<T>()`**: Check if a service is registered before locating

### Improvements
- Better error messages with type and instance name context
- Works in all Dart environments (CLI, server, Flutter, web)

## 1.0.5

- Documentation update

## 1.0.4

- `ServiceLocator` class is now publicly available

## 1.0.3

- Made it simple and less complicated

## 1.0.2

- Readme updated

## 1.0.1

- Remove and clear bug fixed

## 1.0.0

- Initial release of the Flutter Service Locator package
- Support for registering and resolving both synchronous and asynchronous dependencies
- Singleton and factory instance management
- Built-in disposal mechanism for cleaning up resources
- API for checking if a dependency is registered
- Comprehensive documentation and examples
