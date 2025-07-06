# Panduan Reset Widget

Jika widget menampilkan pesan "tidak dapat memuat widget" atau tidak menampilkan data yang benar, ikuti langkah-langkah ini untuk melakukan reset total:

## 1. Hapus Widget

Tekan lama widget Aturin di home screen dan pilih "Remove" atau "Hapus"

## 2. Bersihkan Data Aplikasi

1. Buka **Settings** di perangkat Android
2. Pilih **Apps** atau **Applications**
3. Cari dan pilih **Aturin**
4. Pilih **Storage & cache**
5. Tekan **Clear Cache**
6. Tekan **Clear Storage/Data**

## 3. Force Stop Launcher

1. Kembali ke **Settings** > **Apps**
2. Pilih aplikasi launcher yang Anda gunakan (misal: "Home", "One UI Home", "Launcher3", dll)
3. Tekan **Force Stop**
4. Tekan tombol **Home** untuk restart launcher

## 4. Jalankan Kembali Aplikasi

1. Buka aplikasi Aturin
2. Tunggu hingga proses inisialisasi selesai
3. Di halaman Home, lihat card "Home Screen Widget"
4. Tekan tombol "Setup Widget"

## 5. Tambahkan Widget Kembali

1. Tekan lama di area kosong di home screen
2. Pilih **Widgets**
3. Cari **Aturin**
4. Tambahkan widget ke home screen
5. Tunggu beberapa saat (hingga 1-2 menit) untuk widget ter-update

## Tambahan untuk Developer

Untuk reset lengkap, jalankan perintah berikut di terminal (memerlukan ADB):

```bash
adb shell pm clear com.AturinJaya.pdbl
adb shell am force-stop com.AturinJaya.pdbl
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED
```

Atau jalankan script `rebuild_widget.bat` untuk proses build ulang sekaligus.
