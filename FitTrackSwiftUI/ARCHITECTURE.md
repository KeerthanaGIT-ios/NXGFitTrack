# FitTrack iOS - Architecture Documentation

## Overview

FitTrack is an offline-first iOS workout tracking application built with SwiftUI, Core Data, and a clean MVVM architecture. The app prioritizes offline functionality with automatic background synchronization when connectivity is available.

## Architecture Pattern

### MVVM (Model-View-ViewModel)

- **Models**: Core Data entities (`Session`, `SetEntry`, `SyncQueueItem`) and DTOs for network communication
- **Views**: SwiftUI views (`LoginView`, `WorkoutsView`, `SessionView`, etc.)
- **ViewModels**: Observable objects that manage view state and business logic
- **Services**: Business logic layer (Auth, Profile, Sessions, Sync)

### Dependency Injection

Centralized DI container (`DIContainer`) manages service dependencies:
- Network client (Mock or Real)
- Authentication service
- Profile service
- Session service
- Sync services

This allows easy switching between mock and real backends for development/testing.

## Data Model

### Core Data Entities

#### Session
Represents a single workout session.

```
Session {
  id: UUID (primary key)
  createdAt: Date
  endedAt: Date? (nil while active)
  workoutTitle: String
  synced: Bool (tracks sync status)
  sets: [SetEntry] (one-to-many relationship)
}
```

**Design Decisions**:
- UUID for distributed ID generation (works offline)
- `synced` flag for tracking sync status (simple, effective)
- Cascade delete: deleting session removes all sets

#### SetEntry
Represents a single set within a workout session.

```
SetEntry {
  id: UUID
  exerciseName: String
  reps: Int16
  weightKg: Double
  isCompleted: Bool
  orderIndex: Int16 (for maintaining set order)
  note: String? (optional notes)
  session: Session (many-to-one relationship)
}
```

**Design Decisions**:
- `orderIndex` ensures sets maintain order even if Core Data relationships are unordered
- `note` field included for future extensibility (not yet used in UI)
- Weight stored in kg (SI units, standard in fitness apps)

#### SyncQueueItem
Represents a pending sync operation.

```
SyncQueueItem {
  id: UUID
  endpoint: String (e.g., "/sessions")
  payload: String (JSON-encoded DTO)
  createdAt: Date
  attempts: Int16 (retry counter)
}
```

**Design Decisions**:
- String payload allows flexibility for different endpoint types
- `attempts` counter for retry logic (max 5 attempts)
- No foreign key to Session (decoupled, can sync any data type)

### Data Transfer Objects (DTOs)

DTOs bridge between Core Data models and network API:

- `SessionDTO`: Network representation of Session
- `SetDTO`: Network representation of SetEntry
- `WorkoutTemplateDTO`: Workout template from backend
- `ExerciseDTO`: Exercise within a template
- `ProfileDTO`: User profile data
- `TokenResponse`: JWT tokens from auth endpoints

**Design Decisions**:
- Separate DTOs keep network layer decoupled from Core Data
- DTOs are Codable for easy JSON serialization
- Static `from()` methods convert Core Data → DTO

## Database Schema

### Relationships

```
Session (1) ──< (many) SetEntry
```

