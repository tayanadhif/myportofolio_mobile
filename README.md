# myportofolio_mobile

Nama : Nadhif Aydin Adinandra
NPM : 2506537745
Kelas : PBP E

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Tugas 7

1. **Apa yang dimaksud dengan *widget tree* pada Flutter dan bagaimana hubungan induk-anak (*parent-child*) bekerja antar-*widget*?**

   *Widget tree* adalah susunan widget yang membentuk antarmuka Flutter. Widget disusun secara hierarkis: sebuah widget induk (*parent*) memiliki satu atau lebih widget anak (*child* atau *children*). Induk mengatur letak, ukuran, tampilan, atau perilaku anaknya. Contohnya, `Scaffold` menjadi induk `AppBar` dan `body`, sedangkan `Column` menyusun beberapa widget anak secara vertikal. Ketika data atau konfigurasi berubah, Flutter membangun kembali bagian tree yang terdampak.

   Pada aplikasi ini, `MyApp` membangun `MaterialApp`, yang menampilkan `MyHomePage`. Di dalam `MyHomePage`, `Scaffold` menaungi `AppBar` dan konten halaman. Konten tersebut menggunakan `Stack` untuk menumpuk gambar, lapisan warna, dan area yang dapat digulir; di dalamnya terdapat `Column`, kartu informasi, grid menu, dan chip keahlian.

2. **Sebutkan semua *widget* yang digunakan dalam proyek ini dan jelaskan fungsinya masing-masing!**

   Berikut widget Flutter dan widget khusus yang digunakan pada kode aplikasi di `lib/main.dart` dan `lib/menu.dart`:

   | Widget | Fungsi |
   |---|---|
   | `MyApp` | Widget khusus yang menjadi titik masuk tampilan aplikasi dan mengelola pilihan tema. |
   | `MaterialApp` | Menyediakan struktur dasar aplikasi bergaya Material, tema, dan halaman awal. |
   | `MyHomePage` | Widget khusus yang membangun halaman utama portofolio dari informasi yang diterimanya. |
   | `Scaffold` | Menyediakan kerangka halaman, termasuk area app bar dan body. |
   | `AppBar` | Menampilkan bilah atas dan judul halaman. |
   | `IconButton` | Tombol di app bar untuk mengganti tema terang/gelap. |
   | `Icon` | Menampilkan ikon tema, menu, dan keahlian. |
   | `Stack` | Menumpuk gambar latar, lapisan warna, dan konten halaman. |
   | `Positioned` (`Positioned.fill`) | Mengatur anak `Stack` agar memenuhi area yang tersedia. |
   | `Image` (`Image.asset`) | Menampilkan gambar latar dari aset aplikasi. |
   | `ColoredBox` | Menggambar lapisan warna transparan di atas gambar latar. |
   | `SingleChildScrollView` | Memungkinkan konten halaman digulir jika lebih tinggi dari layar. |
   | `Column` | Menyusun konten secara vertikal, termasuk informasi kartu dan isi kartu menu. |
   | `Text` | Menampilkan judul, keterangan, data profil, label, dan pesan. |
   | `SizedBox` | Memberi jarak atau ruang berukuran tertentu di antara widget. |
   | `Row` | Menyusun tiga kartu informasi profil secara horizontal. |
   | `InfoCard` | Widget khusus untuk menampilkan label dan isi informasi profil dalam kartu. |
   | `_SectionTitle` | Widget khusus untuk menampilkan judul bagian dengan gaya tema. |
   | `GridView` (`GridView.count`) | Menyusun pilihan menu dalam grid dengan jumlah kolom tertentu. |
   | `ItemCard` | Widget khusus untuk menampilkan satu item menu dan menangani ketukan. |
   | `Material` | Menyediakan permukaan Material dan warna/latar untuk kartu menu. |
   | `InkWell` | Memberikan respons interaksi saat kartu menu ditekan. |
   | `Container` | Mengatur ukuran, padding, dan isi kartu informasi/menu. |
   | `Center` | Memusatkan isi kartu menu. |
   | `Padding` | Memberikan padding pada ikon di kartu menu. |
   | `Wrap` | Menyusun chip keahlian dan memindahkannya ke baris berikutnya saat ruang tidak cukup. |
   | `_SkillChip` | Widget khusus untuk menampilkan satu keahlian sebagai chip berikon. |
   | `Chip` | Menampilkan label keahlian beserta ikon kecil. |
   | `Card` | Memberikan tampilan kartu pada informasi profil. |
   | `SnackBar` | Menampilkan pesan sementara setelah item menu ditekan. |

   `TextStyle`, `ThemeData`, `ColorScheme`, `ItemHomepage`, dan `BuildContext` juga tampak pada implementasi, tetapi bukan widget: yang pertama merupakan objek gaya/tema atau data, sedangkan `BuildContext` memberi akses ke posisi widget dalam tree.

