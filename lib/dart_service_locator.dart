import 'dart:collection';

/// Composite key for Type + optional instance name
class _Key {
  final Type type;
  final String? name;
  const _Key(this.type, [this.name]);

  @override
  bool operator ==(Object other) =>
      other is _Key && type == other.type && name == other.name;

  @override
  int get hashCode => Object.hash(type, name);
}

/// A simple service locator for managing singleton and factory instances.
class ServiceLocator {
  final Map<_Key, dynamic> _singletons = HashMap<_Key, dynamic>();
  final Map<_Key, Function> _factories = HashMap<_Key, Function>();
  final Map<_Key, Function?> _disposers = HashMap<_Key, Function?>();

  ServiceLocator._();
  static final ServiceLocator I = ServiceLocator._();

  /// Registers a factory function for creating instances of type [T].
  void register<T>(T Function() creator,
      {String? instanceName, void Function(T)? dispose}) {
    final key = _Key(T, instanceName);
    _factories[key] = creator;
    _disposers[key] = dispose;
  }

  /// Locates a singleton instance of type [T]. If it doesn't exist, it creates one using the registered factory.
  T locate<T>({String? instanceName}) {
    final key = _Key(T, instanceName);
    if (_singletons.containsKey(key)) return _singletons[key] as T;
    final instance = _createInstance<T>(key);
    _singletons[key] = instance;
    return instance;
  }

  /// Creates a new instance of type [T] every time it is called.
  T create<T>({String? instanceName}) =>
      _createInstance<T>(_Key(T, instanceName));

  /// Checks if a service of type [T] is registered.
  bool isRegistered<T>({String? instanceName}) =>
      _factories.containsKey(_Key(T, instanceName));

  /// Removes the singleton instance of type [T], calling dispose if registered.
  void remove<T>({String? instanceName}) {
    final key = _Key(T, instanceName);
    final instance = _singletons[key];
    if (instance != null) {
      final dispose = _disposers[key];
      if (dispose != null) (dispose as void Function(T))(instance as T);
    }
    _singletons.remove(key);
  }

  /// Clears all registered services and singleton instances, calling dispose on each.
  void clear() {
    for (final entry in _singletons.entries) {
      final dispose = _disposers[entry.key];
      if (dispose != null) dispose(entry.value);
    }
    _singletons.clear();
    _factories.clear();
    _disposers.clear();
  }

  T _createInstance<T>(_Key key) {
    final factory = _factories[key];
    if (factory != null) return factory() as T;
    throw Exception(
        'Service not registered: ${key.type}${key.name != null ? ' (${key.name})' : ''}');
  }
}

/// Shortcut to locate a singleton instance of type [T].
T locate<T>({String? instanceName}) =>
    ServiceLocator.I.locate<T>(instanceName: instanceName);

/// Shortcut to create a new instance of type [T].
T create<T>({String? instanceName}) =>
    ServiceLocator.I.create<T>(instanceName: instanceName);

/// Shortcut to check if a service of type [T] is registered.
bool isRegistered<T>({String? instanceName}) =>
    ServiceLocator.I.isRegistered<T>(instanceName: instanceName);

/// Shortcut to remove the singleton instance of type [T].
void remove<T>({String? instanceName}) =>
    ServiceLocator.I.remove<T>(instanceName: instanceName);

/// Shortcut to register a factory function for creating instances of type [T].
void register<T>(T Function() creator,
        {String? instanceName, void Function(T)? dispose}) =>
    ServiceLocator.I
        .register<T>(creator, instanceName: instanceName, dispose: dispose);

/// Shortcut to remove all dependencies.
void clear() => ServiceLocator.I.clear();
