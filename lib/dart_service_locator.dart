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

  /// Locates a synchronous instance of type [T]. If the instance is not already created, it will be created.
  T locateSync<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    } else if (_factories.containsKey(T)) {
      final instance = _createInstanceSync<T>();
      _singletons[T] = instance;
      return instance;
    } else {
      throw ServiceNotRegisteredException(T);
    }
  }

  /// Locates an asynchronous instance of type [T]. If the instance is not already created, it will be created.
  Future<T> locateAsync<T>() async {
    if (_asyncSingletons.containsKey(T)) {
      return await _asyncSingletons[T] as T;
    } else if (_asyncFactories.containsKey(T)) {
      final instance = _createInstanceAsync<T>();
      _asyncSingletons[T] = instance;
      return instance;
    } else {
      throw ServiceNotRegisteredException(T);
    }
  }

  /// Removes the singleton instance of type [T].
  void remove<T>() {
    _factories.remove(T);
    _asyncSingletons.remove(T);
    _singletons.remove(T);
    _asyncFactories.remove(T);
  }

  /// Creates a new synchronous instance of type [T] without storing it as a singleton.
  T createSync<T>() {
    return _createInstanceSync<T>();
  }

  /// Creates a new asynchronous instance of type [T] without storing it as a singleton.
  Future<T> createAsync<T>() async {
    return await _createInstanceAsync<T>();
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
    _factories.clear();
    _singletons.clear();
    _asyncSingletons.clear();
    _asyncFactories.clear();
  }

  /// Creates a synchronous instance of type [T] using the registered factory.
  T _createInstanceSync<T>() {
    final factory = _factories[T];
    if (factory != null) {
      return factory() as T;
    } else {
      throw ServiceNotRegisteredException(T);
    }
  }

  /// Creates an asynchronous instance of type [T] using the registered async factory.
  Future<T> _createInstanceAsync<T>() async {
    final asyncFactory = _asyncFactories[T];
    if (asyncFactory != null) {
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

/// Locates a synchronous singleton instance of type [T].
T singleton<T>() => ServiceLocator.instance.locateSync<T>();

/// Locates an asynchronous singleton instance of type [T].
Future<T> singletonAsync<T>() => ServiceLocator.instance.locateAsync<T>();

/// Creates a new synchronous instance of type [T].
T create<T>() => ServiceLocator.instance.createSync<T>();

/// Creates a new asynchronous instance of type [T].
Future<T> createAsync<T>() => ServiceLocator.instance.createAsync<T>();

/// Removes the singleton instance of type [T].
void remove<T>() => ServiceLocator.instance.remove<T>();

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
