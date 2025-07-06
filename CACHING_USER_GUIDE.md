# Implementasi Caching di Aplikasi Aturin

Dokumen ini menjelaskan implementasi caching pada aplikasi Aturin untuk mengurangi loading screen dan mempercepat pengalaman pengguna.

## Prinsip Dasar Caching

1. **Cache First, Network Second**: Aplikasi akan mencoba mengambil data dari cache terlebih dahulu sebelum memanggil API.
2. **Invalidasi Cache**: Cache akan diinvalidasi (dihapus) saat terjadi operasi CRUD untuk memastikan data selalu terbaru.
3. **Transparansi**: Pengguna tidak perlu mengetahui dari mana data berasal (cache atau API).
4. **Kesegarkan Data**: Pengguna dapat memaksa refresh data kapan saja dengan melakukan "pull-to-refresh".

## Implementasi di TaskApiService dan ActivityApiService

Kedua service mengimplementasikan pola caching yang sama:

1. **Cek Cache Sebelum API**: Setiap metode fetch memeriksa ketersediaan data di cache terlebih dahulu.
2. **Parameter ForceRefresh**: Semua metode fetch memiliki parameter `forceRefresh` untuk memaksa mengambil data dari API.
3. **Flag _dataChanged**: Service menggunakan flag `_dataChanged` untuk menandai apakah data telah berubah dan cache harus diperbarui.
4. **Invalidasi Cache**: Setelah operasi create/update/delete, cache akan diinvalidasi dan data diambil ulang dari server.

## Penggunaan di UI

1. **Loading Minimal**: Loading screen hanya ditampilkan jika tidak ada data sama sekali di cache.
2. **Pull-to-Refresh**: Pengguna dapat memperbarui data dengan pull-to-refresh, yang akan memaksa mengambil data terbaru dari server.
3. **Real-time Updates**: Setelah operasi CRUD, UI akan otomatis diperbarui dengan data terbaru.

## Contoh Alur

### Alur Normal (Data di Cache)

1. Pengguna membuka halaman
2. Aplikasi mengambil data dari cache
3. UI langsung menampilkan data tanpa loading screen
4. Di background, aplikasi memeriksa apakah ada pembaruan dari server

### Alur CRUD

1. Pengguna melakukan operasi CRUD
2. Service mengirim permintaan ke server
3. Service menandai `_dataChanged = true` dan menghapus cache terkait
4. Service memuat ulang data dari server
5. UI diperbarui dengan data terbaru

## Keuntungan

1. **Kecepatan**: UI menampilkan data secara instan dari cache
2. **Pengalaman offline**: Data tetap tersedia meskipun koneksi terputus
3. **Efisiensi bandwidth**: Mengurangi panggilan API yang tidak perlu
4. **UI Responsif**: Tidak ada loading screen yang mengganggu jika sudah ada data

## Pedoman Pengembangan

1. Selalu gunakan parameter `forceRefresh` untuk kontrol caching yang lebih baik
2. Pastikan panggil `_markDataChanged()` setelah operasi CRUD
3. Gunakan `RefreshIndicator` untuk memungkinkan pengguna memperbarui data secara manual
4. Pastikan UI menggunakan data dari Provider dan tidak langsung memanggil API

## Troubleshooting

Jika data tidak diperbarui secara real-time setelah operasi CRUD:

1. Periksa apakah `_markDataChanged()` dipanggil
2. Pastikan metode delete/update/create memanggil fetchXXX dengan `forceRefresh = true`
3. Periksa apakah UI menggunakan Consumer yang benar untuk mendapatkan data terbaru
