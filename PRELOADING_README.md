# Preloading & Global Caching Implementation

Dokumen ini menjelaskan implementasi preloading dan caching global untuk aplikasi Aturin. Implementasi ini memastikan semua data utama dimuat di awal aplikasi dan disimpan dalam cache, sehingga pengguna tidak perlu melihat loading screen saat berpindah antar halaman.

## Cara Kerja

1. **Preloading Data**
   - Semua data utama (tugas, aktivitas, dan profil) dimuat secara otomatis saat aplikasi pertama kali dibuka
   - Selama preloading, aplikasi menampilkan splash screen dengan indikator loading dan status preloading
   - Data yang dimuat disimpan dalam cache dan dapat digunakan oleh semua halaman

2. **Caching Sistem**
   - Data dimuat dari cache terlebih dahulu, bukan langsung dari API
   - Jika cache valid (belum kedaluwarsa), aplikasi menggunakan data cache
   - Jika cache tidak valid atau data telah berubah, aplikasi memuat data dari server

3. **Pengalaman Pengguna**
   - Tidak ada loading screen saat berpindah antar halaman utama jika data sudah ada di cache
   - Pengguna dapat menyegarkan (refresh) data dengan menarik layar ke bawah (pull-to-refresh)
   - Setelah operasi CRUD, cache diperbarui secara otomatis

## Komponen Utama

1. **AppInitializer**
   - Bertanggung jawab untuk memulai preloading data
   - Memuat tugas, aktivitas, dan profil secara paralel
   - Memperbarui status preloading untuk ditampilkan di splash screen

2. **CacheService**
   - Singleton service untuk menyimpan dan mengambil data dari cache
   - Menggunakan flutter_cache_manager untuk mengelola data cache
   - Menangani validasi dan invalidasi cache

3. **API Services**
   - TaskApiService, ActivityApiService, dan ProfileService
   - Masing-masing mendukung penggunaan cache dan penandaan data yang berubah
   - Memiliki parameter forceRefresh untuk memaksa pembaruan dari server

4. **Splash & Preloading Screen**
   - Menampilkan status preloading dan progress bar
   - Memberikan feedback visual kepada pengguna selama preloading

## Alur Data

1. Aplikasi dimulai dan menampilkan splash screen
2. AppInitializer memulai preloading semua data utama
3. Status preloading ditampilkan di splash screen
4. Setelah preloading selesai, aplikasi utama dimulai
5. Halaman-halaman (Aktivitas, Tugas, Profil) menggunakan data dari cache
6. Jika pengguna melakukan CRUD, cache diinvalidasi dan data dimuat ulang

## Troubleshooting

1. **Data Tidak Muncul Setelah Create/Update/Delete**
   - Cache mungkin tidak diinvalidasi dengan benar
   - Coba refresh manual dengan menarik layar ke bawah

2. **Aplikasi Lambat Saat Startup**
   - Ini normal karena preloading sedang berjalan
   - Status preloading ditampilkan di splash screen

3. **Data Tidak Terupdate Otomatis**
   - Coba gunakan fitur pull-to-refresh
   - Restart aplikasi jika masalah berlanjut

## Best Practices

1. Gunakan parameter forceRefresh saat data perlu diperbarui segera
2. Pastikan cache diinvalidasi setelah operasi CRUD
3. Beri pengguna feedback visual saat data sedang dimuat (preloading indicator)

## Kesimpulan

Dengan implementasi preloading dan caching global, aplikasi Aturin memberikan pengalaman pengguna yang lebih baik dengan:

1. Loading awal yang transparan dengan status yang jelas
2. Transisi antar halaman yang instan tanpa loading screen
3. Data yang selalu tersedia bahkan saat offline (cached)
4. Efisiensi penggunaan jaringan dengan caching yang cerdas
