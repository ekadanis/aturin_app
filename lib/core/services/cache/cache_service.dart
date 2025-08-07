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
    } catch (e) {
    }
  }
  
  /// Mengambil data dari cache berdasarkan key
  Future<dynamic> getData(String key) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(key);
      if (fileInfo == null) {
        return null;
      }
      
      final file = fileInfo.file;
      final content = await file.readAsString();
      final data = jsonDecode(content);
      
      return data;
    } catch (e) {
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
  }
  
  /// Menghapus beberapa cache berdasarkan daftar keys
  Future<void> removeMultipleData(List<String> keys) async {
    for (String key in keys) {
      await _cacheManager.removeFile(key);
    }
  }
  
  /// Membersihkan semua cache CacheManager
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
  
  /// Membersihkan semua cache aplikasi (hanya CacheManager)
  Future<void> clearAll() async {
    await _cacheManager.emptyCache();
  }
}