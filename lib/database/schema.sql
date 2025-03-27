-- Buat database
CREATE DATABASE IF NOT EXISTS medcheck_db;
USE medcheck_db;

-- Tabel Admin
CREATE TABLE IF NOT EXISTS admin (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    no_handphone VARCHAR(15) NOT NULL,
    alamat TEXT NOT NULL,
    jabatan ENUM('admin', 'user') NOT NULL DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Pasien
CREATE TABLE IF NOT EXISTS pasien (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    jenis_kelamin ENUM('Laki-laki', 'Perempuan') NOT NULL,
    alamat TEXT NOT NULL,
    no_telp VARCHAR(15) NOT NULL,
    status ENUM('aktif', 'nonaktif') NOT NULL DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Paket MCU
CREATE TABLE IF NOT EXISTS paket_mcu (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    harga DECIMAL(10,2) NOT NULL,
    status ENUM('aktif', 'nonaktif') NOT NULL DEFAULT 'aktif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabel Pendaftaran MCU
CREATE TABLE IF NOT EXISTS pendaftaran_mcu (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_pasien INT NOT NULL,
    id_paket INT NOT NULL,
    id_admin INT NOT NULL,
    tanggal_pendaftaran DATE NOT NULL,
    jam_pendaftaran TIME NOT NULL,
    total_biaya DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'selesai', 'batal') NOT NULL DEFAULT 'pending',
    keterangan TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pasien) REFERENCES pasien(id),
    FOREIGN KEY (id_paket) REFERENCES paket_mcu(id),
    FOREIGN KEY (id_admin) REFERENCES admin(id)
);

-- Insert data awal untuk admin
INSERT INTO admin (username, password, nama, no_handphone, alamat, jabatan) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', '081234567890', 'Jl. Admin No. 1', 'admin'),
('user', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'User', '081234567891', 'Jl. User No. 1', 'user');

-- Insert data awal untuk paket MCU
INSERT INTO paket_mcu (nama, deskripsi, harga) VALUES
('Paket Basic', 'Pemeriksaan dasar kesehatan', 500000),
('Paket Standard', 'Pemeriksaan kesehatan standar', 1000000),
('Paket Premium', 'Pemeriksaan kesehatan lengkap', 2000000); 