class DatabaseConfig {
  static const String host = 'localhost';
  static const String database = 'medcheck_db';
  static const String username = 'root';
  static const String password = '';
  static const int port = 3306;

  static String get connectionString =>
      'mysql://$username:$password@$host:$port/$database';
}
