import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pasien.dart';
import '../models/paket_mcu.dart';
import '../models/pendaftaran_mcu.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:8000/api'; // Sesuaikan dengan URL API Anda

  // Auth Services
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> adminData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: adminData,
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }

  // Pasien Services
  Future<List<Pasien>> getPasienList() async {
    final response = await http.get(Uri.parse('$baseUrl/pasien'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => Pasien.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load pasien list');
    }
  }

  Future<Pasien> createPasien(Map<String, dynamic> pasienData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pasien'),
      body: pasienData,
    );

    if (response.statusCode == 201) {
      return Pasien.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create pasien');
    }
  }

  // Paket MCU Services
  Future<List<PaketMCU>> getPaketMCUList() async {
    final response = await http.get(Uri.parse('$baseUrl/paket-mcu'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => PaketMCU.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load paket MCU list');
    }
  }

  Future<PaketMCU> createPaketMCU(Map<String, dynamic> paketData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/paket-mcu'),
      body: paketData,
    );

    if (response.statusCode == 201) {
      return PaketMCU.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create paket MCU');
    }
  }

  // Pendaftaran MCU Services
  Future<List<PendaftaranMCU>> getPendaftaranList() async {
    final response = await http.get(Uri.parse('$baseUrl/pendaftaran'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((item) => PendaftaranMCU.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load pendaftaran list');
    }
  }

  Future<PendaftaranMCU> createPendaftaran(
      Map<String, dynamic> pendaftaranData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pendaftaran'),
      body: pendaftaranData,
    );

    if (response.statusCode == 201) {
      return PendaftaranMCU.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create pendaftaran');
    }
  }

  // Laporan Services
  Future<Map<String, dynamic>> getLaporanPemasukan(
      String startDate, String endDate) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/laporan/pemasukan?start_date=$startDate&end_date=$endDate'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load laporan pemasukan');
    }
  }
}
