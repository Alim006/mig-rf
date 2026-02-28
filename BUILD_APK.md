# 📦 Инструкция: Сборка APK

## Способ 1: GitHub Actions (автоматически) — РЕКОМЕНДУЕТСЯ

### Шаг 1: Загрузите код на GitHub

```bash
cd mig-rf/frontend
git init
git add .
git commit -m "Initial commit mig.rf"

# Создайте репозиторий на github.com и запушьте:
git remote add origin https://github.com/ВАШ_ЛОГИН/mig-rf.git
git push -u origin main
```

### Шаг 2: GitHub автоматически запустит сборку

После push GitHub Actions сам:
1. Установит Flutter
2. Скачает зависимости
3. Соберёт Debug APK + Release APK
4. Сохранит APK как артефакт

### Шаг 3: Скачайте APK

1. Откройте ваш репозиторий на GitHub
2. Нажмите на вкладку **Actions**
3. Выберите последний запуск **Build APK**
4. Прокрутите вниз до **Artifacts**
5. Скачайте `mig-rf-debug-apk` или `mig-rf-release-apk`

---

## Способ 2: Локально на компьютере

### Требования
- Flutter SDK 3.16+ (https://flutter.dev/docs/get-started/install)
- Android Studio или Android SDK
- Java 17+

### Установка Flutter (если ещё не установлен)

**Windows:**
```powershell
# Скачайте с https://flutter.dev/docs/get-started/install/windows
# Распакуйте и добавьте flutter/bin в PATH
flutter doctor
```

**macOS:**
```bash
brew install --cask flutter
flutter doctor
```

**Linux:**
```bash
sudo snap install flutter --classic
flutter doctor
```

### Сборка APK

```bash
cd mig-rf/frontend

# Скачать зависимости
flutter pub get

# Debug APK (без подписи, для тестирования)
flutter build apk --debug
# Файл: build/app/outputs/flutter-apk/app-debug.apk

# Release APK (оптимизированный)
flutter build apk --release
# Файл: build/app/outputs/flutter-apk/app-release.apk

# Split APK по архитектуре (меньший размер)
flutter build apk --split-per-abi
```

---

## Способ 3: Codemagic (онлайн, без настройки)

1. Зарегистрируйтесь на https://codemagic.io
2. Подключите GitHub репозиторий
3. Выберите Flutter проект
4. Нажмите **Start new build**
5. Скачайте APK из результатов

---

## Подпись APK для Google Play (опционально)

### Генерация ключа подписи

```bash
keytool -genkey -v \
  -keystore android/migrf-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias migrf
```

### Настройка key.properties

```bash
cp android/key.properties.example android/key.properties
# Заполните пароли в android/key.properties
```

### Сборка подписанного APK

```bash
flutter build apk --release
```

### Для GitHub Actions с подписью

Добавьте в **GitHub → Settings → Secrets**:
| Secret | Значение |
|--------|----------|
| `KEY_STORE_PASSWORD` | Пароль keystore |
| `KEY_PASSWORD` | Пароль ключа |
| `KEY_ALIAS` | `migrf` |

И в workflow закомментируйте секции с `keystore`.

---

## Автоматический релиз по тегу

```bash
git tag v1.0.0
git push origin v1.0.0
# GitHub Actions автоматически создаст Release с APK
```

---

## Минимальные требования к устройству

- Android 5.0+ (API level 21)
- ARM или x86 процессор
- 50 MB свободного места

---

## Установка APK на устройство

1. Включите **"Неизвестные источники"** в настройках Android
2. Скопируйте APK на устройство
3. Откройте файл-менеджер → найдите APK → установите

Или через ADB:
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```
