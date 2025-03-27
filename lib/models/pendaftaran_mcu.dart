class PendaftaranMCU {
  final String id;
  final String idPasien;
  final String idPaket;
  final String tanggalPendaftaran;
  final String jamPendaftaran;
  final double totalBiaya;
  final String status;
  final String? keterangan;

  PendaftaranMCU({
    required this.id,
    required this.idPasien,
    required this.idPaket,
    required this.tanggalPendaftaran,
    required this.jamPendaftaran,
    required this.totalBiaya,
    required this.status,
    this.keterangan,
  });

  factory PendaftaranMCU.fromJson(Map<String, dynamic> json) {
    return PendaftaranMCU(
      id: json['id'] as String,
      idPasien: json['id_pasien'] as String,
      idPaket: json['id_paket'] as String,
      tanggalPendaftaran: json['tanggal_pendaftaran'] as String,
      jamPendaftaran: json['jam_pendaftaran'] as String,
      totalBiaya: json['total_biaya'] as double,
      status: json['status'] as String,
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pasien': idPasien,
      'id_paket': idPaket,
      'tanggal_pendaftaran': tanggalPendaftaran,
      'jam_pendaftaran': jamPendaftaran,
      'total_biaya': totalBiaya,
      'status': status,
      'keterangan': keterangan,
    };
  }
}
