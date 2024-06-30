library dart_service_locator;

import 'dart:collection';

/// A simple service locator for managing singleton and factory instances.
class _ServiceLocator {
  final Map<Type, dynamic> _singletons = HashMap<Type, dynamic>();
  final Map<Type, Function> _factories = HashMap<Type, Function>();

  // Private constructor
  _ServiceLocator._();

  // Public accessor
  static final _ServiceLocator instance = _ServiceLocator._();

  /// Registers a factory function for creating instances of type [T].
  void register<T>(T Function() creator) {
    _factories[T] = creator;
  }

  /// Locates a singleton instance of type [T]. If it doesn't exist, it creates one using the registered factory.
  T locate<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    } else {
      final instance = _createInstance<T>();
      _singletons[T] = instance;
      return instance;
    }
  }

  /// Removes the singleton instance of type [T].
  void remove<T>() {
    _singletons.remove(T);
  }

  /// Creates a new instance of type [T] every time it is called.
  T create<T>() {
    return _createInstance<T>();
  }

  /// Clears all singleton instances.
  void clear() {
    _singletons.clear();
  }

  /// Helper method to create an instance using the factory function.
  T _createInstance<T>() {
    final factory = _factories[T];
    if (factory != null) {
      return factory() as T;
    } else {
      throw Exception('Service not registered in locator: $T');
    }
  }
}

/// Shortcut to locate a singleton instance of type [T].
T singleton<T>() => _ServiceLocator.instance.locate<T>();

/// Shortcut to create a new instance of type [T].
T create<T>() => _ServiceLocator.instance.create<T>();

/// Shortcut to remove the singleton instance of type [T].
void remove<T>() => _ServiceLocator.instance.remove<T>();

/// Shortcut to register a factory function for creating instances of type [T].
void register<T>(T Function() creator) =>
    _ServiceLocator.instance.register(creator);

/// Shortcut to remove all dependencies.
void clear() => _ServiceLocator.instance.clear();
