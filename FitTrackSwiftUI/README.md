# FitTrack iOS - Workout Tracking App

A native iOS workout tracking application built with SwiftUI, demonstrating offline-first architecture, secure authentication, and seamless data synchronization.

## Features

- ✅ **Authentication**: Email/password signup and login with secure JWT token storage in Keychain
- ✅ **User Profile**: Editable profile with name, weight (kg), and height (cm)
- ✅ **Workout Templates**: Browse and select from pre-defined workout templates
- ✅ **Workout Sessions**: Start workouts from templates, track sets with reps, weight, and notes
- ✅ **History**: View past workout sessions with summaries
- ✅ **Metrics**: Training volume charts and personal best tracking per exercise
- ✅ **Offline Support**: Fully functional offline with automatic sync when online
- ✅ **Date Range Filtering**: Filter workout history by date range

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with Dependency Injection
- **Persistence**: Core Data (SQLite)
- **Networking**: URLSession with protocol-based abstraction
- **Security**: Keychain Services for token storage
- **Testing**: XCTest (Unit + UI tests)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Build & Run Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd FitTrackSwiftUI
```

### 2. Open in Xcode

```bash
open FitTrackSwiftUI.xcodeproj
```

### 3. Select Target & Simulator

1. Select the `FitTrackSwiftUI` scheme
2. Choose an iOS Simulator (iPhone 15 Pro recommended)
3. Press `Cmd + R` to build and run

### 4. Build Configuration

The app is configured to use **Mock Network Client** by default (no backend required). To switch to a real backend:

1. Open `FitTrackSwiftUI/App/DIContainer.swift`
2. Change `useMockNetwork` from `true` to `false`
3. Update the base URL in `APIEndpoint.swift` if needed

## Test Accounts

When using the **Mock Network Client** (default), you can use any email/password combination:

- **Email**: `test@example.com` (or any email)
- **Password**: `password123` (or any password)

The mock backend will accept any credentials and return mock JWT tokens.

### Mock Backend Behavior

- All authentication requests succeed with mock tokens
- Profile data persists in-memory during app session
- Workout templates are pre-defined (Full Body Beginner, Upper Body Strength)
- Session sync operations succeed immediately

## Backend Setup

### Option 1: Use Mock Network (Default - No Setup Required)

The app uses `MockNetworkClient` by default, which provides:
- In-memory authentication
- Pre-defined workout templates
- Simulated API responses

No backend setup is required.

### Option 2: Connect to Real Backend

1. **Update Configuration**:
   - Open `FitTrackSwiftUI/App/DIContainer.swift`
   - Set `useMockNetwork = false`

2. **Update Base URL**:
   - Open `FitTrackSwiftUI/Networking/APIEndpoint.swift`
   - Update the `url` property with your backend URL

3. **Required Endpoints**:

   ```
   POST /signup
   Body: { "email": string, "password": string }
   Response: { "accessToken": string, "refreshToken": string }

   POST /login
   Body: { "email": string, "password": string }
   Response: { "accessToken": string, "refreshToken": string }

   GET /user/profile
   Headers: Authorization: Bearer <token>
   Response: { "name": string, "weightKg": number, "heightCm": number }

   PUT /user/profile
   Headers: Authorization: Bearer <token>
   Body: { "name": string, "weightKg": number, "heightCm": number }

   GET /workouts
   Headers: Authorization: Bearer <token>
   Response: [{ "id": string, "title": string, "description": string, "exercises": [...] }]

   GET /workouts/:id
   Headers: Authorization: Bearer <token>
   Response: { "id": string, "title": string, "description": string, "exercises": [...] }

   POST /sessions
   Headers: Authorization: Bearer <token>
   Body: { "id": UUID, "createdAt": ISO8601, "endedAt": ISO8601, "workoutTitle": string, "sets": [...] }
   ```

## Running Tests

### Unit Tests

```bash
# Run all unit tests
Cmd + U in Xcode

# Or via command line
xcodebuild test -scheme FitTrackSwiftUI -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**Test Coverage**:
- ✅ Volume calculation (empty, single set, multiple sets, edge cases)
- ✅ Personal best calculation (single/multiple exercises, multiple sets)
- ✅ Sync queue operations (enqueue, fetch, remove, increment attempts)

### UI Tests

```bash
# Run UI tests
Cmd + U in Xcode (includes UI tests)

# Or run specific test
# Select "FitTrackSwiftUIUITests" scheme and run
```

**UI Test Coverage**:
- ✅ Complete workout flow: Login → Start Workout → Add Set → End → View History

## Project Structure

