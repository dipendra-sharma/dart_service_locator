import 'dart:async';

/// A service locator for managing dependencies.
class ServiceLocator {
  final Map<Type, dynamic> _singletons = <Type, dynamic>{};
  final Map<Type, Function> _factories = <Type, Function>{};
  final Map<Type, Future<dynamic>> _asyncSingletons = <Type, Future<dynamic>>{};
  final Map<Type, Function> _asyncFactories = <Type, Function>{};

  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  /// Registers a synchronous factory for a type [T].
  void register<T>(T Function() creator) {
    _factories[T] = creator;
  }

  /// Registers an asynchronous factory for a type [T].
  void registerAsync<T>(Future<T> Function() creator) {
    _asyncFactories[T] = creator;
  }

  /// Locates an instance of type [T]. If the instance is not already created, it will be created.
  Future<T> locate<T>() async {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    } else if (_asyncSingletons.containsKey(T)) {
      return await _asyncSingletons[T] as T;
    } else {
      final instance = await _createInstance<T>();
      if (instance is Future) {
        _asyncSingletons[T] = instance as Future<dynamic>;
      } else {
        _singletons[T] = instance;
      }
      return instance;
    }
  }

  /// Removes the singleton instance of type [T].
  T? remove<T>() {
    _asyncSingletons.remove(T);
    return _singletons.remove(T) as T?;
  }

  /// Creates a new instance of type [T] without storing it as a singleton.
  Future<T> create<T>() async {
    return await _createInstance<T>();
  }

  /// Clears all registered singletons and disposes them if they implement [Disposable].
  Future<void> clear() async {
    for (var singleton in _singletons.values) {
      if (singleton is Disposable) {
        await singleton.dispose();
      }
    }
    for (var asyncSingleton in _asyncSingletons.values) {
      final resolvedSingleton = await asyncSingleton;
      if (resolvedSingleton is Disposable) {
        await resolvedSingleton.dispose();
      }
    }
    _singletons.clear();
    _asyncSingletons.clear();
  }

  /// Creates an instance of type [T] using the registered factory or async factory.
  Future<T> _createInstance<T>() async {
    final factory = _factories[T];
    final asyncFactory = _asyncFactories[T];
    if (factory != null) {
      return factory() as T;
    } else if (asyncFactory != null) {
      return await asyncFactory() as T;
    } else {
      throw ServiceNotRegisteredException(T);
    }
  }

  /// Checks if a factory or async factory is registered for type [T].
  bool isRegistered<T>() {
    return _factories.containsKey(T) || _asyncFactories.containsKey(T);
  }
}

/// An interface for disposable services.
abstract class Disposable {
  Future<void> dispose();
}

/// Exception thrown when a service is not registered in the locator.
class ServiceNotRegisteredException implements Exception {
  final Type type;

  ServiceNotRegisteredException(this.type);

  @override
  String toString() => 'Service not registered in locator: $type';
}

/// Locates a singleton instance of type [T].
Future<T> singleton<T>() => ServiceLocator.instance.locate<T>();

/// Creates a new instance of type [T].
Future<T> create<T>() => ServiceLocator.instance.create<T>();

/// Removes the singleton instance of type [T].
T? remove<T>() => ServiceLocator.instance.remove<T>();

/// Registers a synchronous factory for type [T].
void register<T>(T Function() creator) =>
    ServiceLocator.instance.register(creator);

/// Registers an asynchronous factory for type [T].
void registerAsync<T>(Future<T> Function() creator) =>
    ServiceLocator.instance.registerAsync(creator);

/// Checks if a factory or async factory is registered for type [T].
bool isRegistered<T>() => ServiceLocator.instance.isRegistered<T>();

/// Clears all registered singletons and disposes them if they implement [Disposable].
Future<void> clearLocator() => ServiceLocator.instance.clear();
