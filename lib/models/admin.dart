class Admin {
  final String id;
  final String username;
  final String namaLengkap;
  final String jabatan;
  final String? noHandphone;
  final String? alamat;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.id,
    required this.username,
    required this.namaLengkap,
    required this.jabatan,
    this.noHandphone,
    this.alamat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      username: json['username'],
      namaLengkap: json['nama_lengkap'],
      jabatan: json['jabatan'],
      noHandphone: json['no_handphone'],
      alamat: json['alamat'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama_lengkap': namaLengkap,
      'jabatan': jabatan,
      'no_handphone': noHandphone,
      'alamat': alamat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
