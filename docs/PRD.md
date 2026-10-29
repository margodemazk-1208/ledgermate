# Product Requirements Document (PRD)

## Project Name: LedgerMate — Personal Finance & Smart Daily Budget Tracker

## 1. Informasi Dokumen

| Metadata | Details |
|---|---|
| Document Version | 2.0.0 (full rewrite dari v1.0 — lihat §10 Changelog) |
| Status | Ready for Development |
| Target Platform | Android only (Flutter) |
| Distribusi | APK sideload manual ke lingkaran teman — tiap install independen, tanpa akun/server pusat |
| Target Launch | Tidak ada deadline (proyek pribadi) |

### Elevator Pitch

LedgerMate adalah aplikasi manajemen keuangan pribadi **100% offline**, dibangun dengan Flutter + Isar, yang menghitung otomatis "uang jajan harian aman" berbasis siklus gajian pengguna, melacak target tabungan, dan menyajikan analitik pengeluaran. Awalnya dibangun untuk kebutuhan pribadi, lalu dibagikan sebagai APK ke teman-teman dengan masalah keuangan serupa — setiap install berdiri sendiri, tanpa ada pihak pusat yang mengelola data siapa pun.

## 2. Latar Belakang & Tujuan

### 2.1 Problem Statement
1. Uang tiba-tiba habis karena tidak tahu batas aman belanja harian setelah dikurangi kewajiban rutin.
2. Menabung untuk target (goal) dilakukan tanpa kalkulasi realistis soal estimasi waktu tercapai.
3. Pola income campuran (gaji tetap + penghasilan tambahan tidak tetap) bikin perhitungan manual ribet.

### 2.2 Tujuan Produk
- User tahu persis angka "aman dibelanjakan hari ini" tanpa mikir manual.
- Pencatatan transaksi harus cepat (<5 detik) biar nggak males dicatat.
- 100% jalan tanpa internet — nggak ada titik gagal karena koneksi.

*(Metrik growth seperti DAU/MAU dihapus dari v1 — tidak relevan untuk app tanpa server/analytics terpusat.)*

## 3. Scope

### 3.1 In-Scope (v1)
- Android app, Flutter, offline-first, Isar sebagai database lokal satu-satunya.
- Smart Daily Budget Engine (self-balancing, lihat §7.1 BR-01).
- Goal & Projection Tracker — multi-goal aktif bersamaan.
- Visual Analytics: breakdown kategori + tren bulan-ke-bulan.
- Onboarding wizard (gaji, tanggal gajian, pengeluaran wajib) di first-launch.
- Setup ulang manual tiap siklus gajian baru (gaji & pengeluaran wajib diinput lagi — tidak ada carry-over otomatis).
- Export/Import manual (JSON/CSV) ke/dari file di storage lokal, untuk backup & pindah HP.
- Dwibahasa (Indonesia/English), dark mode default + light mode toggle.
- Navigasi 6 tab: Home, Tambah Transaksi, Goals, **Aset**, Analytics, Settings.
- Aset/Investasi tracker — nilai di-update manual (emas, saham, reksadana, dll), murni net-worth, terpisah dari budget harian.
- **Multi-Dompet (v1.1, lihat D16)** — user bikin/hapus/rename dompet sendiri secara bebas (nggak dibatasi 3 tipe tertentu), tiap transaksi nyantol ke 1 dompet spesifik, transfer antar dompet didukung, dan user pilih sendiri dompet mana yang ikut dihitung di Smart Daily Budget Engine (lihat BR-04).

### 3.2 Out-of-Scope (v1) — dihapus total dari v1.0
- ❌ Backend server (Node.js/PostgreSQL) — tidak ada data terpusat.
- ❌ Web Admin Dashboard, RBAC, User Management, Audit Log.
- ❌ Consent-Based Admin Shadowing (fitur ini batal, tidak jadi dibangun).
- ❌ Akun/login, cloud sync, multi-device sync.
- ❌ PIN & Biometric lock (bisa ditambah di v2 kalau user minta).
- ❌ iOS (Android only untuk sekarang).
- ❌ Open Banking API / auto-sync bank/e-wallet / auto-fetch harga saham-kripto-emas real-time (**Aset/Investasi tetap ada di v1, tapi nilai di-update manual oleh user** — lihat FR-10. Yang di-exclude cuma otomatisasi/API-nya).
- ❌ OCR struk (entitas disiapkan via field `receipt_url` nullable, implementasi ditunda).
- ❌ Monetisasi — gratis.

