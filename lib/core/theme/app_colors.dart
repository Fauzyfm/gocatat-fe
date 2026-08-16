import 'package:flutter/material.dart';

class AppColors {
  // Warna Latar Belakang (Dasar)
  static const Color background = Color(0xFFFCF2E5);
  
  // Teks Utama / Elemen Gelap
  static const Color textPrimary = Color(0xFF524646);
  
  // Aksen / Teks Sekunder / Border Tipis
  static const Color textSecondary = Color(0xFFA8A492);
  
  // Aksi Utama (Primary) / Pengeluaran / Notifikasi
  static const Color primaryAction = Color(0xFFEC5B38);

  // Warna Pemasukan (Bisa pakai Emerald/Green yang selaras, atau tetap pakai textPrimary/primaryAction)
  static const Color income = Color(0xFF2E8B57); // Contoh warna hijau untuk income
  static const Color expense = primaryAction; // Merah/Oranye untuk expense
}
