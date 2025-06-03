# DEBUG: Analisis Double Fetch pada GreetingHeader

## 🔍 Identifikasi Masalah

Berdasarkan analisis kode, ditemukan penyebab **double fetch** ketika navigasi dari halaman jadwal (AktivitasRoute) ke beranda (HomeRoute):

### 1. **Root Cause: Lifecycle HomeService**

**MASALAH UTAMA:**
- `HomeService` dibuat sebagai **singleton** melalui `ChangeNotifierProvider<HomeService>(create: (_) => HomeService())` di `main.dart`
- Dalam constructor `HomeService()`, langsung dipanggil `fetchData()` (line 80 dalam home_service.dart)
- Setiap kali halaman Home di-load, `HomePage.initState()` juga memanggil `homeService.fetchData()` (line 37 dalam home_page.dart)

### 2. **Double Fetch Scenario:**

**Skenario Navigasi: Jadwal → Beranda**
1. **Fetch #1**: Dari constructor `HomeService()` karena provider singleton
2. **Fetch #2**: Dari `HomePage.initState()` → `homeService.fetchData()`

**Timeline:**
```
[Navigation Start] AktivitasRoute → HomeRoute
├── [Provider Access] HomeService instance accessed
├── [Constructor Call] HomeService() → fetchData() ✅ FETCH #1
├── [HomePage Build] HomePage widget created
├── [initState] HomePage.initState() called
└── [Manual Call] homeService.fetchData() ✅ FETCH #2
```

### 3. **Bukti di Kode:**

**File: `lib/main.dart` (line 93)**
```dart
// Provider untuk HomeService (unified service for home page)
ChangeNotifierProvider<HomeService>(create: (_) => HomeService()),
```

**File: `lib/features/home/services/home_service.dart` (line 80)**
```dart
HomeService() {
    fetchData(); // ⚠️ AUTO FETCH #1
}
```

**File: `lib/features/home/ui/page/home_page.dart` (line 33-37)**
```dart
@override
void initState() {
    super.initState();
    homeService = Provider.of<HomeService>(context, listen: false);
    homeService.fetchData(); // ⚠️ MANUAL FETCH #2
}
```

## 🚀 Solusi yang Direkomendasikan

### Option 1: Remove Constructor Fetch (RECOMMENDED)
Hapus `fetchData()` dari constructor `HomeService` dan hanya panggil dari widget yang membutuhkan.

### Option 2: Remove Manual Fetch dari HomePage
Hapus `homeService.fetchData()` dari `HomePage.initState()` dan bergantung pada constructor fetch saja.

### Option 3: Add Fetch Guard
Tambah flag untuk mencegah fetch berulang dalam waktu singkat.

## 🎯 Implementasi Solusi

Saya akan mengimplementasikan **Option 1** karena memberikan kontrol lebih baik kepada widget untuk menentukan kapan fetch dilakukan.
