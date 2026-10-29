# Coffee Paste (mobile)

## Menjalankan

```
flutter pub get
flutter run                                   # terhubung ke backend Go (default)
flutter run --dart-define=USE_MOCK=true       # mode mock, tanpa backend
```

Alamat backend (`PORT` di `.env` backend, default 8000):

| Perangkat | Perintah |
|---|---|
| Emulator Android | `flutter run` (default `http://10.0.2.2:8000/api`) |
| HP fisik (satu Wi-Fi dengan laptop) | `flutter run --dart-define=API_BASE_URL=http://IP_LAPTOP:8000/api` |
| Produksi (Railway) | `flutter run --dart-define=API_BASE_URL=https://coffeepaste-production.up.railway.app/api` |

Mode mock: login otomatis terisi akun demo (`AppConfig.demoEmail` / `demoPassword`).

## Endpoint yang dipakai

| Fitur | Endpoint |
|---|---|
| Login / daftar / lupa password | `POST /auth/login`, `/auth/register`, `/auth/forgot-password` |
| Login Google | `POST /auth/google` (body `{"idToken": "..."}`) |
| Menu & kategori | `GET /menu`, `GET /menu/categories` |
| Pesanan | `GET /orders`, `POST /orders` (QRIS / Tunai), `POST /orders/{id}/cancel` |
| Profil & password | `GET /profile`, `PUT /profile`, `PUT /profile/password` |
| Ganti email | `POST /profile/email`, `POST /profile/email/verify`, `DELETE /profile/email` |

Hanya akun role `customer` yang bisa masuk di aplikasi. Harga dan total pesanan selalu
dihitung server (aplikasi hanya mengirim `menuItemId`, `qty`, `size`, `ice`, `sugar`).
Tautan reset password dari email terbuka di web (`FRONTEND_URL/reset-password`).

## Arsitektur data

```
UI -> Provider -> Repository (abstract) -> Mock*  atau  Api*
```

- `features/<fitur>/data/<fitur>_repository.dart` : kontrak (abstract)
- `..._mock_repository.dart` : data palsu di memori
- `..._api_repository.dart`  : memanggil backend lewat `ApiClient` (Dio)
- `core/config/app_repositories.dart` : satu-satunya tempat memilih mock/API

## Routing & sesi login

- Routing memakai `go_router` (`lib/core/router/app_router.dart`). Semua path ada di `AppRoutes`.
- Guard login ada di `AppRouter.guard`: belum login hanya boleh ke splash/login/daftar/lupa password; sudah login tidak bisa kembali ke halaman login.
- Token + profil singkat disimpan di `flutter_secure_storage` (`lib/core/storage/token_storage.dart`) dan dipulihkan saat aplikasi dibuka (`AuthProvider.restoreSession`).
- Login Google memakai `google_sign_in`: aplikasi mengirim ID token ke `POST /auth/google`, server memverifikasinya dan membalas token sesi. Setup di bagian *Login Google* di bawah.
- Email bisa diganti dari Informasi Akun: kode 6 digit dikirim ke email baru (mode mock: `123456`). Foto profil baru hanya tersimpan di perangkat.

## Pesan & bayar
- Detail produk: **Keranjang** atau **Pesan Sekarang** (langsung ke checkout).
- Checkout memilih **QRIS** atau **Tunai**. Setelah memesan, halaman pembayaran menampilkan QR QRIS (bisa discan atau diunduh ke galeri) atau pemberitahuan bayar ke kasir. Halaman memperbarui diri tiap 4 detik.
- Setelah kasir/gateway melunasi: status **Lunas**, tombol **Lihat Struk** (bisa diunduh sebagai gambar).
- **Batalkan** tersedia selama pesanan belum diproses kasir dan belum dibayar.
- Mode mock mensimulasikan pembayaran: QRIS lunas 12 detik, tunai 15 detik setelah memesan.
- Setelah `git pull`: `flutter pub get` (paket baru: qr_flutter, gal,
  path_provider, flutter_local_notifications, shared_preferences, firebase_core,
  firebase_messaging).
- Ganti password: server mencabut token lama dan mengirim token baru, yang langsung dipakai aplikasi.

## Notifikasi

Notifikasi memakai dua jalur yang saling melengkapi: **notifikasi lokal**
(`flutter_local_notifications`) untuk saat aplikasi terbuka, dan **push FCM**
(`firebase_messaging`) untuk saat aplikasi di background / sudah ditutup.

### Pengaturan & izin

- Pengaturan: **Akun -> Notifikasi**. Dua sakelar (Pesanan & Pembayaran) disimpan
  permanen di perangkat lewat `shared_preferences` (`NotificationProvider`).
- Saat sakelar dinyalakan, izin sistem (Android 13+ / iOS) diminta otomatis. Bila
  ditolak, layar menampilkan banner "Izin notifikasi dari sistem nonaktif" +
  tombol **Izinkan notifikasi**, dan statusnya dicek ulang tiap layar kembali aktif.
- Tombol **Kirim notifikasi percobaan** di layar pengaturan untuk memastikan
  notifikasi benar-benar muncul di perangkat.

