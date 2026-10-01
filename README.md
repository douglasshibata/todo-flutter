# Todo Application (Flutter)

A production-ready, clean, and robust Flutter To-Do management application with persistent local storage, sound null safety, safe JSON parsing, and unit/widget test coverage.

---

## Project Overview & Architecture

### Overview
This project provides a simple yet comprehensive task management system written in Dart using the Flutter framework. It allows users to add new tasks, toggle task completion status, and remove tasks using swipe-to-dismiss functionality. Tasks are automatically persisted locally across app launches.

### Architecture
The project follows clean Flutter architecture principles:

- **`lib/models/item.dart`**: Immutable Data Model representing a single To-Do task (`Item`). Includes fields `id`, `title`, and `done`. Features defensive parsing (`fromJson`), serializing (`toJson`), state copying (`copyWith`), and value equality (`==` & `hashCode`).
- **`lib/main.dart`**:
  - `App`: The root `StatelessWidget` configuring application theme, app title, and routing to `HomePage`.
  - `HomePage` & `_HomePageState`: Stateful UI layer encapsulating local list state (`_items`) and managing async storage interactions with `SharedPreferences`.
- **`test/`**:
  - `item_test.dart`: Unit test suite for `Item` model creation, serialization, edge cases, and equality.
  - `widget_test.dart`: Integration & Widget test suite for loading, adding, toggling, deleting, and validating user input.

---

## Setup & Installation Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `>=2.17.6 <3.0.0` or modern Dart 3 SDK)
- Android Studio / Xcode / VS Code configured for Flutter development.

### Installation Steps

1. **Clone repository & navigate into project root**:
   ```bash
   git clone <repository_url>
   cd todo
   ```

2. **Get dependencies**:
   ```bash
   flutter pub get
   ```

3. **Check analyzer / lints**:
   ```bash
   flutter analyze
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## Environment Variables Required

No external secret keys or API environment variables are required. Local persistence utilizes device local storage via `shared_preferences`.

---

## How to Run the Test Suite

Run all unit and widget tests using the standard Flutter test runner:

```bash
flutter test
```

To run individual test files:
```bash
flutter test test/item_test.dart
flutter test test/widget_test.dart
```

---

## Security Considerations & Vulnerabilities Resolved

During auditing and refactoring, the following critical issues were addressed:

1. **State Mutation & Lifecycle Bugs**:
   - Fixed mutable fields on `StatefulWidget` (`HomePage.items`) which violated Flutter's immutability contracts. Moved items list encapsulation entirely into `_HomePageState`.
   - Prevented async memory leaks by checking `mounted` before invoking `setState()` after asynchronous `SharedPreferences` reads.
   - Added `TextEditingController.dispose()` in `dispose()` lifecycle method to prevent memory leaks.

2. **Unique Identifier & Key Collisions**:
   - Replaced string-title keys (`Key(item.title)`) in `Dismissible` widgets with unique ID-based keys (`ValueKey(item.id)`). This prevents duplicate title crashes during item dismissal and rebuilds.

3. **Input Sanitization & Edge Case Parsing**:
   - Guarded task creation against empty strings or whitespace-only inputs using `.trim()`.
   - Implemented defensive JSON deserialization (`Item.fromJson`) to safely handle corrupt, `null`, missing, or wrong-typed local storage payloads without throwing uncaught runtime exceptions.

4. **Broken Test Suite**:
   - Fixed test runner compilation failures caused by obsolete boilerplate code referencing `MyApp`. Replaced with comprehensive unit and widget test cases.
