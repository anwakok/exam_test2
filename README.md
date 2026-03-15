# Yu-Gi-Oh! Memory Duel - Flutter App

แอปพลิเคชัน Yu-Gi-Oh! สไตล์ Memory Game ที่พัฒนาด้วย Flutter รองรับการเล่นออฟไลน์ พร้อม AI Integration และระบบ User

## สารบัญ

- [การรันโปรเจกต์](#การรันโปรเจกต์)
- [สถาปัตยกรรม](#สถาปัตยกรรม)
- [ฟีเจอร์หลัก](#ฟีเจอร์หลัก)
- [โครงสร้างโปรเจกต์](#โครงสร้างโปรเจกต์)

## การรันโปรเจกต์

### 1. ติดตั้ง Flutter
```bash
flutter doctor
```

### 2. Clone และ Setup
```bash
git clone <repository-url>
cd game
flutter pub get
```

### 3. Environment Setup
สร้างไฟล์ `assets/.env`:
```
GROQ_API_KEY=your_groq_api_key_here
```

### 4. Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. รันแอป
```bash
flutter run
```

## สถาปัตยกรรม

โปรเจกต์ใช้ **Clean Architecture** แบ่งเป็น 3 ชั้น:

```
┌─────────────────────────────┐
│    PRESENTATION LAYER       │
│     (BLoC + UI)             │
├─────────────────────────────┤
│      DOMAIN LAYER           │
│  (Entities + Use Cases)     │
├─────────────────────────────┤
│       DATA LAYER            │
│ (Models + Repositories)     │
└─────────────────────────────┘
```

### Dependencies
- **get_it**: Dependency Injection
- **auto_route**: Navigation
- **flutter_bloc**: State Management
- **sqflite**: Database
- **dio**: HTTP Client

## ฟีเจอร์หลัก

- 🔐 **User System** - SQLite Database
- 🎴 **Card Browser** - YGOPRODeck API  
- 🧠 **Memory Game** - Flip Animation
- 🤖 **AI Integration** - Groq API
- 📷 **Card Scanning** - ML Kit OCR

## โครงสร้างโปรเจกต์

```
lib/
├── core/               # Theme, Network
├── features/
│   ├── cards/          # Card Feature
│   ├── user/           # User Feature (SQLite)
│   ├── memory_game/    # Memory Game
│   ├── ai/             # AI Service
│   └── settings/       # App Settings
├── router.dart         # AutoRoute
├── injection.dart      # DI
└── main.dart           # Entry Point
```

## การทดสอบ

```bash
flutter test
```

---

Yu-Gi-Oh! is a trademark of Shueisha and Konami.
