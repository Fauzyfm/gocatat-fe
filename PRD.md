# Product Requirements Document (PRD) - GoCatat (Multi-Platform Flutter App)

## 1. Objective & Goals
* **Tujuan Utama:** Membangun antarmuka aplikasi multi-platform (Mobile Android/iOS, Desktop, dan Web) untuk manajemen keuangan "GoCatat" yang sepenuhnya terhubung dengan backend API Go yang telah dirancang.
* **Masalah yang Dipecahkan:** Memberikan akses tak terbatas (fleksibel) kepada pengguna untuk mencatat dan melacak pemasukan, pengeluaran, dan saldo di berbagai perangkat tanpa hambatan antarmuka.
* **Target Pengguna:** Pengguna dengan mobilitas tinggi yang membutuhkan alat pencatat keuangan cepat di HP saat bepergian, sekaligus nyaman memonitor analitik di laptop/PC.

## 2. User Flows & Core Features

### User Flows:
1. **Autentikasi Lintas Platform:** Pengguna dapat mendaftar dan login di aplikasi HP, serta melanjutkan sesinya di perangkat web/desktop menggunakan email yang sama.
2. **Monitoring Visual Terpusat:** Di halaman dashboard, pengguna melihat ringkasan *total saldo*, *total pemasukan*, dan *total pengeluaran* (terintegrasi API backend). Tampilan menyesuaikan dimensi layar secara otomatis.
3. **Manajemen Dompet (Wallets):** Pengguna melihat dompet-dompet aktif (misal: "Gopay", "BCA", "Cash"), menambahkan dompet baru, mengedit, dan menghapusnya.
4. **Pencatatan Transaksi:** Pengguna memasukkan data transaksi harian (pemasukan atau pengeluaran) dan diarahkan pada dompet mana uang tersebut masuk atau keluar.

### Fitur Utama (Scope):
* **Autentikasi (`/auth`):** Layanan Register, Login, Logout dan manajemen identitas (Profile) menggunakan standar session/token API.
* **Dashboard (`/transaction/summary`):** Penyajian rekapitulasi performa finansial berdasarkan *response* API.
* **Modul Saldo/Dompet (`/balance`):** Antarmuka CRUD untuk dompet, tersinkronisasi langsung dengan *database* backend.
* **Modul Transaksi (`/transaction`):** Antarmuka riwayat transaksi harian secara detail (*income* & *expense*).

## 3. Acceptance Criteria
* [ ] Aplikasi dibangun dengan *framework* **Flutter**, sehingga satu *codebase* dapat menghasilkan *build* untuk Mobile (APK/iOS), Web, dan Windows/macOS/Linux.
* [ ] Aplikasi bersifat 100% responsif (*Adaptive UI*). Tampilan berubah mulus antara versi Smartphone (*Bottom Nav*), Tablet (*Nav Rail*), dan Laptop/Desktop (*Sidebar*).
* [ ] Layout antarmuka dipastikan sangat **mudah dipahami** secara intuisi oleh pengguna awam; tombol aksi utama (FAB) selalu menonjol.
* [ ] Komunikasi dengan API backend (seperti *handling cookie/token* dari Go Fiber) berfungsi sempurna di semua *build target* (Web dan non-Web).
* [ ] Aplikasi dapat menangani error dari server (contoh: validasi input, token kadaluarsa) dan menampilkannya sebagai pesan elegan kepada pengguna.

## 4. ⚠️ Strict Non-Goals (Batasan)
* **JANGAN** membuat penyimpanan data kalkulasi saldo mandiri di aplikasi jika tidak berlandaskan data backend. Semua perhitungan (seperti sisa saldo) divalidasi dan bersumber dari endpoint Go.
* **JANGAN** menggunakan desain yang kaku. *Glassmorphism* dan *liquid animation* wajib diimplementasikan, tidak sekadar material design biasa.
* **JANGAN** memaksakan tampilan antarmuka *mobile* secara mentah-mentah ke layar lebar laptop/desktop tanpa membagi kolom atau layar ruang *(whitespace)*.