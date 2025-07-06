# Implementasi Caching di Aturin App

Dokumen ini menjelaskan implementasi caching di aplikasi Aturin untuk mengurangi loading screen dan meningkatkan performa aplikasi.

> **PENTING**: Jika data tidak muncul setelah menambah tugas baru, gunakan fitur **Pull-to-Refresh** dengan menarik layar ke bawah untuk memperbarui data secara paksa dari server.

## Pendahuluan

Aplikasi Aturin sekarang menggunakan sistem caching yang memungkinkan data tetap tersimpan secara lokal dan hanya memuat data dari server saat diperlukan. Implementasi ini menggunakan `flutter_cache_manager` untuk menyimpan dan mengelola cache.

## Keuntungan Caching

- Mengurangi loading screen yang tidak perlu
- Aplikasi lebih responsif dengan menampilkan data dari cache terlebih dahulu
- Mengurangi beban pada server dan konsumsi data pengguna
- Aplikasi tetap berfungsi saat koneksi internet tidak stabil atau lambat

## Cara Kerja

1. **Kelas CacheService**
   - Bertanggung jawab untuk menyimpan dan mengambil data dari cache
   - Menggunakan `DefaultCacheManager` dari package `flutter_cache_manager`
   - Menyediakan metode-metode untuk menyimpan, mengambil, dan menghapus cache

2. **Integrasi dengan API Service**
   - Setiap API service (contoh: TaskApiService) menggunakan CacheService
   - Saat mengambil data, service pertama memeriksa apakah data tersedia di cache
   - Jika data tersedia dan masih valid (belum expired), service menggunakan data dari cache
   - Jika tidak ada cache atau cache sudah expired, service mengambil data dari server dan memperbarui cache

3. **Deteksi Perubahan Data**
   - Saat ada operasi CRUD (Create, Read, Update, Delete), data di cache ditandai sebagai "berubah"
   - Cache yang terkait dengan data tersebut dihapus untuk memastikan data yang ditampilkan selalu yang terbaru

4. **Optimisasi UI**
   - Komponen UI seperti TaskListView hanya menampilkan loading screen saat data belum tersedia
   - Saat data sudah ada (dari cache atau server), UI langsung menampilkan data tanpa loading screen

## Implementasi di Kode

### CacheService

```dart
class CacheService {
  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  
  factory CacheService() {
    return _instance;
  }
  
  // Menyimpan data ke cache
  Future<void> saveData({
    required String key, 
    required dynamic data,
    Duration? maxAge,
  }) async { ... }
  
  // Mengambil data dari cache
  Future<dynamic> getData(String key) async { ... }
  
  // Mengecek apakah cache valid
  Future<bool> isCacheValid(String key) async { ... }
  
  // Metode-metode lain untuk pengelolaan cache
}
```

### Penggunaan di TaskApiService

```dart
Future<List<Task>> getAllTasks() async {
  // Periksa apakah data sudah ada di cache
  if (!_dataChanged && await _cacheService.isCacheValid(_allTasksCacheKey)) {
    // Gunakan data dari cache jika tersedia
    final cachedData = await _cacheService.getData(_allTasksCacheKey);
    if (cachedData != null) {
      return List<Task>.from(cachedData.map((e) => Task.fromMap(e)));
    }
  }
  
  // Jika tidak ada cache, ambil dari server dan simpan ke cache
  final response = await http.get(...);
  if (response.statusCode == 200) {
    // Simpan ke cache
    await _cacheService.saveData(
      key: _allTasksCacheKey, 
      data: tasks,
      maxAge: const Duration(minutes: 5),
    );
    
    return tasks;
  }
}
```

## Best Practices

1. **Durasi Cache yang Tepat**
   - Set durasi cache sesuai dengan seberapa sering data berubah
   - Data yang jarang berubah bisa memiliki durasi cache yang lebih panjang

2. **Invalidasi Cache**
   - Hapus cache terkait saat ada operasi CRUD
   - Gunakan metode `_markDataChanged()` untuk menandai bahwa data telah berubah

3. **Loading Indicator yang Cerdas**
   - Tampilkan loading indicator hanya saat benar-benar diperlukan
   - Gunakan shimmer effect untuk UI yang lebih baik saat loading

4. **Pemantauan Penggunaan Cache**
   - Tambahkan log debugging untuk memantau penggunaan cache
   - Gunakan `debugPrint('🗄️ Cache: ...')` untuk memudahkan identifikasi log terkait cache

## Troubleshooting

1. **Data tidak update setelah perubahan**
   - Pastikan cache dibersihkan setelah operasi CRUD
   - Periksa apakah metode `_markDataChanged()` dipanggil

2. **Cache terlalu lama/cepat expired**
   - Sesuaikan nilai `_cacheValidityDuration` di TaskApiService

3. **Penggunaan memori berlebih**
   - Gunakan metode `clearCache()` secara berkala untuk membersihkan cache lama
   - Pastikan ukuran data yang di-cache tidak terlalu besar

## Kesimpulan

Dengan implementasi caching ini, aplikasi Aturin menjadi lebih responsif dan efisien. Loading screen hanya muncul saat benar-benar dibutuhkan, membuat pengalaman pengguna lebih baik dan mulus.
