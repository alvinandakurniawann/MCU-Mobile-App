class Pasien {
  final String id;
  final String nama;
  final String tanggalLahir;
  final String jenisKelamin;
  final String alamat;
  final String noTelp;
  final String status;

  Pasien({
    required this.id,
    required this.nama,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alamat,
    required this.noTelp,
    required this.status,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      id: json['id'] as String,
      nama: json['nama'] as String,
      tanggalLahir: json['tanggal_lahir'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      alamat: json['alamat'] as String,
      noTelp: json['no_telp'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'no_telp': noTelp,
      'status': status,
    };
  }
}
