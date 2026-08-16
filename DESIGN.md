# Design Specification - GoCatat (Flutter App)

## 1. Konsep Visual & Tema (iOS Liquid Glass)
* **Gaya Desain:** Terinspirasi dari gaya OS Apple (iOS) dengan elemen *Glassmorphism* atau *Liquid Glass*. Komponen antarmuka memiliki efek tembus pandang (translucent) dengan *blur* pada latar belakang, memberikan kesan UI yang berlapis, mewah, modern, dan menyatu dengan *background*.
* **Palet Warna:** 
  Pilihan warna bernuansa elegan, kalem, namun memiliki aksen tegas:
  * **Dasar / Latar Belakang (Background):** `#FCF2E5` (Warna krem gading yang sangat hangat dan ringan, nyaman di mata).
  * **Teks Utama & Elemen Gelap:** `#524646` (Cokelat keabu-abuan tua; tegas, hangat, dan lebih ramah dibandingkan hitam pekat).
  * **Aksen / Warna Sekunder:** `#A8A492` (Abu-abu *earthy* / *taupe*; digunakan untuk teks sekunder, garis batas (*border* tipis), atau elemen yang kurang prioritas).
  * **Aksi Utama (Primary):** `#EC5B38` (Oranye kemerahan; sangat mencolok, digunakan untuk tombol aksi penting, pembeda warna pengeluaran, atau notifikasi agar langsung menarik perhatian).
* **Tipografi:** 
  Menggunakan *font* yang **tegas namun luwes** (mudah dibaca namun tidak kaku).
  * **Rekomendasi:** **SF Pro Display** (Standar iOS), **Poppins** (Luwes & geometris), atau **Montserrat**.
  * **Penggunaan:** Judul/Nominal menggunakan *SemiBold/Bold*, sedangkan teks deskripsi menggunakan *Regular*.

## 2. Layout & Responsivitas (Cross-Platform Flutter)
Aplikasi ini dikembangkan menggunakan **Flutter** dengan satu basis kode (*codebase*) yang dapat beradaptasi (responsif) di segala layar: Mobile, Tablet, Desktop (Laptop/PC), dan Web. Layout dirancang agar **sangat intuitif dan mudah dipahami**.

* **Mobile (Smartphone):**
  * **Navigasi:** Memanfaatkan *Bottom Navigation Bar* yang mengambang dengan efek *glassmorphism*.
  * **Tata Letak:** *Single-column* memanjang ke bawah. Bagian atas diisi oleh ringkasan saldo, di bawahnya terdapat kartu dompet (*swipe/carousel* horizontal), dan diikuti daftar transaksi.
  * **Aksi:** Tombol "Tambah Transaksi" menggunakan *Floating Action Button (FAB)* berwarna `#EC5B38` dengan efek *glow*.
* **Tablet (Layar Menengah):**
  * **Navigasi:** *Navigation Rail* vertikal di sisi kiri layar.
  * **Tata Letak:** Mulai memisahkan ruang (contoh: 2 kolom untuk melihat saldo & transaksi secara berdampingan).
* **Laptop / Desktop / Web:**
  * **Navigasi:** *Sidebar* utuh berbahan *glass* di sebelah kiri untuk berpindah menu.
  * **Tata Letak:** *Multi-column*. Layar utama sangat lapang. Area kiri/tengah untuk Dashboard & Transaksi, sementara sisi paling kanan dapat memuat panel *detail transaksi* atau *form tambah data* tanpa perlu memunculkan jendela baru (*modal*).

## 3. Komponen UI (Glassmorphism Implementasi Flutter)
* **Kartu Nominal & Dompet:** 
  * Dibangun dengan `Container` berlatar belakang gradasi putih/krem sangat tipis.
  * Ditambahkan `BackdropFilter` dengan `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` untuk memburamkan objek di baliknya.
  * *Border* warna `#A8A492` yang diberi *opacity* rendah (contoh: 30%) tebal 1px di sisi atas untuk efek *edge highlight* khas kaca.
* **Daftar Transaksi (ListTiles):** 
  * *Tile* bersudut membulat (*rounded corners*) dengan jarak spasial (`margin`) antar transaksi agar tidak terlihat bertumpuk.
  * Nominal pemasukan direpresentasikan dengan teks `#524646` tebal, dan pengeluaran menggunakan `#EC5B38`.
* **Input / Form:** 
  * Kotak pencarian atau input teks berwujud kapsul/kotak bersudut membulat lembut. Tidak memakai garis tegas melainkan mengandalkan bayangan halus (*soft inner shadow*) agar selaras dengan tema liquid glass.

## 4. State, Transisi & Animasi
* **Animasi Transisi:** Penggunaan *Hero animation* khas Flutter saat pengguna mengetuk daftar dompet menuju detail dompet. Transisi antar halaman mengadopsi efek geser (sliding) ala iOS (`CupertinoPageRoute`).
* **Loading State:** Penggunaan *Shimmer Effect* (efek cahaya mengkilap berjalan) berbalut latar transparan kaca saat memuat data dari API.
* **Micro-interactions:** Setiap elemen interaktif memiliki respons visual (seperti mengecil sedikit saat ditekan menggunakan widget `InkWell` atau kustomisasi). Efek *Haptic feedback* kecil di-trigger pada HP saat menambahkan transaksi berhasil.