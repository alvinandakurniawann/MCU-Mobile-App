class User {
  final String id;
  final String username;
  final String password;
  final String namaLengkap;
  final String noKtp;
  final String jenisKelamin;
  final String tempatLahir;
  final DateTime tanggalLahir;
  final String alamat;
  final String noHandphone;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.namaLengkap,
    required this.noKtp,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.alamat,
    required this.noHandphone,
    this.email,
    required this.createdAt,
    required this.updatedAt,
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
      tanggalLahir: DateTime.parse(json['tanggal_lahir']),
      alamat: json['alamat'],
      noHandphone: json['no_handphone'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      'tanggal_lahir': tanggalLahir.toIso8601String(),
      'alamat': alamat,
      'no_handphone': noHandphone,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
