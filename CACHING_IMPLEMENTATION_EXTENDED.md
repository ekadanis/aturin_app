# Implementasi Caching pada Aplikasi Aturin

Dokumen ini menjelaskan implementasi caching pada aplikasi Aturin untuk mengurangi loading screen dan meningkatkan responsivitas UI.

## Gambaran Umum

Implementasi caching bertujuan untuk:

1. Menghilangkan loading screen yang tidak perlu
2. Memastikan UI diperbarui secara real-time setelah operasi CRUD
3. Mengurangi permintaan jaringan ke server
4. Memberikan pengalaman pengguna yang lebih cepat dan responsif

## Komponen Utama

### 1. CacheService

`CacheService` adalah kelas singleton yang menggunakan `flutter_cache_manager` untuk mengelola data cache. Layanan ini menyimpan data API dalam bentuk JSON dengan masa berlaku tertentu.

**Fitur Utama**:

- Penyimpanan data ke cache dengan key tertentu
- Pengambilan data dari cache
- Validasi apakah cache masih berlaku
- Penghapusan cache berdasarkan key atau prefix
- Pembersihan semua cache

### 2. TaskApiService

Mengimplementasikan mekanisme caching untuk seluruh operasi task:

**Cache Keys**:

- `all_tasks` - Untuk semua task
- `today_tasks` - Untuk task hari ini
- `uncompleted_today_tasks` - Untuk task yang belum selesai hari ini
- `tasks_by_status_` - Prefix untuk task berdasarkan status
- `dashboard_summary` - Untuk ringkasan dashboard
- `late_tasks_count` - Untuk jumlah task terlambat

**Perilaku Caching**:

- **Operasi Baca (GET)**: Memeriksa cache terlebih dahulu, mengambil dari server hanya jika cache tidak valid atau `forceRefresh=true`
- **Operasi Tulis (POST/PATCH/DELETE)**: Menandai data sebagai berubah (`_dataChanged=true`), membersihkan cache terkait, dan memperbarui UI

### 3. ActivityApiService

Mengimplementasikan mekanisme caching untuk seluruh operasi aktivitas:

**Cache Keys**:

- `all_activities` - Untuk semua aktivitas
- `today_activities` - Untuk aktivitas hari ini
- `activities_by_date_` - Prefix untuk aktivitas berdasarkan tanggal
- `activities_by_category_` - Prefix untuk aktivitas berdasarkan kategori
- `activities_by_date_range_` - Prefix untuk aktivitas berdasarkan rentang tanggal
- `activity_by_slug_` - Prefix untuk detail aktivitas berdasarkan slug

**Perilaku Caching**:

- **Operasi Baca (GET)**: Memeriksa cache terlebih dahulu, mengambil dari server hanya jika cache tidak valid atau `forceRefresh=true`
- **Operasi Tulis (POST/PATCH/DELETE)**: Menandai data sebagai berubah (`_dataChanged=true`), membersihkan cache terkait, dan memperbarui UI

## Alur Caching

### Alur Baca Data

1. Aplikasi meminta data melalui API service (`TaskApiService`/`ActivityApiService`)
2. API service memeriksa apakah terdapat cache valid yang dapat digunakan:
   - Jika `forceRefresh=true` atau `_dataChanged=true`, langsung mengambil data dari server
   - Jika cache valid, menggunakan data dari cache
   - Jika cache tidak valid, mengambil data dari server
3. Jika mengambil dari server, data baru disimpan ke cache
4. API service memperbarui state dan notifyListeners() untuk memperbarui UI

### Alur Tulis Data (CRUD)

1. Aplikasi melakukan operasi tulis melalui API service
2. API service mengirim permintaan ke server
3. Setelah berhasil, API service:
   - Menandai data sebagai berubah (`_dataChanged=true`)
   - Membersihkan cache terkait
   - Memuat ulang data dari server dengan `forceRefresh=true`
   - Memperbarui state dan notifyListeners() untuk memperbarui UI

## Fitur Khusus

### Parameter forceRefresh

Semua metode fetch memiliki parameter `forceRefresh` yang memungkinkan pengembang untuk:

- `forceRefresh=false` (default): Menggunakan cache jika masih valid
- `forceRefresh=true`: Mengabaikan cache dan selalu mengambil data segar dari server

### Invalidasi Cache Pintar

Sistem menggunakan invalidasi cache strategis:

- Pada operasi tulis, hanya cache terkait yang dihapus
- Untuk prefix-based keys, menggunakan `removePrefixedData` untuk menghapus semua cache terkait

### Efisiensi Loading

UI dirancang untuk:

- Menampilkan data dari cache segera, tanpa loading screen
- Menampilkan loading screen hanya jika tidak ada data cache dan sedang mengambil dari server
- Menggunakan `RefreshIndicator` untuk memberi pengguna kendali atas pembaruan data

## Implementasi di UI

### AktivitasPage (Jadwal)

- Menggunakan `Provider<ActivityApiService>` untuk akses ke data aktivitas
- Menerapkan `RefreshIndicator` untuk pembaruan manual
- Menggunakan `Consumer` untuk mendengarkan pembaruan data dari API service
- Memanfaatkan parameter `forceRefresh` untuk kontrol caching

### TaskListScreen (Tugas)

- Menggunakan `Provider<TaskApiService>` untuk akses ke data tugas
- Menerapkan `RefreshIndicator` untuk pembaruan manual
- Menggunakan `Consumer` untuk mendengarkan pembaruan data dari API service
- Memanfaatkan parameter `forceRefresh` untuk kontrol caching

## Panduan Troubleshooting

### 1. Data Tidak Diperbarui Setelah Operasi CRUD

Jika UI tidak menampilkan data terbaru setelah operasi CRUD:

- Pastikan `_markDataChanged()` dipanggil setelah operasi CRUD berhasil
- Verifikasi bahwa `notifyListeners()` dipanggil setelah state diperbarui
- Periksa bahwa semua cache terkait dihapus dengan benar

### 2. Cache Tidak Berfungsi

Jika aplikasi selalu mengambil data dari server:

- Periksa implementasi `isCacheValid()` dan kondisi penggunaannya
- Verifikasi bahwa data disimpan ke cache dengan benar
- Periksa pengaturan `maxAge` pada cache

### 3. Kinerja Buruk

Jika aplikasi masih lambat meskipun menggunakan cache:

- Identifikasi bottleneck dengan profiling
- Periksa efisiensi transformasi data (dari JSON ke model dan sebaliknya)
- Pertimbangkan untuk menggunakan cache yang lebih persisten atau database lokal

## Kesimpulan

Implementasi caching pada aplikasi Aturin secara signifikan meningkatkan pengalaman pengguna dengan mengurangi loading screen dan memastikan UI diperbarui secara real-time setelah operasi CRUD. Sistem dirancang untuk menjaga keseimbangan antara kesegaran data dan kinerja aplikasi.