3. **Apa fungsi dari widget `MaterialApp`? Jelaskan mengapa widget ini umumnya digunakan sebagai *root widget* pada aplikasi Flutter!**

   `MaterialApp` menyiapkan fitur umum aplikasi Material, antara lain tema terang/gelap, konfigurasi visual Material, navigasi, dan halaman awal (`home`). Pada proyek ini, `MaterialApp` mengatur `theme`, `darkTheme`, serta `themeMode`, lalu menampilkan `MyHomePage` sebagai halaman awal.

   Widget ini lazim menjadi root widget karena membungkus seluruh antarmuka aplikasi dan menyediakan konfigurasi serta layanan yang dibutuhkan widget turunannya. Dengan begitu, widget di bawahnya dapat mengakses tema dan layanan Material melalui `BuildContext`. `runApp` memasang `MyApp` sebagai root aplikasi; `MyApp` kemudian mengembalikan `MaterialApp`.

4. **Jelaskan perbedaan antara `StatelessWidget` dan `StatefulWidget`! Kapan kita sebaiknya memilih `StatelessWidget` dan kapan harus menggunakan `StatefulWidget`?**

   `StatelessWidget` cocok untuk tampilan yang tidak mengelola state yang berubah di dalam widget tersebut. Widget dibangun dari konfigurasi atau data yang diterima; jika input berubah, Flutter dapat membangun ulang widget dengan konfigurasi baru. Pada proyek ini, `MyHomePage`, `InfoCard`, `ItemCard`, `_SectionTitle`, dan `_SkillChip` adalah `StatelessWidget`.

   `StatefulWidget` digunakan ketika tampilan perlu berubah sebagai respons terhadap state yang dikelola widget. Data state disimpan pada objek `State`, dan `setState` memberi tahu Flutter bahwa tampilan perlu dibangun ulang. `MyApp` adalah `StatefulWidget` karena menyimpan `_isDarkMode`; saat tombol tema ditekan, `_toggleTheme` mengubah nilainya dan aplikasi memperbarui tema. Pilih `StatelessWidget` jika tidak ada state lokal yang berubah, dan `StatefulWidget` jika widget perlu mengelola perubahan state selama masa hidupnya.

5. **Apa itu `BuildContext` dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode `build`?**

   `BuildContext` adalah referensi ke lokasi sebuah widget dalam widget tree. Flutter menggunakannya agar widget dapat menemukan informasi atau layanan yang disediakan widget leluhur, misalnya tema melalui `Theme.of(context)`, ukuran layar melalui `MediaQuery.of(context)`, atau pengelola pesan melalui `ScaffoldMessenger.of(context)`.

   Parameter `context` tersedia pada metode `build(BuildContext context)`. Parameter ini dapat diteruskan ke API yang memerlukan informasi dari tree. Contohnya, halaman menggunakan `Theme.of(context)` untuk memperoleh warna dan tipografi tema, `MediaQuery.of(context)` untuk menghitung lebar kartu, serta `ScaffoldMessenger.of(context)` untuk menampilkan `SnackBar`. Gunakan context pada lokasi yang berada di bawah leluhur penyedia layanan yang diperlukan.

6. **Jelaskan konsep *hot reload* di Flutter dan apa perbedaannya dengan *hot restart*! Kapan kita tidak bisa hanya mengandalkan *hot reload* dan harus melakukan *hot restart* atau *full restart*?**

   *Hot reload* menerapkan perubahan kode Dart ke aplikasi yang sedang berjalan dan membangun ulang widget, biasanya tanpa menghapus state yang sedang aktif. Karena prosesnya cepat dan state dipertahankan, hot reload berguna untuk melihat perubahan UI atau logika selama pengembangan.

   *Hot restart* memulai ulang aplikasi Flutter dari awal dan menghapus state dalam memori, tetapi tidak membangun ulang atau memulai ulang proses native aplikasi. Gunakan hot restart jika perubahan bergantung pada inisialisasi awal atau state awal yang tidak diperbarui oleh hot reload, atau jika hot reload tidak menerapkan perubahan dengan benar.

   *Full restart* menghentikan lalu menjalankan kembali aplikasi, termasuk bagian native/platform. Ini diperlukan untuk perubahan kode native seperti Kotlin/Java atau Swift/Objective-C, konfigurasi platform, dan perubahan plugin yang membutuhkan proses build atau registrasi native baru. Jadi, hot reload bukan pengganti restart untuk semua jenis perubahan; pilih restart sesuai bagian aplikasi yang berubah.

### AI Disclosure

Saya menggunakan ChatGPT sebagai alat bantu untuk memperoleh panduan dan langkah-langkah dalam mengerjakan proyek, memverifikasi pemahaman mengenai konsep Flutter, serta mencari solusi saat menemui kendala selama pengembangan. Saya meninjau dan menyesuaikan saran yang diberikan, kemudian menguji aplikasi untuk memastikan perubahan sesuai dengan kebutuhan proyek.

**ChatGPT history conversation:**
- [Percakapan Tugas 7](https://chatgpt.com/share/6af335f7-93d4-83ec-b2ab-4db9846f2165)