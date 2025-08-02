import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

/// Service untuk mengelola caching data aplikasi
class CacheService {
  static final CacheService _instance = CacheService._internal();
  final DefaultCacheManager _cacheManager = DefaultCacheManager();
  
  // Singleton pattern
  factory CacheService() {
    return _instance;
  }
  
  CacheService._internal();
  
  /// Menyimpan data ke cache dengan key tertentu
  Future<void> saveData({
    required String key, 
    required dynamic data,
    Duration? maxAge,
  }) async {
    try {
      final String jsonData = jsonEncode(data);
      await _cacheManager.putFile(
        key, 
        Uint8List.fromList(utf8.encode(jsonData)),
        maxAge: maxAge ?? const Duration(hours: 2),
        key: key,
      );
      debugPrint('🗄️ Cache: Data tersimpan untuk key $key');
    } catch (e) {
      debugPrint('🗄️ Cache: Error menyimpan data untuk key $key: $e');
    }
  }
  
  /// Mengambil data dari cache berdasarkan key
  Future<dynamic> getData(String key) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(key);
      if (fileInfo == null) {
        debugPrint('🗄️ Cache: Cache tidak ditemukan untuk key $key');
        return null;
      }
      
      final file = fileInfo.file;
      final content = await file.readAsString();
      final data = jsonDecode(content);
      
      debugPrint('🗄️ Cache: Data berhasil diambil dari cache untuk key $key');
      return data;
    } catch (e) {
      debugPrint('🗄️ Cache: Error membaca data untuk key $key: $e');
      return null;
    }
  }
  
  /// Mengecek apakah cache dengan key tertentu valid (tidak expired)
  Future<bool> isCacheValid(String key) async {
    final fileInfo = await _cacheManager.getFileFromCache(key);
    return fileInfo != null;
  }
  
  /// Menghapus cache dengan key tertentu
  Future<void> removeData(String key) async {
    await _cacheManager.removeFile(key);
    debugPrint('🗄️ Cache: Cache dihapus untuk key $key');
  }
  
  /// Menghapus beberapa cache berdasarkan daftar keys
  Future<void> removeMultipleData(List<String> keys) async {
    for (String key in keys) {
      await _cacheManager.removeFile(key);
      debugPrint('🗑️ Cache: Cache dihapus untuk key $key');
    }
  }
  
  /// Membersihkan semua cache CacheManager
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    debugPrint('🗄️ Cache: Semua cache CacheManager dibersihkan');
  }
  
  /// Membersihkan semua cache aplikasi (hanya CacheManager)
  Future<void> clearAll() async {
    await _cacheManager.emptyCache();
    debugPrint('🧹 CacheService: Semua cache aplikasi telah dibersihkan');
  }
}