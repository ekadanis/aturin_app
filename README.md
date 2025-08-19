# Aturin App 📱

**Aturin** adalah aplikasi manajemen jadwal dan tugas yang membantu Anda mengatur aktivitas harian dengan mudah dan efisien. Dengan fitur notifikasi cerdas, widget native Android, dan sinkronisasi real-time, Aturin memastikan Anda tidak akan melewatkan aktivitas penting.

## 🎯 Description

Aturin App dirancang untuk mengatasi tantangan dalam mengelola jadwal dan tugas harian. Aplikasi ini menyediakan solusi lengkap dengan interface yang intuitif, sistem notifikasi yang dapat disesuaikan, dan integrasi dengan widget Android untuk akses cepat ke jadwal Anda.

**Mengapa Aturin?**
- Meningkatkan produktivitas dengan reminder yang tepat waktu
- Menyediakan overview lengkap aktivitas harian
- Memungkinkan kategorisasi aktivitas yang fleksibel

## ✨ Features

### 🔐 **Authentication & User Management**
- Login dengan email/password dan Google Sign-In
- Sistem registrasi dengan validasi yang robust
- Password reset dengan email verification
- Profile management dengan avatar customization

### 📅 **Schedule & Task Management**
- Buat, edit, dan hapus aktivitas/tugas
- Kategorisasi aktivitas (Akademik, Hiburan, Pekerjaan, Olahraga, dll.)
- Timeline view untuk melihat jadwal harian
- Status tracking (Pending, In Progress, Completed, Late)

### 🔔 **Smart Notifications**
- Alarm kustom untuk setiap aktivitas
- Notifikasi push menggunakan Firebase Cloud Messaging (FCM)
- Background service untuk notifikasi yang handal
- Global alarm enable/disable setting

### 📱 **Native Android Widget**
- Home screen widget menampilkan jadwal hari ini
- Auto-update widget setiap tengah malam
- Quick access ke aplikasi dari widget
- Responsive design untuk berbagai ukuran widget

### 🌐 **Connectivity & Sync**
- Real-time sync dengan Laravel backend
- Offline mode dengan local database
- Connectivity status monitoring
- Auto-retry mekanisme untuk failed requests

### 🎨 **User Experience**
- Modern Material Design UI
- Dark/Light theme support
- Interactive calendar view
- Smooth animations dan transitions
- Responsive design untuk berbagai ukuran layar

## 🛠️ Tech Stack

### **Frontend (Flutter)**
- **Framework**: Flutter 3.24.3 / Dart 3.5.3
- **State Management**: Provider pattern
- **Routing**: Auto Route
- **UI Components**: Material Design 3, Google Fonts, Sizer
- **Local Storage**: SharedPreferences,
- **Animations**: Flutter built-in animations

### **Backend Integration**
- **API**: Laravel RESTful API
- **Authentication**: JWT Bearer Token
- **File Upload**: HTTP multipart requests
- **Real-time**: Polling-based updates

### **Firebase Services**
- **Cloud Messaging (FCM)**: Push notifications
- **Authentication**: Google Sign-In integration

### **Native Android**
- **Widget**: AppWidgetProvider with RemoteViews
- **Background Services**: WorkManager untuk scheduled tasks
- **Local Notifications**: Android AlarmManager integration

### **Development Tools**
- **IDE**: Android Studio / VS Code
- **Version Control**: Git dengan conventional commits
- **Build System**: Gradle
- **Testing**: Flutter integration tests

## 📋 Installation

### **Prerequisites**
- Flutter SDK (>= 3.24.3)
- Dart SDK (>= 3.5.3)
- Android Studio / VS Code
- Android SDK (minSdkVersion 21, targetSdkVersion 34)
- Git

### **Step-by-step Setup**

1. **Clone Repository**
   ```bash
   git clone https://github.com/ekadanis/aturin_app.git
   cd aturin_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Download `google-services.json` dari Firebase Console
   - Place file ke `android/app/google-services.json`
   - Pastikan package name sesuai: `com.AturinJaya.pdbl`

4. **Configure Android**
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   ```

5. **Run Application**
   ```bash
   flutter run --debug
   ```

