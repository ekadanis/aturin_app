# Home Screen Widget Implementation

## Overview
Home Widget untuk aplikasi Aturin yang menampilkan jadwal aktivitas dan tugas hari ini langsung di layar utama ponsel.

## Fitur
- Menampilkan maksimal 3 item jadwal hari ini
- Menunjukkan aktivitas dan tugas yang akan datang
- Update otomatis setiap 15 menit
- Tampilan kosong ketika tidak ada jadwal
- Click untuk membuka aplikasi

## Struktur File

### Flutter (Dart)
```
lib/
├── features/
│   └── home/
│       ├── services/
│       │   └── home_widget_service.dart      # Service utama widget
│       ├── providers/
│       │   └── home_widget_provider.dart     # State management
│       └── widgets/
│           └── home_widget_control_card.dart # UI kontrol widget
```

### Android (Kotlin)
```
android/app/src/main/
├── kotlin/com/example/aturin_app/
│   └── AturinAppHomeWidget.kt                # Widget provider
├── res/
│   ├── layout/
│   │   └── aturin_app_home_widget.xml        # Layout widget
│   ├── drawable/
│   │   ├── widget_background.xml             # Background widget
│   │   ├── item_indicator.xml                # Indikator item
│   │   ├── category_background.xml           # Background kategori
│   │   ├── ic_task.xml                       # Icon tugas
│   │   ├── ic_activity.xml                   # Icon aktivitas
│   │   ├── ic_event_note.xml                 # Icon kosong
│   │   └── app_icon.xml                      # Icon aplikasi
│   ├── values/
│   │   └── strings.xml                       # String resources
│   └── xml/
│       └── aturin_app_home_widget_info.xml   # Konfigurasi widget
```

## Cara Penggunaan

### 1. Setup Otomatis
Widget akan otomatis terinisialisasi ketika aplikasi dimulai.

### 2. Kontrol Manual
Di halaman Home, akan muncul card "Home Screen Widget" untuk:
- Setup widget pertama kali
- Update manual widget
- Melihat status widget
- Troubleshooting

### 3. Menambah Widget ke Home Screen

#### Android:
1. Tekan dan tahan pada layar utama
2. Pilih "Widget" dari menu
3. Cari "Aturin" dalam daftar widget
4. Drag widget ke layar utama
5. Widget akan menampilkan jadwal hari ini

## Update Mechanism

### Otomatis
- Widget update setiap 15 menit
- Update ketika data aktivitas/tugas berubah
- Update ketika aplikasi dibuka

### Manual
- Tombol "Perbarui Widget" di card kontrol
- Force refresh untuk testing

## Data Yang Ditampilkan

### Format Data
- **Aktivitas**: Judul, waktu mulai, kategori
- **Tugas**: Judul, deadline, kategori, status completed

### Urutan
- Diurutkan berdasarkan waktu (earliest first)
- Maksimal 3 item ditampilkan
- Jika kosong, menampilkan pesan "Tidak ada jadwal"

## Troubleshooting

### Widget Tidak Muncul
1. Pastikan aplikasi sudah dijalankan minimal 1 kali
2. Check card kontrol di Home screen
3. Klik "Setup Widget" jika belum diinisialisasi

### Data Tidak Update
1. Klik "Perbarui Widget" di card kontrol
2. Buka aplikasi untuk trigger update
3. Check koneksi internet

### Widget Error
1. Lihat pesan error di card kontrol
2. Restart aplikasi
3. Re-add widget di home screen

## Technical Details

### Data Storage
- Menggunakan SharedPreferences melalui `home_widget` package
- Data disimpan dalam format JSON dan individual fields
- Maksimal 5 item slot (hanya 3 yang ditampilkan)

### Performance
- Update minimal 15 menit interval
- Async loading data
- Background update tanpa blocking UI

### Permissions
- Tidak memerlukan permission khusus
- Menggunakan existing internet permission

## Development Notes

### Testing
```dart
// Test widget update
final provider = context.read<HomeWidgetProvider>();
await provider.forceRefresh();

// Check widget data
final data = await provider.homeWidgetService.getWidgetData();
print(data);
```

### Debugging
- Check console untuk log `🏠 HomeWidget:`
- Gunakan card kontrol untuk monitoring
- Widget error ditampilkan di card

### Customization
- Ubah `sectionTimeConfig` untuk waktu sections
- Modify layout di `aturin_app_home_widget.xml`
- Customize style di drawable resources

## Future Enhancements
- iOS widget support (WidgetKit)
- Multiple widget sizes
- Custom widget categories
- Dark mode support
- Notification integration