## 4. User Persona

- **Nama:** Kamu (pemilik proyek) + lingkaran teman dengan masalah keuangan serupa.
- **Pola income:** campuran — gaji bulanan tetap + penghasilan tambahan tidak tetap.
- **Masalah:** nggak tahu batas aman belanja harian; pengen nabung buat barang tapi nggak ketauan progresnya realistis atau nggak.

## 5. Functional Requirements (FR)

| ID | Modul | Requirement | Acceptance Criteria |
|---|---|---|---|
| FR-01 | Onboarding | Setup Wizard pertama install | Pilih **Income Frequency**: Mode A - Periodik (lump-sum di interval mingguan/2 mingguan/bulanan/custom — input tanggal income berikutnya) atau Mode B - Harian (income dicatat tiap kali masuk, termasuk jadwal nggak rata, tanpa tanggal payday). Lanjut buat **minimal 1 dompet** (FR-12) dengan saldo awal, lalu pilih dompet mana yang ikut dihitung di budget engine (BR-04). Lanjut input income awal + daftar pengeluaran wajib. Wajib selesai sebelum masuk Home. |
| FR-02 | Transaction | Catat transaksi offline | Simpan ke Isar <50ms. Form: jumlah (format Rupiah otomatis, tidak boleh negatif/kosong), kategori, **dompet (wajib pilih 1)**, tanggal, catatan opsional, tipe (income/expense). |
| FR-03 | Transaction | Edit & Delete transaksi | Edit bebas kapan saja. **Delete dibatasi hanya untuk transaksi tanggal hari ini** — transaksi lampau tidak bisa dihapus (jaga integritas histori), hanya bisa di-edit jumlah/kategorinya. |
| FR-04 | Engine | Smart Daily Budget Engine | Hitung "Uang Jajan Aman Hari Ini" sesuai formula BR-01 (§7.1). Rekalkulasi tiap ada transaksi baru, income baru, atau goal berubah. |
| FR-05 | Cycle | Siklus Gajian Baru | Saat tanggal gajian tercapai, app prompt user re-input gaji & pengeluaran wajib siklus baru (manual, tidak ada default/template). |
| FR-06 | Goals | Goal & Projection Tracker | Multi-goal aktif bersamaan. Tiap goal: nama, target amount, current amount, target date, opsi override alokasi harian manual. Tampilkan % progress + estimasi tanggal tercapai berdasar kecepatan nabung rata-rata. |
| FR-06b | Goals | Goal Realism Warning | Kalau total alokasi harian dari semua goal aktif bikin `UangJajanAmanHariIni` negatif/terlalu kecil, tampilkan alert dengan opsi: perpanjang target date goal, atau lanjut (acknowledge resiko). |
| FR-06c | Goals | Tarik dari Goal (Withdraw) | User bisa tarik sebagian/seluruh `currentAmount` goal kapan saja. Konfirmasi dialog wajib. Nominal yang ditarik otomatis nambah ke `RemainingBalance`/`UangJajanAmanHariIni` periode berjalan. |
| FR-10 | Assets | Aset/Investasi Tracker (tab baru) | User bisa tambah aset (nama, tipe, modal awal/harga beli, nilai sekarang). Nilai sekarang **di-update manual** oleh user kapan saja (tidak ada fetch harga otomatis — app tetap offline-first). Tampilkan gain/loss = nilai sekarang − modal awal, per aset + total gabungan. **Tidak** memengaruhi `UangJajanAmanHariIni`/`DailySavingsReserve` — murni net-worth tracking terpisah dari budget harian. |
| FR-11 | Notifications | Local Reminder (offline, via flutter_local_notifications — bukan FCM/push server) | 4 jenis reminder, masing-masing bisa di-ON/OFF individual di Settings: (1) **Catat transaksi harian** — jam default 21:00, waktunya bisa dikustomisasi user; (2) **Alert limit terlampaui** — trigger real-time begitu transaksi dicatat bikin `UangJajanAmanHariIni` minus/mendekati 0; (3) **Siklus gajian baru** — trigger di `nextPaydayDate`/interval baru (terhubung ke FR-05); (4) **Milestone goal** — trigger saat progress goal nyentuh 25%/50%/75%/100%. |
| FR-07 | Analytics | Visual Analytics | Pie/bar chart breakdown per kategori, filter harian/mingguan/bulanan, **plus tren bulan-ke-bulan** (perbandingan total & per kategori vs bulan sebelumnya). |
| FR-08 | Data | Export/Import Manual | Export seluruh data (transaksi, goals, settings) ke file JSON/CSV di folder Download. Import dari file untuk restore/pindah HP. |
| FR-09 | Settings | Pengaturan App | Ganti bahasa (ID/EN), ganti tema (dark/light), kelola kategori custom, lihat/export data. |
| FR-12 | Wallets | Multi-Dompet Management (v1.1) | User bisa tambah/edit/hapus dompet sendiri secara bebas (nama + ikon, tanpa dibatasi tipe tertentu) dari Settings atau Home. Tiap dompet punya saldo (dihitung on-the-fly dari `startingBalance` + jumlah transaksi yang nyantol ke dompet itu, bukan disimpan sebagai angka statis). Dompet yang masih punya transaksi/transfer terkait tidak bisa dihapus (harus dipindah/dihapus transaksinya dulu, cegah data yatim). Minimal selalu ada 1 dompet aktif. |
| FR-13 | Wallets | Transfer Antar Dompet | User bisa transfer nominal dari 1 dompet ke dompet lain dalam 1 aksi (misal tarik tunai dari Bank ke Tunai). Tidak dihitung sebagai income/expense di Analytics (FR-07) atau budget engine (BR-01) — murni perpindahan saldo internal, netral terhadap total kekayaan. |

