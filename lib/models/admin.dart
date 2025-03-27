class Admin {
  final String id;
  final String nama;
  final String username;
  final String noHandphone;
  final String alamat;
  final String jabatan;

  Admin({
    required this.id,
    required this.nama,
    required this.username,
    required this.noHandphone,
    required this.alamat,
    required this.jabatan,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] as String,
      nama: json['nama'] as String,
      username: json['username'] as String,
      noHandphone: json['no_handphone'] as String,
      alamat: json['alamat'] as String,
      jabatan: json['jabatan'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'no_handphone': noHandphone,
      'alamat': alamat,
      'jabatan': jabatan,
    };
  }
}
