# Aplikasi Pembukuan Kas RT — Supabase + GitHub

Fitur: login, role admin/warga, transaksi kas masuk/keluar, data warga, pinjaman, cicilan masuk, saldo otomatis, dan laporan PDF dengan kop RT.

## 1. Supabase
1. Buat project di Supabase.
2. Buka SQL Editor dan jalankan `supabase.sql`.
3. Buka Authentication > Users > Add user, buat akun admin dengan email/password.
4. Salin UUID user tersebut, lalu di SQL Editor jalankan `update public.profiles set role='admin' where id='UUID_USER_ADMIN';`
5. Ambil Project URL dan anon public key dari Settings > API.

## 2. Jalankan di GitHub/Vercel
1. Upload semua file ini ke repository GitHub.
2. Di Vercel pilih Add New > Project > import repository.
3. Framework Vite biasanya terdeteksi otomatis. Build: `npm run build`, Output: `dist`.
4. Environment Variables: `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY`.
5. Deploy.

## 3. Dari HP
GitHub bisa dibuka lewat browser/Chrome. Untuk upload file, paling mudah buat repository baru lalu upload file satu per satu atau upload ZIP setelah diekstrak. Vercel juga dapat dibuka dari Chrome HP.

## Catatan keamanan
Anon key boleh berada di aplikasi frontend; keamanan data ditentukan oleh Row Level Security (RLS). Jangan pernah memasukkan `service_role` key ke frontend/GitHub.