## 6. Non-Functional Requirements (NFR)

### 6.1 Performance
- Simpan transaksi ke Isar: **< 50ms**
- Cold launch app: **< 1.5 detik**

### 6.2 Data Integrity
- **Koreksi (2026-10-28, lihat DECISIONS.md D14):** klaim awal "Isar's built-in AES encryption" di versi sebelumnya dokumen ini **tidak akurat** — baik `isar` maupun `isar_community` tidak pernah punya fitur enkripsi built-in. Keputusan final: andalkan **enkripsi app-sandbox bawaan Android** (default aktif di API level modern) — cukup buat ancaman realistis app ini (dibagi ke circle temen kecil, bukan data sensitif level enterprise). Tidak ada library enkripsi tambahan yang dipasang.
- Tidak ada `sync_status` field di data model — dihapus total, karena tidak ada server untuk disinkron.

### 6.3 Tech Stack (final, v2)

```
[Android App]
  ├── Framework: Flutter (Dart)
  ├── State Management: Riverpod
  ├── Local Database: Isar (satu-satunya sumber data, tidak ada server)
  ├── Notifications: flutter_local_notifications (on-device, tidak butuh internet/FCM)
  ├── Charting: fl_chart (atau syncfusion_flutter_charts)
  └── i18n: flutter_localizations (ID/EN)
```
Tidak ada backend, tidak ada API, tidak ada admin dashboard. Build sepenuhnya client-side.

## 7. Business Rules

### 7.1 BR-01 — Smart Daily Budget Formula (final, menggantikan formula v1 yang terpotong)

App mendukung **2 mode Income Frequency**, dipilih user saat onboarding (FR-01), karena pola income "gajian periodik" dan "bekel harian/nggak rata" butuh kalkulasi beda. Kedua mode ini general — **bukan hardcode bulanan/harian literal**:
- **Mode A** jalan buat interval APA PUN yang sifatnya lump-sum di tanggal tertentu: mingguan, 2 mingguan, bulanan, atau custom — user tinggal set "tanggal income berikutnya", `RemainingDays` otomatis ngikutin selisihnya.
- **Mode B** jalan buat pola income APA PUN yang nggak berbentuk lump-sum terjadwal — termasuk bekel harian yang **nggak rata** (misal cuma dikasih Senin-Kamis, weekend nggak) — karena dia nggak mengasumsikan jadwal sama sekali, cuma baca transaksi income yang beneran dicatat user. Hari tanpa income otomatis dihitung `BekelHariIni = 0`, tidak perlu setup jadwal terpisah.

