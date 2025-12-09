import 'package:dart_service_locator/dart_service_locator.dart';

// Example services
abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) => print('[LOG] $message');
}

class FileLogger implements Logger {
  @override
  void log(String message) => print('[FILE] $message');
}

class Database {
  final Logger logger;
  bool _closed = false;

  Database(this.logger) {
    logger.log('Database connected');
  }

  void query(String sql) {
    if (_closed) throw StateError('Database is closed');
    logger.log('Query: $sql');
  }

  void close() {
    _closed = true;
    logger.log('Database closed');
  }
}

class UserRepository {
  final Database db;
  UserRepository(this.db);

  void getUsers() => db.query('SELECT * FROM users');
}

void main() {
  print('=== dart_service_locator Example ===\n');

  // 1. Basic registration and location
  print('1. Basic singleton:');
  register<Logger>(() => ConsoleLogger());
  final logger = locate<Logger>();
  logger.log('Hello from singleton!');
  print('Same instance: ${identical(locate<Logger>(), logger)}\n');

  // 2. Named instances
  print('2. Named instances:');
  register<Logger>(() => FileLogger(), instanceName: 'file');
  locate<Logger>().log('From default logger');
  locate<Logger>(instanceName: 'file').log('From file logger');
  print('');

  // 3. Disposal callbacks
  print('3. Disposal callbacks:');
  register<Database>(
    () => Database(locate<Logger>()),
    dispose: (db) => db.close(),
  );
  final db = locate<Database>();
  db.query('SELECT 1');
  remove<Database>(); // Will call dispose
  print('');

  // 4. Factory pattern (create new each time)
  print('4. Factory pattern:');
  register<Database>(() => Database(locate<Logger>()));
  final db1 = create<Database>();
  final db2 = create<Database>();
  print('Different instances: ${!identical(db1, db2)}\n');

  // 5. Check if registered
  print('5. isRegistered:');
  print('Logger registered: ${isRegistered<Logger>()}');
  print('UserRepository registered: ${isRegistered<UserRepository>()}');
  register<UserRepository>(() => UserRepository(locate<Database>()));
  print('UserRepository registered (after): ${isRegistered<UserRepository>()}\n');

  // 6. Dependency chain
  print('6. Dependency chain:');
  final repo = locate<UserRepository>();
  repo.getUsers();
  print('');

  // 7. Cleanup
  print('7. Cleanup:');
  clear();
  print('All cleared. Logger registered: ${isRegistered<Logger>()}');
}
