# Panduan Pengguna: Fitur Preloading dan Caching

Dokumen ini berisi panduan pengguna tentang fitur preloading dan caching global di aplikasi Aturin.

## Apa itu Preloading dan Caching?

**Preloading** berarti aplikasi memuat semua data utama (tugas, aktivitas, dan profil) saat pertama kali dibuka, sebelum Anda melihat halaman utama. Ini mengurangi waktu tunggu saat Anda berpindah antar halaman.

**Caching** berarti aplikasi menyimpan data yang sudah dimuat dalam penyimpanan sementara (cache), sehingga tidak perlu mengunduh data yang sama berulang kali dari server.

## Tampilan Splash Screen dengan Status Preloading

Saat Anda membuka aplikasi Aturin, Anda akan melihat splash screen dengan:

- Splash screen statis tanpa animasi loading apapun (untuk pengalaman yang lebih natural dan seamless)
- Status preloading yang hanya menampilkan apa yang sedang dimuat (profil, tugas, aktivitas)
- Progress bar sederhana yang menunjukkan kemajuan tanpa efek animasi berlebihan
- Persentase penyelesaian preloading yang ditampilkan secara halus

Splash screen ini memberikan informasi visual tentang kemajuan preloading data sehingga Anda tahu bahwa aplikasi sedang mempersiapkan data yang diperlukan. Tunggu hingga proses ini selesai untuk pengalaman terbaik.

## Keuntungan Bagi Pengguna

1. **Navigasi Lebih Cepat**: Tidak ada loading screen saat berpindah antar halaman utama (Aktivitas, Tugas, Profil)
2. **Penggunaan Data Lebih Efisien**: Data yang sama tidak diunduh berulang kali
3. **Pengalaman Lebih Mulus**: Halaman-halaman utama ditampilkan secara instan

## Kapan Data Diperbarui?

Data diperbarui dalam situasi berikut:

1. **Saat Aplikasi Pertama Dibuka**: Semua data utama diunduh dan disimpan dalam cache
2. **Setelah Operasi CRUD**: Saat Anda membuat, mengedit, atau menghapus data (cache otomatis diperbarui)
3. **Saat Pull-to-Refresh**: Saat Anda menarik layar ke bawah untuk menyegarkan data
4. **Setelah Cache Kedaluwarsa**: Cache memiliki masa berlaku tertentu (biasanya 5-30 menit)

## Bagaimana Cache Mendukung Operasi CRUD?

Sistem cache dirancang untuk tetap sinkron dengan perubahan data:

1. **Create (Membuat)**: Saat Anda membuat item baru, item tersebut langsung ditambahkan ke cache tanpa perlu memuat ulang data dari server
2. **Read (Membaca)**: Saat membuka aplikasi atau halaman, data diambil dari cache untuk tampilan instan
3. **Update (Mengubah)**: Perubahan pada data langsung diperbarui dalam cache, sehingga perubahan terlihat segera tanpa loading
4. **Delete (Menghapus)**: Item yang dihapus langsung dihapus dari cache, tanpa perlu memuat ulang data lengkap

## Cara Menggunakan

### Memuat Ulang Data (Refresh)

Untuk memuat ulang data dari server:

1. Tarik layar ke bawah pada halaman utama (pull-to-refresh)
2. Lepaskan untuk memulai proses refresh
3. Data terbaru akan dimuat dari server dan cache akan diperbarui

### Memastikan Data Terupdate

Jika Anda tidak yakin apakah data yang ditampilkan adalah data terbaru:

1. Gunakan fitur pull-to-refresh
2. Periksa tanggal dan waktu terakhir update pada item-item

### Saat Koneksi Buruk atau Offline

Saat koneksi internet buruk atau tidak tersedia:

1. Aplikasi akan menampilkan data dari cache (jika tersedia)
2. Pesan kesalahan akan muncul saat mencoba memuat ulang data
3. Anda tetap dapat melihat data yang sudah ada di cache

## Troubleshooting

### Data Tidak Muncul Setelah Dibuat/Diedit/Dihapus

1. Coba refresh manual dengan menarik layar ke bawah (pull-to-refresh)
2. Periksa koneksi internet Anda
3. Keluar dan masuk kembali ke aplikasi

### Aplikasi Lambat Saat Pertama Dibuka

1. Ini normal karena preloading sedang berjalan
2. Tunggu hingga splash screen menghilang
3. Progress bar dan status di splash screen menunjukkan kemajuan preloading

### Data Tidak Terupdate Otomatis

1. Gunakan pull-to-refresh untuk memaksa pembaruan dari server
2. Pastikan koneksi internet Anda stabil
3. Restart aplikasi jika masalah berlanjut

## Tips

1. **Beri Waktu Saat Pertama Kali**: Saat pertama membuka aplikasi, beri waktu singkat untuk preloading selesai dengan tampilan natural tanpa animasi
2. **Gunakan Pull-to-Refresh**: Jika ragu tentang kebaruan data, gunakan pull-to-refresh
3. **Perhatikan Progress Bar**: Progress bar statis akan menunjukkan kemajuan preloading tanpa animasi yang mengganggu
4. **Navigasi Tanpa Loading**: Setelah preloading selesai, navigasi antar halaman utama tidak akan menampilkan loading sama sekali

Dengan memahami cara kerja preloading dan caching, Anda dapat memanfaatkan aplikasi Aturin dengan lebih efektif dan efisien.
