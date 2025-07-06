# 🔧 Widget Troubleshooting Guide

Panduan ini akan membantu Anda menyelesaikan masalah yang umum terjadi dengan Home Widget di aplikasi Aturin.

## 📱 Masalah Umum dan Solusinya

### Widget Menampilkan "Tidak dapat memuat widget"

**Penyebab Potensial:**
1. Data tidak tersimpan dengan benar di SharedPreferences
2. Widget belum terinisialisasi oleh aplikasi
3. Terjadi error saat memuat data
4. Package name di Android tidak sesuai

**Solusi:**
1. **Clean Install Aplikasi:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Force Refresh Widget dari Dalam App:**
   - Buka aplikasi Aturin
   - Navigasikan ke halaman Home
   - Temukan card "Home Screen Widget"
   - Tekan tombol "Perbarui Widget"

3. **Hapus dan Tambahkan Kembali Widget:**
   - Tekan lama pada widget di home screen
   - Pilih "Remove" atau "Hapus"
   - Buka app Aturin
   - Tekan tombol "Setup Widget" di card kontrol
   - Tambahkan widget baru ke home screen

4. **Clear App Data (Jika masalah berlanjut):**
   - Buka Settings di Android
   - Cari "Apps" atau "Applications"
   - Pilih Aturin
   - Pilih "Storage & cache"
   - Tekan "Clear Storage" dan "Clear Cache"
   - Buka kembali app dan setup widget

### Widget Tetap Menampilkan "Tidak dapat memuat widget" Meskipun Data Berhasil Diambil

**Penyebab Potensial:**
1. Widget belum terinisialisasi sepenuhnya
2. Ada masalah dengan tampilan widget di launcher
3. Cache launcher belum diperbarui
4. Widget membutuhkan waktu untuk menampilkan update terbaru

**Solusi:**
1. **Force Restart Launcher:**
   - Tekan tombol Home di perangkat
   - Buka Recent Apps (multitasking view)
   - Tutup aplikasi launcher (swipe up)
   - Tekan Home lagi untuk memulai ulang launcher
   
2. **Reset Widget Completely:**
   - Hapus widget dari home screen
   - Restart device
   - Buka aplikasi Aturin
   - Tekan tombol "Setup Widget" di card kontrol
   - Tambahkan widget baru ke home screen

3. **Ubah Ukuran Widget:**
   - Tekan lama pada widget
   - Pilih opsi resize/resize handle
   - Ubah ukuran widget sedikit lebih besar
   - Kemudian kembalikan ke ukuran semula

4. **Periksa Kompatibilitas Launcher:**
   - Beberapa launcher custom mungkin tidak mendukung widget penuh
   - Coba gunakan launcher default jika menggunakan launcher pihak ketiga

5. **Tunggu Beberapa Menit:**
   - Pada beberapa perangkat, widget memerlukan waktu hingga 15 menit untuk refresh penuh

### Widget Tidak Update Otomatis

**Penyebab Potensial:**
1. Batasan background process di perangkat
2. Fitur battery optimization menghalangi update
3. Permission untuk background process tidak diberikan

**Solusi:**
1. **Nonaktifkan Battery Optimization:**
   - Buka Settings Android
   - Cari "Battery" atau "Battery Optimization"
   - Cari aplikasi Aturin
   - Pilih "Don't optimize"

2. **Update Manual:**
   - Buka aplikasi Aturin secara reguler
   - Gunakan tombol "Perbarui Widget" jika diperlukan

3. **Restart Device:**
   - Terkadang restart device dapat memperbaiki masalah update widget

### Widget Error dengan Pesan Stack Trace

**Penyebab:**
Error saat memproses atau menampilkan data

**Solusi:**
1. **Debug Mode:**
   - Check konsol untuk log error yang detail
   - Cari pesan error yang spesifik

2. **Reset Widget:**
   - Hapus widget dari home screen
   - Buka aplikasi dan tekan "Setup Widget" kembali
   - Tambahkan widget baru ke home screen

3. **Bersihkan Data Aplikasi:**
   - Gunakan tombol "Clear Data" di pengaturan aplikasi

### Widget Tidak Merespons Sentuhan atau Klik

**Penyebab Potensial:**
1. PendingIntent tidak terdaftar dengan benar
2. Masalah permission pada launcher
3. Konflik dengan aplikasi lain

