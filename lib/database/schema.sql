-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Buat database
CREATE DATABASE IF NOT EXISTS medcheck_db;
USE medcheck_db;

-- Tabel Admin
CREATE TABLE IF NOT EXISTS admin (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nama VARCHAR(100) NOT NULL,
    no_handphone VARCHAR(15) NOT NULL,
    alamat TEXT NOT NULL,
    jabatan VARCHAR(10) NOT NULL DEFAULT 'user' CHECK (jabatan IN ('admin', 'user')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Pasien
CREATE TABLE IF NOT EXISTS pasien (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama VARCHAR(100) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    jenis_kelamin VARCHAR(10) NOT NULL CHECK (jenis_kelamin IN ('Laki-laki', 'Perempuan')),
    alamat TEXT NOT NULL,
    no_telp VARCHAR(15) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif', 'nonaktif')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Paket MCU
CREATE TABLE IF NOT EXISTS paket_mcu (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nama VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    harga DECIMAL(10,2) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif', 'nonaktif')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabel Pendaftaran MCU
CREATE TABLE IF NOT EXISTS pendaftaran_mcu (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_pasien UUID NOT NULL REFERENCES pasien(id),
    id_paket UUID NOT NULL REFERENCES paket_mcu(id),
    id_admin UUID NOT NULL REFERENCES admin(id),
    tanggal_pendaftaran DATE NOT NULL,
    jam_pendaftaran TIME NOT NULL,
    total_biaya DECIMAL(10,2) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'selesai', 'batal')),
    keterangan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
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

-- Create RLS (Row Level Security) policies
ALTER TABLE admin ENABLE ROW LEVEL SECURITY;
ALTER TABLE pasien ENABLE ROW LEVEL SECURITY;
ALTER TABLE paket_mcu ENABLE ROW LEVEL SECURITY;
ALTER TABLE pendaftaran_mcu ENABLE ROW LEVEL SECURITY;

-- Create policies for admin table
CREATE POLICY "Admin can view all admins" ON admin
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can insert admins" ON admin
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update admins" ON admin
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create policies for pasien table
CREATE POLICY "Anyone can view patients" ON pasien
    FOR SELECT USING (true);

CREATE POLICY "Admin can insert patients" ON pasien
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update patients" ON pasien
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create policies for paket_mcu table
CREATE POLICY "Anyone can view packages" ON paket_mcu
    FOR SELECT USING (true);

CREATE POLICY "Admin can insert packages" ON paket_mcu
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update packages" ON paket_mcu
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create policies for pendaftaran_mcu table
CREATE POLICY "Users can view their own registrations" ON pendaftaran_mcu
    FOR SELECT USING (auth.uid() = id_admin);

CREATE POLICY "Admin can view all registrations" ON pendaftaran_mcu
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert registrations" ON pendaftaran_mcu
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update registrations" ON pendaftaran_mcu
    FOR UPDATE USING (auth.role() = 'authenticated'); 