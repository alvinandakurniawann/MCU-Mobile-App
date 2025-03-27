import 'package:medcheck_mobile/models/paket_mcu.dart';
import 'package:medcheck_mobile/models/user.dart';

class Pendaftaran {
  final String id;
  final User user;
  final PaketMCU paketMcu;
  final DateTime tanggalPendaftaran;
  final String status;
  final double totalHarga;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pendaftaran({
    required this.id,
    required this.user,
    required this.paketMcu,
    required this.tanggalPendaftaran,
    required this.status,
    required this.totalHarga,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pendaftaran.fromJson(Map<String, dynamic> json) {
    return Pendaftaran(
      id: json['id'],
      user: User.fromJson(json['user']),
      paketMcu: PaketMCU.fromJson(json['paket_mcu']),
      tanggalPendaftaran: DateTime.parse(json['tanggal_pendaftaran']),
      status: json['status'],
      totalHarga: json['total_harga'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user.id,
      'paket_mcu_id': paketMcu.id,
      'tanggal_pendaftaran': tanggalPendaftaran.toIso8601String(),
      'status': status,
      'total_harga': totalHarga,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