**Solusi:**
1. **Restart Aplikasi:**
   - Tutup aplikasi Aturin sepenuhnya
   - Buka kembali dan tekan tombol "Perbarui Widget"
   
2. **Update Widget dari Settings:**
   - Buka Settings di Android
   - Cari "Widgets" atau "Home screen widgets"
   - Pilih widget Aturin
   - Tekan "Update" atau "Force update" jika tersedia

3. **Reinstall Aplikasi:**
   - Backup data aplikasi jika diperlukan
   - Uninstall aplikasi
   - Install ulang aplikasi
   - Setup widget kembali

## 🛠️ Langkah-Langkah Fix Teknis

Jika Anda merupakan developer atau pengguna teknis, berikut adalah langkah-langkah perbaikan yang lebih spesifik:

### Masalah: Widget Tidak Dapat Memuat Data

**Solusi Teknis:**
1. **Clean Build & Reinstall:**
   ```bash
   cd <project_directory>
   flutter clean
   flutter pub get
   flutter build apk --debug
   flutter install
   ```

2. **Restart System Services:**
   ```bash
   adb shell am force-stop com.AturinJaya.pdbl
   adb shell am kill com.AturinJaya.pdbl
   adb shell am broadcast -a android.intent.action.BOOT_COMPLETED
   ```

3. **Debug Widget dengan Logs:**
   ```bash
   adb logcat -s AturinAppHomeWidget:D
   ```

### Masalah: Widget Menampilkan Text Tapi Tidak Terbaca

**Solusi Teknis:**
1. Pastikan file `AturinAppHomeWidget.kt` menggunakan layout yang memadai:
   ```kotlin
   val views = RemoteViews(context.packageName, android.R.layout.simple_expandable_list_item_2)
   ```

2. Pastikan warna teks di-set dengan eksplisit:
   ```kotlin
   views.setTextColor(android.R.id.text1, android.graphics.Color.BLACK)
   views.setTextColor(android.R.id.text2, android.graphics.Color.DKGRAY)
   ```

3. Pastikan ukuran teks cukup besar:
   ```kotlin
   views.setTextViewTextSize(android.R.id.text1, android.util.TypedValue.COMPLEX_UNIT_SP, 16f)
   views.setTextViewTextSize(android.R.id.text2, android.util.TypedValue.COMPLEX_UNIT_SP, 14f)
   ```

4. Jika masih tidak terlihat, coba gunakan layout custom:
   ```xml
   android:initialLayout="@layout/aturin_app_home_widget"
   ```

## 🔍 Verifikasi Widget Berfungsi

### Test Widget Data

Untuk memverifikasi data yang digunakan widget:

1. Buka aplikasi Aturin
2. Di halaman Home, perhatikan info di card "Home Screen Widget":
   - Waktu update terakhir
   - Jumlah aktivitas dan tugas

3. Jika data terlihat benar di card kontrol tapi tidak di widget, coba:
   - Perbarui widget dengan tombol di card
   - Hapus dan tambahkan kembali widget

### Debug Output

Untuk developer, check output debug dengan filter `🏠 HomeWidget:` di konsol untuk mendapatkan informasi lebih detail tentang apa yang terjadi dengan widget.

## 📋 Checklist Troubleshooting

- [ ] App dijalankan minimal satu kali setelah instalasi
- [ ] Widget control card menampilkan status "Aktif"
- [ ] Tombol "Perbarui Widget" sudah ditekan
- [ ] Widget dihapus dan ditambahkan kembali
- [ ] App cache dibersihkan
- [ ] Device direstart
- [ ] Battery optimization dinonaktifkan

## 🔄 Kapan Widget Diperbarui?

- Setiap kali aplikasi dibuka
- Setiap 30 menit (jika device memungkinkan)
- Ketika ada perubahan pada data aktivitas atau tugas
- Secara manual dengan tombol "Perbarui Widget"

## 🆘 Masih Bermasalah?

Jika setelah mencoba semua solusi di atas widget masih tidak berfungsi:

1. Pastikan perangkat Android Anda mendukung widgets
2. Check apakah ada launcher khusus yang mungkin tidak mendukung widget
3. Verifikasi perangkat menggunakan Android versi 5.0 atau lebih baru
4. Pada beberapa perangkat, widget perlu waktu hingga beberapa menit untuk menampilkan data setelah ditambahkan

Berhasil menyelesaikan masalah yang tidak ada dalam guide ini? Silakan berkontribusi untuk memperbaiki dokumentasi ini!