#### Mode A — Periodik (lump-sum di tanggal tertentu — mingguan/2 mingguan/bulanan/custom, bukan cuma bulanan)

```
RemainingDays       = jumlah hari dari HARI INI sampai tanggal income berikutnya (inklusif hari ini)

RemainingBalance    = (IncomeTetapSiklusIni + TotalIncomeTambahanYangSudahMasuk)
                      − TotalPengeluaranWajibSiklusIni
                      − TotalPengeluaranHarianYangSudahDicatatSiklusIni
                      // ⚠️ v1.1 (D16, BR-04): hanya transaksi yang nyantol ke dompet
                      // ber-flag includeInDailyBudget=true yang dihitung di sini.
                      // Transaksi di dompet non-budget (mis. tabungan Bank) diabaikan
                      // dari formula, meski tetap tercatat & muncul di Analytics/saldo total.

DailySavingsReserve = Σ untuk setiap goal aktif:
                        (TargetAmount − CurrentAmount) / SisaHariKeTargetDate

UangJajanAmanHariIni = (RemainingBalance / RemainingDays) − DailySavingsReserve
```

**Behavior:** Setiap kali user mencatat pengeluaran, `RemainingBalance` turun → angka esok hari otomatis re-kalkulasi. Kalau user boros hari ini, jatah besok otomatis mengetat. Kalau hemat, jatah besok naik.

#### Mode B — Harian (bekel/income diterima tiap hari, tanpa tanggal payday)

```
SaldoCarryOver       = sisa UangJajanAmanHariIni kemarin yang nggak kepake (akumulatif, TIDAK hangus)

DailySavingsReserve  = Σ untuk setiap goal aktif:
                         (TargetAmount − CurrentAmount) / SisaHariKeTargetDate

UangJajanAmanHariIni = SaldoCarryOver + BekelHariIni
                       − PengeluaranWajibHariIni (kalau ada, mis. ongkos)
                       − PengeluaranYangSudahDicatatHariIni
                       − DailySavingsReserve
                       // ⚠️ v1.1 (D16, BR-04): BekelHariIni & PengeluaranYangSudahDicatatHariIni
                       // hanya menjumlahkan transaksi di dompet ber-flag includeInDailyBudget=true.
```

**Behavior:** Tidak ada konsep "sisa hari sampai payday" karena incomenya memang harian. Sisa bekel yang tidak terpakai **terakumulasi** ke saldo besok (carry-over), bukan hangus — supaya user yang hemat hari ini dapat buffer lebih besar besoknya.

Kedua mode berbagi logic `DailySavingsReserve` yang sama (§7.3).

### 7.2 BR-02 — Mandatory Expense Input
Pengeluaran wajib (kos, cicilan, dll) diinput **manual sekali di awal tiap siklus gajian baru** — bukan dihitung otomatis dari kategori transaksi. Tidak ada carry-over/template dari siklus sebelumnya (by design, sesuai keputusan user — tiap siklus bisa beda kebutuhan).

### 7.3 BR-03 — Goal Allocation & Contribution Mechanism
Semua goal aktif menyumbang `DailySavingsReserve` secara independen dan dijumlahkan. Tidak ada prioritas antar goal di v1 (semua diperlakukan setara).

