<div align="center">

# 💰 GoCatat

### Aplikasi Manajemen Keuangan Pribadi — Modern, Elegan & Multi-Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.27-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Backend](https://img.shields.io/badge/Backend-Go_Fiber-00ADD8?logo=go&logoColor=white)](https://gofiber.io)
[![Deploy](https://img.shields.io/badge/Live-gocatat.my.id-EC5B38?logo=googlechrome&logoColor=white)](https://gocatat.my.id)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

<br/>

**🌐 Live Demo → [gocatat.my.id](https://gocatat.my.id)**

<br/>

*Catat pemasukan & pengeluaran kamu dengan antarmuka yang cantik — kapan saja, di mana saja.*

</div>

---

## ✨ Tentang GoCatat

**GoCatat** adalah aplikasi pencatat keuangan pribadi yang dibangun dengan **Flutter**, memungkinkan satu codebase berjalan di **Web**, **Android**, **iOS**, **Windows**, **macOS**, dan **Linux**. Didesain dengan filosofi *iOS Liquid Glass* — antarmuka transparan berlapis blur yang terasa premium dan modern.

Aplikasi ini terhubung sepenuhnya dengan **backend API** berbasis **Go Fiber** yang menangani seluruh logika bisnis, autentikasi, dan penyimpanan data.

---

## 🚀 Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🔐 **Autentikasi** | Register, Login & Logout dengan session cookie yang aman |
| 📊 **Dashboard** | Ringkasan total saldo, pemasukan & pengeluaran secara real-time |
| 💳 **Manajemen Dompet** | CRUD dompet digital (Gopay, BCA, Cash, dll.) |
| 📝 **Pencatatan Transaksi** | Catat income & expense harian dengan detail lengkap |
| 👤 **Profil Pengguna** | Kelola informasi akun pribadi |
| 📱 **Responsif** | Tampilan adaptif untuk Mobile, Tablet & Desktop |

---

## 🎨 Desain & UI

GoCatat menggunakan konsep visual **Glassmorphism / Liquid Glass** yang terinspirasi dari iOS:

- **Background** — `#FCF2E5` Krem gading yang hangat dan nyaman di mata
- **Teks Utama** — `#524646` Cokelat keabu-abuan tua yang tegas namun ramah
- **Aksen** — `#A8A492` Abu-abu earthy untuk elemen sekunder
- **Primary Action** — `#EC5B38` Oranye kemerahan yang mencolok untuk CTA

**Fitur Visual:**
- 🪟 Efek backdrop blur transparan pada komponen utama
- ✨ Shimmer loading effect saat fetch data API
- 🎭 Hero animation & transisi halaman ala iOS (`CupertinoPageRoute`)
- 📐 Layout adaptif: Bottom Nav (Mobile) → Nav Rail (Tablet) → Sidebar (Desktop)

---

## 🏗️ Arsitektur Proyek

```
lib/
├── core/                  # Konfigurasi, konstanta, tema & utilitas
├── data/                  # Layer data (API service, models, repositories)
├── presentation/
│   ├── providers/         # State management (Provider)
│   ├── screens/           # Halaman utama aplikasi
│   │   ├── home_screen           # Dashboard & ringkasan keuangan
│   │   ├── balance_screen        # Manajemen dompet/saldo
│   │   ├── transaction_screen    # Riwayat & pencatatan transaksi
│   │   ├── login_screen          # Halaman login
│   │   ├── register_screen       # Halaman registrasi
│   │   └── profile_screen        # Profil pengguna
│   ├── widgets/           # Komponen UI reusable (glass cards, dll.)
│   └── app_shell.dart     # Shell navigasi responsif
└── main.dart              # Entry point aplikasi
```

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|-------|-----------|
| **Framework** | Flutter 3.27 (Dart 3.x) |
| **State Management** | Provider |
| **HTTP Client** | Dio + Cookie Manager |
| **Styling** | Google Fonts, Custom Glassmorphism Widgets |
| **Formatting** | intl (Currency & Date) |
| **Environment** | flutter_dotenv |
| **Backend API** | Go Fiber — [api.gocatat.my.id](https://api.gocatat.my.id) |
| **Deployment** | Docker + Nginx (EasyPanel VPS) |

---

## ⚡ Quick Start

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0.0
- Dart SDK ≥ 3.0.0

### Instalasi

```bash
# 1. Clone repository
git clone https://github.com/Fauzyfm/gocatat-fe.git
cd gocatat-fe

# 2. Salin dan konfigurasi environment
cp .env.example .env

# 3. Install dependencies
flutter pub get

# 4. Jalankan aplikasi
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run                  # Device default
```

### Environment Variables

```env
# Base URL API Backend
API_BASE_URL=https://api.gocatat.my.id/api/v1
```

---

## 🐳 Docker Deployment

GoCatat menggunakan **multi-stage Docker build** untuk deployment production:

```bash
# Build image
docker build \
  --build-arg API_BASE_URL=https://api.gocatat.my.id/api/v1 \
  -t gocatat-fe .

# Run container
docker run -d -p 80:80 gocatat-fe
```

**Stack deployment:**
- **Stage 1** — Debian Slim + Flutter SDK → build web release
- **Stage 2** — Nginx Alpine → serve static files dengan gzip & SPA routing

> 💡 Saat ini GoCatat sudah di-deploy dan berjalan di **[gocatat.my.id](https://gocatat.my.id)** menggunakan **EasyPanel** pada VPS.

---

## 🔗 API Endpoints

GoCatat terhubung ke backend API:

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `POST` | `/auth/register` | Registrasi akun baru |
| `POST` | `/auth/login` | Login pengguna |
| `POST` | `/auth/logout` | Logout pengguna |
| `GET` | `/auth/profile` | Ambil data profil |
| `GET` | `/balance` | Daftar semua dompet |
| `POST` | `/balance` | Buat dompet baru |
| `PUT` | `/balance/:id` | Edit dompet |
| `DELETE` | `/balance/:id` | Hapus dompet |
| `GET` | `/transaction` | Daftar transaksi |
| `POST` | `/transaction` | Catat transaksi baru |
| `GET` | `/transaction/summary` | Ringkasan keuangan |

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

<div align="center">

**Dibuat dengan ❤️ menggunakan Flutter & Go**

[⬆ Kembali ke Atas](#-gocatat)

</div>
