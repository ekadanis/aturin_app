# Provider Setup Documentation

## Overview
Provider setup telah direfaktor dari `main.dart` ke dalam file-file terorganisir untuk meningkatkan maintainability dan struktur kode yang lebih baik.

## File Structure

### 1. `core/providers/provider_config.dart`
**Purpose**: Mengatur konfigurasi semua Provider yang diperlukan aplikasi

**Key Features**:
- `getProviders()` - Mendapatkan semua provider yang diperlukan
- `getCoreProviders()` - Provider untuk layanan inti saja
- `getApiProviders()` - Provider khusus untuk layanan API
- `getFeatureProviders()` - Provider khusus untuk layanan fitur

**Example Usage**:
```dart
final providers = ProviderConfig.getProviders(
  connectivityService: connectivityService,
);
```

### 2. `core/providers/app_providers.dart`
**Purpose**: Widget wrapper untuk mengatur semua Provider dalam aplikasi

**Key Components**:
- `AppProviders` - Widget utama untuk wrapping seluruh aplikasi
- `CoreProviders` - Widget untuk provider inti saja
- `ProviderExtensions` - Extension method untuk memudahkan akses service

**Example Usage**:
```dart
return AppProviders(
  connectivityService: connectivityService,
  child: MyAppContent(),
);
```

### 3. `core/providers/provider_registry.dart`
**Purpose**: Registry untuk mengelola dan mengakses semua service dari context

**Key Features**:
- Static methods untuk mengakses setiap service
- Error handling untuk setiap service access
- Generic methods `watchService<T>()` dan `readService<T>()`
- Method `hasService<T>()` untuk mengecek ketersediaan service

**Example Usage**:
```dart
// Akses GlobalStateService
final globalState = ProviderRegistry.getGlobalStateService(context);

// Akses generic service
final authService = ProviderRegistry.readService<AuthService>(context);

// Watch service for updates
final connectivity = ProviderRegistry.watchService<ConnectivityService>(context);
```

### 4. `core/providers/index.dart`
**Purpose**: Barrel file untuk export semua provider-related classes

**Usage**:
```dart
import 'package:aturin_app/core/providers/index.dart';
```

## Providers List

### Core Services
1. **ConnectivityService** - Mengelola status koneksi internet
2. **GlobalStateService** - State management global untuk sinkronisasi data

### Authentication & User Management
3. **AuthService** - Layanan autentikasi pengguna
4. **ProfileService** - Layanan profil pengguna

### Task Management Services
5. **TaskService** (from features/task) - Backward compatibility
6. **TaskApiService** - API service untuk task management

### Activity Management Services
7. **ActivityApiService** - API service untuk activity management
8. **AktivitasService** - Service untuk aktivitas/jadwal

### Home Services
9. **HomeService** - Unified service untuk halaman home

## Migration Guide

### Before (main.dart):
```dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider<ConnectivityService>.value(value: connectivityService),
    ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
    // ... many more providers
  ],
  child: MyApp(),
);
```

### After (main.dart):
```dart
return AppProviders(
  connectivityService: connectivityService,
  child: MyApp(),
);
```

## Benefits

1. **Better Organization**: Provider setup terpisah dari main.dart
2. **Maintainability**: Mudah menambah/menghapus provider
3. **Flexibility**: Bisa menggunakan subset provider sesuai kebutuhan
4. **Type Safety**: Registry memberikan type-safe access ke services
5. **Error Handling**: Built-in error handling untuk service access
6. **Documentation**: Setiap provider terdokumentasi dengan baik

## Best Practices

1. **Use ProviderRegistry**: Gunakan registry untuk akses service yang type-safe
2. **Use Extensions**: Manfaatkan extension methods untuk akses yang lebih mudah
3. **Specific Providers**: Gunakan CoreProviders atau subset lain jika tidak perlu semua provider
4. **Error Handling**: Selalu handle error saat mengakses service
5. **Listen Strategy**: Gunakan `watchService()` jika perlu listen, `readService()` jika tidak

## Integration with GlobalStateService

Provider setup ini sudah terintegrasi dengan `GlobalStateService` untuk:
- Automatic data synchronization
- Cached data management
- Real-time updates across screens
- Unified state management

## Usage Examples

### Accessing Services in Widgets
```dart
// Method 1: Using ProviderRegistry
final globalState = ProviderRegistry.getGlobalStateService(context);

// Method 2: Using Consumer
Consumer<GlobalStateService>(
  builder: (context, globalState, child) {
    return Text('Tasks: ${globalState.todayTasksCount}');
  },
)

// Method 3: Using Extension
final authService = context.readService<AuthService>();
```

### Adding New Provider
1. Add service import to `provider_config.dart`
2. Add ChangeNotifierProvider to appropriate method
3. Add static method to `provider_registry.dart`
4. Update documentation

This refactored setup provides a solid foundation for scalable Provider management in the Aturin app.
