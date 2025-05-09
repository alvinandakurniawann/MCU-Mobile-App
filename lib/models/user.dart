class User {
  final String id;
  final String? username;
  final String? password;
  final String? namaLengkap;
  final String? noKtp;
  final String? jenisKelamin;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? alamat;
  final String? noHandphone;
  final String? email;
  final String? fotoProfil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    this.username,
    this.password,
    this.namaLengkap,
    this.noKtp,
    this.jenisKelamin,
    this.tempatLahir,
    this.tanggalLahir,
    this.alamat,
    this.noHandphone,
    this.email,
    this.fotoProfil,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      namaLengkap: json['nama_lengkap'],
      noKtp: json['no_ktp'],
      jenisKelamin: json['jenis_kelamin'],
      tempatLahir: json['tempat_lahir'],
      tanggalLahir: json['tanggal_lahir'] != null && json['tanggal_lahir'] != '' ? DateTime.tryParse(json['tanggal_lahir']) : null,
      alamat: json['alamat'],
      noHandphone: json['no_handphone'],
      email: json['email'],
      fotoProfil: json['foto_profil'],
      createdAt: json['created_at'] != null && json['created_at'] != '' ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null && json['updated_at'] != '' ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nama_lengkap': namaLengkap,
      'no_ktp': noKtp,
      'jenis_kelamin': jenisKelamin,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir?.toIso8601String(),
      'alamat': alamat,
      'no_handphone': noHandphone,
      'email': email,
      'foto_profil': fotoProfil,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
