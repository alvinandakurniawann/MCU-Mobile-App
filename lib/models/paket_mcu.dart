class PaketMCU {
  final String id;
  final String namaPaket;
  final String deskripsi;
  final double harga;
  final int durasiPemeriksaan;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaketMCU({
    required this.id,
    required this.namaPaket,
    required this.deskripsi,
    required this.harga,
    required this.durasiPemeriksaan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaketMCU.fromJson(Map<String, dynamic> json) {
    return PaketMCU(
      id: json['id'] as String,
      namaPaket: json['nama_paket'] as String,
      deskripsi: json['deskripsi'] as String,
      harga: (json['harga'] as num).toDouble(),
      durasiPemeriksaan: json['durasi_pemeriksaan'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_paket': namaPaket,
      'deskripsi': deskripsi,
      'harga': harga,
      'durasi_pemeriksaan': durasiPemeriksaan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
