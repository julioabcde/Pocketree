# Pocketree 🌳💰

A money tracking management app built with Flutter. Keep track of your expenses, income, and financial goals all in one place.

## About

Pocketree helps you manage your personal finances with ease. Track your spending habits, monitor your income, and achieve your financial goals through intuitive money management features.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Git](https://git-scm.com/downloads)
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/julioabcde/Pocketree.git
   cd Pocketree
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```
   Fix any issues reported by the doctor command.

4. **Run the app**
   
   For development:
   ```bash
   flutter run
   ```
   
   For specific platforms:
   ```bash
   flutter run -d chrome        # Web
   flutter run -d windows       # Windows
   flutter run -d android       # Android
   flutter run -d ios           # iOS (macOS only)
   ```

### Project Structure

```
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── app_bloc_observer.dart
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── network/
│   │   └── dio_client.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── utils/
│   ├── di/
│   │   └── injection.dart
│   └── services/        
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── models/
    │   │   ├── datasources/
    │   │   └── repositories/
    │   │
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       ├── pages/       
    │       └── widgets/
```

## Development

### Running Tests
```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

**Windows:**
```bash
flutter build windows --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Project Link: [https://github.com/julioabcde/Pocketree](https://github.com/julioabcde/Pocketree)
