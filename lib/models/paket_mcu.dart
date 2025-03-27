class PaketMCU {
  final String id;
  final String nama;
  final String deskripsi;
  final double harga;
  final String status;
  final List<String> layanan;

  PaketMCU({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.status,
    required this.layanan,
  });

  factory PaketMCU.fromJson(Map<String, dynamic> json) {
    return PaketMCU(
      id: json['id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      harga: json['harga'] as double,
      status: json['status'] as String,
      layanan: List<String>.from(json['layanan'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'status': status,
      'layanan': layanan,
    };
  }
}