### Pembagian peran lokal vs push

| Kondisi | Yang menampilkan |
| --- | --- |
| Aplikasi terbuka (foreground) | Notifikasi lokal — baik dari polling maupun dari pesan FCM yang diterima |
| Aplikasi di background / ditutup | Sistem Android/iOS (karena backend mengirim field `notification`) |
| Notifikasi disentuh pengguna | Keduanya membuka tab Pesanan |

- Perubahan yang dinotifikasi: pembayaran berubah lunas, atau status jadi
  *disiapkan / siap diambil / selesai / dibatalkan*.
- Payload `order:<id>` dan `payment:<id>` membuka tab Pesanan saat disentuh.
- Polling status pesanan dipegang `MainNavigationScreen` (berjalan selama aplikasi
  di depan, di tab mana pun; server hanya ditanya bila ada pesanan berlangsung).

### Anti-notifikasi ganda

Push dan polling bisa melaporkan perubahan yang sama, sehingga ada dua lapis
pengaman:

1. `NotificationProvider._isDuplicate` — notifikasi dengan kategori + payload +
   judul yang sama dalam 60 detik terakhir tidak dikirim ulang (berlaku untuk
   polling maupun pesan push foreground; notifikasi percobaan dikecualikan).
2. Saat pendaftaran token FCM berhasil, server membalas `{"push": true}`;
   aplikasi menyimpannya sebagai `NotificationProvider.pushEnabled`. Bila push
   aktif, penarikan ulang saat kembali dari background memakai
   `refreshSilently(notify: false)` — datanya tetap diperbarui tanpa notifikasi
   kedua, karena perubahan selama di background pasti sudah tampil sebagai push.

Bila push belum aktif (FCM belum dikonfigurasi di server / pendaftaran token
gagal), polling lokal tetap menjadi satu-satunya sumber notifikasi — tidak ada
fitur yang hilang, hanya notifikasi saat aplikasi ditutup total.

### Konfigurasi FCM

- Aplikasi: `android/app/google-services.json` dari Firebase Console
  (proyek `coffee-paste-360d5`, paket `com.coffeepaste.coffee_paste`), dibaca
  oleh plugin Gradle `com.google.gms.google-services` 4.4.2 di
  `android/settings.gradle.kts` + `android/app/build.gradle.kts`.
- Layanan aplikasi: `lib/core/notifications/push_notification_service.dart`
  (init Firebase, `onMessage` -> notifikasi lokal, `onMessageOpenedApp` /
  `getInitialMessage` -> buka tab Pesanan, `onTokenRefresh` -> daftar ulang token).
- Pendaftaran token: `POST /api/devices` dipanggil saat sesi login terbentuk dan
  saat token berubah; responsnya memberi tahu status push server.
- Server (Go): paket `internal/notif` mengirim pesan lewat Firebase Admin SDK;
  dipicu dari kasir mengubah status/menandai lunas, callback QRIS, settlement
  Midtrans, dan pembatalan dari aplikasi. Kirim selalu dilakukan latar belakang
  dan kegagalan hanya dicatat ke log (tidak pernah membatalkan request).

### Catatan Android & iOS

- `android/app/build.gradle.kts` mengaktifkan *desugaring* (`coreLibraryDesugaring`)
  — syarat wajib `flutter_local_notifications`.
- `minSdk = 24` — syarat `firebase_messaging`.
- Kotlin Gradle Plugin `2.1.20` — syarat `firebase_core`.
- `ndkVersion` dipakai `26.3.11579264` karena NDK 27 di mesin ini rusak (folder
  `build/` hilang); kembalikan ke `27.0.12077973` bila NDK-nya sudah diperbaiki.
- iOS: izin diminta lewat `requestPermissions`; build iOS tetap harus dari macOS
  dan butuh `GoogleService-Info.plist` dari Firebase Console.

## Test

```
flutter pub get
flutter test
```

## Login Google

1. Google Cloud Console -> APIs & Services -> Credentials, buat dua OAuth client ID:
   - **Web application**: salin client ID-nya. Dipakai sebagai `GOOGLE_SERVER_CLIENT_ID` di aplikasi dan `GOOGLE_CLIENT_IDS` di backend.
   - **Android**: package name `com.coffeepaste.coffee_paste` + SHA-1 keystore yang dipakai untuk build. Tidak ditulis di kode, hanya perlu terdaftar.
2. SHA-1 debug: `cd android && ./gradlew signingReport` (varian `debug`). Setiap laptop punya SHA-1 debug berbeda: daftarkan semuanya, atau satu Android client per orang. Build release: daftarkan juga SHA-1 keystore release (atau SHA-1 *App signing* dari Play Console bila memakai Play App Signing).
3. OAuth consent screen: isi nama aplikasi dan email dukungan; selama status *Testing*, tambahkan akun uji di *Test users*.
4. Jalankan:

```
flutter pub get
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=XXXX.apps.googleusercontent.com
```

Bila dialog Google langsung tertutup tanpa masuk (Android), biasanya SHA-1/package name belum cocok dengan Android client ID. Lihat log debug `GoogleSignInException`.