- **Alokasi harian per goal** default dihitung otomatis: `(TargetAmount − CurrentAmount) / SisaHariKeTargetDate`. User **boleh override manual** (misal paksa nabung Rp20.000/hari meski hasil otomatis beda) — kalau di-override, sistem pakai angka manual itu, bukan hasil pembagian otomatis, sampai user ubah lagi atau hapus override-nya.
- **Warning kalau nggak realistis:** kalau total `DailySavingsReserve` dari semua goal aktif bikin `UangJajanAmanHariIni` jadi negatif atau di bawah ambang wajar, app munculin alert ke user dengan 2 opsi: perpanjang tanggal target goal (biar alokasi harian ngecil), atau lanjut terima resiko (limit harian tetap ditampilkan minus/kecil, nggak diblokir).
- **Akumulasi progress (auto-accrual):** App ini cuma pencatat, bukan e-wallet — uang goal nggak beneran dipindah secara fisik. Progress `currentAmount` tiap goal **bertambah otomatis tiap hari** sebesar `DailySavingsReserve` hari itu (karena nominal itu sudah "disisihkan" dari `UangJajanAmanHariIni`, jadi dianggap otomatis masuk tabungan goal), tanpa perlu user catat transaksi "setor" manual.
- **Penarikan (Withdraw):** Kalau kepepet butuh uang yang udah "disetor" ke goal, user bisa tap **"Tarik dari Goal"** — `currentAmount` goal itu turun sejumlah yang ditarik, dan nominalnya otomatis balik nambah ke `UangJajanAmanHariIni`/`RemainingBalance` periode berjalan (dianggap kayak income masuk lagi). Konfirmasi dialog ditampilkan sebelum penarikan diproses (irreversible terhadap progress goal).

### 7.4 BR-04 — Wallet Scoping ke Budget Engine (v1.1, lihat D16)
Tiap dompet (`Wallet`) punya flag `includeInDailyBudget` (Bool), diset user pas bikin dompet (default saat onboarding: user pilih dompet mana yang "dianggap uang jajan harian" vs "dianggap tabungan/di luar budget harian", bisa diubah lagi kapan saja dari Settings).
- `RemainingBalance` (Mode A) dan `BekelHariIni`/`PengeluaranYangSudahDicatatHariIni` (Mode B) **hanya** menjumlahkan transaksi di dompet-dompet dengan `includeInDailyBudget=true`.
- Transaksi di dompet `includeInDailyBudget=false` tetap tercatat penuh, tetap muncul di Analytics (FR-07) dan Total Saldo Home, tapi **tidak** memengaruhi `UangJajanAmanHariIni` — logic yang sama kayak Asset (FR-10) terhadap budget harian, cuma versinya buat dompet/transaksi, bukan aset.
- **Transfer** (FR-13) antar 2 dompet yang sama-sama `includeInDailyBudget=true` net-neutral terhadap `RemainingBalance` (satu turun, satu naik, totalnya nggak berubah). Transfer yang nyeberang status include/exclude (misal dari dompet budget ke dompet tabungan) **akan** mengubah `RemainingBalance`/`UangJajanAmanHariIni` — ini WAJAR dan disengaja (uang itu beneran keluar dari pool jajan harian), bukan bug.

## 8. Data Model (Isar, lokal-only)