```
FitTrackSwiftUI/
├── App/
│   ├── FitTrackSwiftUIApp.swift    # App entry point
│   ├── DIContainer.swift            # Dependency injection container
│   └── AppRouter.swift              # Navigation/routing logic
├── Models/
│   ├── DTOs.swift                   # Data transfer objects
│   ├── SessionDTO.swift            # Session DTOs
│   ├── WorkoutDTOs.swift           # Workout DTOs
│   └── SyncOperation.swift         # Sync queue model
├── Networking/
│   ├── NetworkClient.swift         # Network protocol
│   ├── URLSessionNetworkClient.swift  # Real HTTP client
│   ├── MockNetworkClient.swift     # Mock client (default)
│   └── APIEndpoint.swift           # API endpoint definitions
├── Persistence/
│   └── Persistence.swift           # Core Data stack
├── Services/
│   ├── AuthService.swift           # Authentication
│   ├── ProfileService.swift        # User profile
│   ├── WorkoutsService.swift       # Workout templates
│   ├── SessionService.swift        # Workout sessions
│   ├── SyncService.swift           # Background sync
│   ├── SyncQueueService.swift      # Sync queue management
│   ├── MetricsCalculator.swift    # Volume & PB calculations
│   └── NetworkMonitor.swift        # Network connectivity
├── ViewModels/
│   ├── LoginViewModel.swift
│   ├── SignupViewModel.swift
│   ├── ProfileViewModel.swift
│   ├── WorkoutsViewModel.swift
│   ├── SessionViewModel.swift
│   └── HistoryViewModel.swift
├── Views/
│   ├── LoginView.swift
│   ├── SignupView.swift
│   ├── HomeView.swift
│   ├── WorkoutsView.swift
│   ├── WorkoutDetailView.swift
│   ├── SessionView.swift
│   ├── HistoryView.swift
│   ├── MetricsView.swift
│   └── ProfileView.swift
└── Utils/
    └── KeychainManager.swift       # Secure token storage
```

## Core Data Schema

### Session Entity
- `id`: UUID (primary identifier)
- `createdAt`: Date
- `endedAt`: Date (optional)
- `workoutTitle`: String
- `synced`: Bool (sync status)
- `sets`: Relationship to SetEntry (one-to-many)

### SetEntry Entity
- `id`: UUID
- `exerciseName`: String
- `reps`: Int16
- `weightKg`: Double
- `isCompleted`: Bool
- `orderIndex`: Int16
- `note`: String (optional)
- `session`: Relationship to Session (many-to-one)

### SyncQueueItem Entity
- `id`: UUID
- `endpoint`: String
- `payload`: String (JSON)
- `createdAt`: Date
- `attempts`: Int16

## Offline & Sync Strategy

1. **Offline-First**: All data is saved to Core Data immediately
2. **Sync Queue**: Failed syncs are queued in `SyncQueueItem`
3. **Background Sync**: `SyncService` processes queue every 10 seconds when online
4. **Conflict Resolution**: Last-write-wins (client always overwrites server)
5. **Retry Logic**: Up to 5 attempts per queued item

## Key Features Implementation

### Secure Authentication
- JWT tokens stored in iOS Keychain (not UserDefaults)
- Tokens automatically included in API requests via `Authorization` header
- Token persistence across app launches

### Offline Support
- Core Data for local persistence
- Sync queue for deferred network operations
- Network monitoring to trigger sync when connectivity restored

### Metrics Calculation
- **Volume**: Sum of (reps × weight) for all sets in a session
- **Personal Best**: Maximum (reps × weight) per exercise across all sessions

## Troubleshooting

### App won't build
- Ensure Xcode 15.0+ is installed
- Clean build folder: `Cmd + Shift + K`, then `Cmd + B`
- Check that iOS 17.0+ deployment target is set

### Tests failing
- Ensure Core Data model is included in test target
- Check that test data is properly cleaned up in `tearDown`

### Sync not working
- Verify network connectivity
- Check `NetworkMonitor.shared.isConnected`
- Review sync queue in Core Data (`SyncQueueItem` entities)

## Demo Video

See `demo/` folder for:
- GIFs or video showing:
  - Signup/Login flow
  - Starting a workout
  - Adding sets
  - Ending session
  - Viewing history and metrics
  - Offline → Online sync

## Architecture Documentation

See `ARCHITECTURE.md` for detailed architecture notes covering:
- Data model design
- Database schema
- Sync strategy
- Tradeoffs and design decisions

## License

This project is a demonstration app for iOS engineering assessment.

## Author

Created as part of NXG FitTrack iOS engineering assessment.