- One session has many sets
- Cascade delete: deleting session deletes all sets
- No inverse cascade (sets don't delete session)

### Indexing

Core Data automatically indexes:
- Primary keys (UUIDs)
- Foreign keys (session relationship)

**Tradeoffs**:
- No custom indexes needed for current query patterns
- Date-based queries on `createdAt` are fast enough for typical data volumes
- If scaling to thousands of sessions, consider index on `createdAt`

## Sync Strategy

### Offline-First Approach

1. **Immediate Local Save**: All operations (create session, add set, end session) save to Core Data immediately
2. **Queue for Sync**: When session ends, a `SyncQueueItem` is created
3. **Background Processing**: `SyncService` runs a timer (10s interval) to process queue
4. **Network Check**: Only processes queue when `NetworkMonitor` indicates connectivity
5. **Retry Logic**: Failed syncs increment `attempts`, removed after 5 failures

### Sync Flow

```
User ends session
  ↓
Session saved to Core Data (synced = false)
  ↓
SessionDTO created from Session
  ↓
SyncOperation created (endpoint + payload)
  ↓
SyncQueueItem saved to Core Data
  ↓
[Background: SyncService timer fires]
  ↓
Check network connectivity
  ↓
For each queued item:
  - Decode SyncOperation
  - Decode SessionDTO
  - POST to /sessions endpoint
  - On success: Delete SyncQueueItem, mark Session.synced = true
  - On failure: Increment attempts, retry later (max 5)
```

### Conflict Resolution

**Strategy**: Last-write-wins (client always overwrites server)

**Rationale**:
- Simpler implementation (no merge logic needed)
- Acceptable for single-user app (no multi-device conflicts)
- Client is source of truth (user just completed workout)

**Tradeoffs**:
- ✅ Simple, predictable behavior
- ✅ No complex merge logic
- ❌ Could lose server-side changes if user edits on another device
- ❌ Not suitable for multi-user collaborative scenarios

**Future Improvements**:
- Add `lastModified` timestamp for conflict detection
- Implement three-way merge for set-level conflicts
- Add server-side conflict resolution endpoint

## Networking Layer

### Protocol-Based Abstraction

```swift
protocol NetworkClient {
  func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
  func request(_ endpoint: APIEndpoint) async throws -> Data
}
```

Two implementations:
1. **MockNetworkClient**: In-memory mock for development/testing
2. **URLSessionNetworkClient**: Real HTTP client for production

### Authentication

- JWT tokens stored in iOS Keychain (secure, encrypted)
- Tokens automatically added to requests via `APIEndpoint.urlRequest`
- Token retrieval via `KeychainManager.shared.getAccessToken()`

**Security Considerations**:
- ✅ Keychain is hardware-encrypted on device
- ✅ Tokens never stored in UserDefaults or plaintext
- ✅ Tokens cleared on logout
- ⚠️ No token refresh logic (would need `/refresh` endpoint)

## Persistence Layer

### Core Data Stack

```swift
NSPersistentContainer(name: "FitTrack")
  - SQLite store (default location: App Sandbox)
  - Automatic lightweight migration enabled
  - Background context for sync operations
```

**Configuration**:
- In-memory store for unit tests
- SQLite for production (persistent, performant)
- Automatic merge policies for background saves

### Seed Data

No seed data required - app starts empty. Workout templates come from backend/mock API.

## Testing Strategy

### Unit Tests

**Location**: `FitTrackSwiftUITests/`

**Coverage**:
1. **Volume Calculation** (`MetricsCalculator.calculateVolume`)
   - Empty sessions
   - Single/multiple sets
   - Edge cases (zero weight)

2. **Personal Best Calculation** (`MetricsCalculator.personalBest`)
   - Single/multiple exercises
   - Multiple sets per exercise
   - Cross-session aggregation

3. **Sync Queue** (`SyncQueueService`)
   - Enqueue operations
   - Fetch queue
   - Remove items
   - Retry counter increment

**Test Data**: In-memory Core Data stack (isolated, fast)

### UI Tests

**Location**: `FitTrackSwiftUIUITests/`

**Coverage**:
- Complete workout flow: Login → Start Workout → Add Set → End → View History

**Challenges**:
- Async network calls (mock helps)
- Core Data persistence between test steps
- Navigation state management

## Design Tradeoffs

### 1. Offline-First vs. Online-First

**Chosen**: Offline-first

**Pros**:
- ✅ Works without network (critical for gym environments)
- ✅ Fast UI (no network delays)
- ✅ Better user experience

**Cons**:
- ❌ More complex sync logic
- ❌ Potential for conflicts (mitigated by single-user assumption)
- ❌ Sync queue management overhead

### 2. Core Data vs. Realm vs. SQLite Direct

**Chosen**: Core Data

**Rationale**:
- Native iOS framework (no dependencies)
- Excellent SwiftUI integration
- Mature, battle-tested
- Good performance for typical data volumes

**Alternatives Considered**:
- Realm: Simpler API, but external dependency
- SQLite direct: More control, but more boilerplate

### 3. MVVM vs. VIPER vs. Clean Architecture

**Chosen**: MVVM

**Rationale**:
- Simple, well-understood pattern
- Good fit for SwiftUI (ObservableObject)
- Sufficient separation for app size
- Easy to test (ViewModels are testable)

**Tradeoffs**:
- ✅ Simple, maintainable
- ✅ SwiftUI-friendly
- ❌ Can become complex with many ViewModels
- ❌ Less strict than VIPER (but sufficient here)

### 4. Sync Queue: Database vs. In-Memory

**Chosen**: Database (Core Data)

**Rationale**:
- Survives app crashes/restarts
- Can inspect queue for debugging
- Persistent across app launches

**Tradeoffs**:
- ✅ Reliable (survives crashes)
- ✅ Debuggable
- ❌ Slightly slower than in-memory
- ❌ More complex (but worth it for reliability)

### 5. Last-Write-Wins vs. Merge Strategy

**Chosen**: Last-write-wins

**Rationale**:
- Single-user app (no multi-device conflicts expected)
- Simpler implementation
- Client is source of truth (user just completed workout)

**Future**: Could add merge strategy if multi-device support needed

## Performance Considerations

### Core Data Performance

- **Fetch Requests**: Use predicates to limit results (date range filtering)
- **Batch Operations**: Not needed for current scale (single-user, typical < 1000 sessions)
- **Background Context**: Used for sync operations (doesn't block UI)

### Network Performance

- **Mock Client**: Instant responses (good for development)
- **Real Client**: Standard URLSession (can add caching if needed)
- **Sync Interval**: 10 seconds (balance between responsiveness and battery)

### UI Performance

- **SwiftUI Lists**: Efficient for typical data volumes
- **Charts**: Swift Charts framework (native, performant)
- **Lazy Loading**: Not needed (data volumes are small)

## Scalability

### Current Limits

- **Sessions**: ~1000 sessions (typical user: ~3/week = ~10 years)
- **Sets per Session**: ~50 sets (typical workout)
- **Total Data**: ~5-10 MB (well within device storage)

### Future Scaling

If scaling needed:
1. **Pagination**: Add limit/offset to fetch requests
2. **CloudKit**: Sync across devices
3. **Server-Side Aggregation**: Move metrics calculation to backend
4. **Caching**: Cache workout templates locally

## Security

### Authentication

- ✅ JWT tokens in Keychain (hardware-encrypted)
- ✅ Tokens in Authorization header (not URL params)
- ✅ HTTPS for real backend (URLSession enforces)

### Data Protection

- ✅ Core Data uses app sandbox (isolated)
- ✅ Keychain items are encrypted at rest
- ⚠️ No encryption for Core Data (acceptable for fitness data)

### Network Security

- ✅ Certificate pinning possible (not implemented, but URLSession supports)
- ✅ Token expiration handling (would need refresh endpoint)

## Future Enhancements

1. **Token Refresh**: Implement refresh token flow
2. **Conflict Resolution**: Add merge strategy for multi-device
3. **CloudKit Sync**: Sync across user's devices
4. **Offline Metrics**: Pre-calculate metrics for faster loading
5. **Set Notes**: Add UI for `SetEntry.note` field
6. **Workout Templates**: Allow user-created templates
7. **Exercise Library**: Expandable exercise database
8. **Social Features**: Share workouts, compare with friends

## Conclusion

FitTrack demonstrates a production-ready iOS architecture with:
- Clean separation of concerns (MVVM)
- Offline-first design (Core Data + sync queue)
- Secure authentication (Keychain)
- Testable code (unit + UI tests)
- Scalable structure (ready for future enhancements)

The architecture prioritizes simplicity and maintainability while providing a solid foundation for growth.