```
LocalProfile
  - fixedSalary (Decimal)
  - incomeFrequency (Enum: PERIODIC / DAILY)   // NEW — nentuin formula BR-01 mode A/B dipakai
  - nextPaydayDate (Date, nullable)            // hanya dipakai kalau incomeFrequency = PERIODIC
  - carryOverBalance (Decimal, default 0)      // NEW — hanya dipakai kalau incomeFrequency = DAILY
  - language (Enum: ID/EN)
  - theme (Enum: dark/light)
  - notifDailyReminderEnabled (Bool, default true)      // NEW
  - notifDailyReminderTime (Time, default 21:00)        // NEW
  - notifLimitAlertEnabled (Bool, default true)         // NEW
  - notifPayCycleEnabled (Bool, default true)           // NEW
  - notifGoalMilestoneEnabled (Bool, default true)      // NEW

PayCycle
  - id
  - startDate / paydayDate
  - fixedSalary
  - variableIncomeTotal (running, bertambah tiap income transaction masuk)
  - mandatoryExpenses: List<MandatoryExpenseItem { name, amount }>

Transaction
  - id
  - type (INCOME / EXPENSE / TRANSFER)            // TRANSFER NEW (v1.1, D16)
  - amount
  - categoryId                                     // nullable kalau type=TRANSFER (transfer tidak punya kategori pengeluaran/income)
  - walletId (FK ke Wallet.id)                     // NEW (v1.1) — wajib diisi, dompet asal transaksi
  - transferPeerWalletId (FK ke Wallet.id, nullable) // NEW (v1.1) — hanya diisi kalau type=TRANSFER, dompet tujuan
  - transferGroupId (String/UUID, nullable)        // NEW (v1.1) — pasangan 2 row Transaction (keluar+masuk) dari 1 aksi transfer dapat id yang sama, buat gampang di-undo/ditampilkan sebagai 1 entri di UI meski 2 row di DB
  - date
  - notes (nullable)
  - payCycleId (FK, biar gampang hitung per-siklus)
  // sync_status DIHAPUS — tidak relevan, app offline-only

Wallet                                            // NEW (v1.1, D16) — custom, bukan 3 tipe fixed
  - id
  - name                                           // bebas, user-defined (bukan enum Tunai/E-Wallet/Bank)
  - icon (String — key ikon dari set ikon app, bukan upload bebas)
  - startingBalance (int, whole Rupiah)            // saldo awal pas dompet dibuat
  - includeInDailyBudget (Bool, default true)      // NEW — lihat BR-04, nentuin ikut dihitung UangJajanAmanHariIni atau nggak
  - createdAt (Timestamp)
  // saldo SEKARANG dihitung on-the-fly: startingBalance + Σ(transaksi masuk/keluar/transfer yang nyantol ke wallet ini) — tidak disimpan sbg field statis, konsisten sama pola Asset.gainLoss (§8 Asset)

Category
  - id
  - name
  - isDefault (Bool) // true utk kategori bawaan, false utk custom buatan user

FinancialGoal
  - id
  - goalName
  - targetAmount
  - currentAmount
  - targetDate
  - manualDailyAllocation (Decimal, nullable)   // NEW — kalau diisi, override hitungan otomatis (Target-Current)/SisaHari

Asset                                            // NEW — net-worth tracker, terpisah dari Goal
  - id
  - assetName
  - assetType (String — bebas: emas/saham/reksadana/tanah/dll)
  - purchaseValue (Decimal)    // modal awal/harga beli
  - currentValue (Decimal)     // di-update manual oleh user kapan saja
  - lastUpdatedAt (Timestamp)
  // gainLoss dihitung on-the-fly: currentValue − purchaseValue, tidak disimpan sbg field
```

## 9. Roadmap (disederhanakan drastis dari v1 — Phase 3 lama dihapus total)

```
Phase 1: Core Offline App (minggu 1-3)
  ├── Setup Flutter + Isar + Riverpod skeleton
  ├── Onboarding wizard (gaji, tanggal gajian, pengeluaran wajib)
  ├── Transaction CRUD (offline, dengan validasi + batasan delete)
  └── Kategori default + custom

Phase 2: Smart Engine (minggu 4-5)
  ├── Smart Daily Budget Engine (BR-01) + re-kalkulasi real-time
  ├── Goal & Projection Tracker (multi-goal)
  └── Siklus gajian baru (prompt re-input tiap payday)

Phase 3: Analytics & Polish (minggu 6-7)
  ├── Visual Analytics (pie/bar + tren bulan-ke-bulan)
  ├── Export/Import JSON/CSV
  ├── Dark/light theme toggle + dwibahasa ID/EN
  └── Testing + build APK buat dibagiin ke temen
```

## 10. Changelog dari PRD v1.0

**Dihapus total** (nggak relevan buat single-device-per-user, no-server app):
- Admin role, Web Admin Dashboard, RBAC, User Management, Audit Log
- Consent-Based Admin Shadowing + ShadowingSessions entity
- Backend: Node.js/NestJS, PostgreSQL, Prisma, OpenAPI spec, REST sync engine
- React.js Admin Dashboard
- PIN & Biometric lock (FR-01 lama)
- `sync_status` field, Last-Write-Wins conflict resolution (tidak ada sync)
- Business goals DAU/MAU stickiness (metrik growth produk, tidak relevan)
- iOS target
- Seluruh "Phase 3: Admin & Governance" dari roadmap lama

**Diperbaiki:**
- BR-01 formula (di v1 terpotong/rusak di gambar) — didefinisikan ulang lengkap di §7.1

**Ditambahkan:**
- Pembatasan delete transaksi (hanya hari ini)
- Validasi input ketat (format Rupiah, no negative)
- Dwibahasa ID/EN
- Tren bulan-ke-bulan di analytics
- Setup wizard onboarding eksplisit
- Isar local encryption (AES) dipertahankan meski offline, karena data finansial sensitif
