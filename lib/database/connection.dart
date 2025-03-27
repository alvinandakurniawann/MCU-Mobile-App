import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseConnection {
  static final client = SupabaseClient(
    SupabaseConfig.url,
    SupabaseConfig.anonKey,
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
}