## 🚀 Usage

### **Basic Usage**

1. **First Time Setup**
   - Daftar akun baru atau login dengan Google
   - Atur preferensi user (jam tidur, target frequency, dll.)
   - Grant permission untuk notifikasi

2. **Membuat Aktivitas**
   - Tap tombol "+" di bottom navigation
   - Pilih kategori aktivitas
   - Set tanggal, waktu, dan alarm
   - Save aktivitas

3. **Mengelola Jadwal**
   - Lihat timeline aktivitas di Home page
   - Switch antara view "Tugas" dan "Aktivitas"
   - Mark tugas sebagai completed
   - Edit/delete aktivitas yang ada

4. **Menggunakan Widget**
   - Long press di home screen Android
   - Pilih "Widgets" → "Aturin"
   - Drag widget ke home screen
   - Widget akan otomatis menampilkan jadwal hari ini

### **Advanced Features**

- **Bulk Operations**: Select multiple tasks untuk batch actions
- **Categories**: Customize kategori sesuai kebutuhan
- **Notifications**: Fine-tune notification settings
- **Sync**: Manual sync dengan pull-to-refresh


## 🏗️ Project Structure

```
aturin_app/
├── 
├── 📁 assets/                            # Static assets
│   ├── images/                           # App images & illustrations
│   ├── icons/                            # SVG icons & app icons
│   ├── audio/                            # Audio files (alarms, etc.)
│   ├── avatars/                          # User avatar images
│   ├── onboarding/                       # Onboarding assets
│   └── font/                             # Custom fonts
├── 🧪 test/                              # Test files
│   ├── unit/                             # Unit tests
│   ├── integration/                      # Integration tests
│   └── widget/                           # Widget tests
├── 📚 lib/                               # Main Dart code
│   ├── main.dart                         # 🚀 Entry point aplikasi
│   ├── my_app.dart                       # ⚙️ App configuration & themes
│   ├── app/                              # 📱 App-level components
│   │   └── bottom_navbar.dart            # Main navigation bar
│   ├── features/                         # 🎯 Feature-based modules
│   │   ├── alarm/                        # ⏰ Alarm management
│   │   │   ├── data/                     # Data layer (models, databases)
│   │   │   ├── presentation/             # UI layer (screens, widgets)
│   │   │   └── services/                 # Business logic
│   │   ├── animated_splash_screen/       # 🎬 Splash screen
│   │   ├── auth/                         # 🔐 Authentication (legacy)
│   │   ├── device/                       # 📱 Device & FCM management
│   │   │   ├── models/                   # Device models
│   │   │   ├── services/                 # Device services
│   │   │   └── widgets/                  # Device-related widgets
│   │   ├── home/                         # 🏠 Home dashboard
│   │   │   ├── presentation/
│   │   │   │   ├── screens/              # Home screens
│   │   │   │   ├── widgets/              # Home widgets
│   │   │   │   └── providers/            # Home state management
│   │   │   └── ui/                       # UI components
│   │   ├── login/                        # 🔑 Login functionality
│   │   │   └── presentation/
│   │   │       ├── screens/              # Login screens
│   │   │       └── widgets/              # Login widgets
│   │   ├── onboarding/                   # 👋 User onboarding
│   │   ├── password_reset/               # 🔄 Password recovery
│   │   ├── profile/                      # 👤 User profile
│   │   │   ├── data/models/              # User data models
│   │   │   ├── models/                   # Profile models
│   │   │   ├── presentation/             # Profile UI
│   │   │   └── ui/                       # Profile components
│   │   ├── register/                     # 📝 User registration
│   │   ├── schedule/                     # 📅 Schedule management
│   │   │   ├── data/                     # Schedule data layer
│   │   │   ├── domain/                   # Business logic
│   │   │   └── presentation/             # Schedule UI
│   │   ├── task/                         # ✅ Task management
│   │   │   ├── data/                     # Task data & models
│   │   │   ├── presentation/             # Task UI & services
│   │   │   └── screens/                  # Task screens
│   │   ├── user_preference/              # ⚙️ User settings
│   │   └── widget_aturin/                # 📱 Native widget integration
│   │       ├── services/                 # Widget services
│   │       └── widgets/                  # Widget components
│   ├── shared/                           # 🔗 Shared components
│   │   ├── core/                         # 🏗️ Core utilities
│   │   │   ├── constant/                 # App constants & themes
│   │   │   ├── database/                 # Database configurations
│   │   │   ├── infrastructure/           # Routing, DI, etc.
│   │   │   ├── initialization/           # App initialization
│   │   │   ├── providers/                # Global state management
│   │   │   └── services/                 # Core services
│   │   │       ├── api/                  # API services
│   │   │       │   ├── auth/             # Authentication API
│   │   │       │   ├── activities/       # Activities API
│   │   │       │   ├── profile/          # Profile API
│   │   │       │   └── task/             # Task API
│   │   │       ├── connectivity/         # Network connectivity
│   │   │       └── widgets/              # Widget services
│   │   ├── extensions/                   # Dart extensions
│   │   ├── helpers/                      # Helper utilities
│   │   ├── screens/                      # Shared screens
│   │   ├── utils/                        # Utility functions
│   │   └── widgets/                      # 🧩 Reusable UI components
│   └── core/                             # Legacy core (deprecated)
├─

### 📂 **Key Directory Explanations**

#### **🎯 `/lib/features/`** - Feature-based Architecture
Setiap feature memiliki struktur yang konsisten:
- **`data/`** - Models, repositories, data sources
- **`domain/`** - Business logic, use cases, entities
- **`presentation/`** - UI components, screens, state management

#### **🔗 `/lib/shared/`** - Shared Resources
- **`core/services/api/`** - HTTP clients, API endpoints
- **`core/providers/`** - Global state management (Provider pattern)
- **`core/infrastructure/`** - Routing (AutoRoute), dependency injection
- **`widgets/`** - Reusable UI components across features

#### **📱 `/android/`** - Android Native
- **`app/src/main/kotlin/`** - Native Android code (Widget implementation)
- **`app/src/main/res/`** - Android resources (layouts, drawables, strings)
- **`app/google-services.json`** - Firebase configuration

#### **📁 `/assets/`** - Static Assets
- **Organized by type** - images, icons, audio, fonts
- **Used by Flutter** - configured in `pubspec.yaml`

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📦 Build & Deployment

### **Debug Build**
```bash
flutter build apk --debug
```

### **Release Build**
```bash
flutter build apk --release
flutter build appbundle --release  # For Play Store
```

### **Build Configuration**
- **minSdkVersion**: 21 (Android 5.0)
- **targetSdkVersion**: 34 (Android 14)
- **compileSdkVersion**: 34

## 🤝 Contributing

Kami menyambut kontribusi dari developer lain! Ikuti langkah berikut:

1. **Fork repository**
2. **Create feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit changes**
   ```bash
   git commit -m 'feat: add amazing feature'
   ```
4. **Push to branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open Pull Request**

### **Contribution Guidelines**
- Follow conventional commit format
- Write unit tests untuk new features
- Update documentation jika diperlukan
- Ensure code passes all tests
- Follow Flutter/Dart style guide

### **Conventional Commits**
```
feat: new feature
fix: bug fix
docs: documentation changes
style: formatting changes
refactor: code refactoring
test: adding tests
chore: maintenance tasks
```

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Aturin Development Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 👥 Credits & Authors

### **Development Team**
- **Mobile Developer**: Aturin Development Team
- **Backend Developer**: Laravel API Team
- **UI/UX Designer**: Aturin Design Team


### **Third-party Packages**
- `provider` - State management
- `auto_route` - Navigation
- `google_fonts` - Typography
- `sizer` - Responsive design
- `firebase_messaging` - Push notifications
- `google_sign_in` - Authentication
- `http` - API communication
- `shared_preferences` - Local storage
- `sqflite` - Local database

## 🔄 Changelog

Lihat [CHANGELOG.md](CHANGELOG.md) untuk detail perubahan setiap versi.



---

<div align="center">
  <p>Made with ❤️ by B3 Aturin Team</p>
  <p>🌟 Star this repository if you find it helpful!</p>
</div>
