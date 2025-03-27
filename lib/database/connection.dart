import 'package:mysql1/mysql1.dart';
import 'config.dart';

class DatabaseConnection {
  static MySqlConnection? _connection;

  static Future<MySqlConnection> get connection async {
    if (_connection == null) {
      final settings = ConnectionSettings(
        host: DatabaseConfig.host,
        port: DatabaseConfig.port,
        db: DatabaseConfig.database,
        user: DatabaseConfig.username,
        password: DatabaseConfig.password,
      );

      try {
        _connection = await MySqlConnection.connect(settings);
        print('Database connected successfully');
      } catch (e) {
        print('Error connecting to database: $e');
        rethrow;
      }
    }
    return _connection!;
  }

  static Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
