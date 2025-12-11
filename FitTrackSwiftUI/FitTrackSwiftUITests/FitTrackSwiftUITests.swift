//
//  FitTrackSwiftUITests.swift
//  FitTrackSwiftUITests
//
//  Created by Keetzz on 10/12/25.
//

import XCTest
import CoreData
@testable import FitTrackSwiftUI

final class FitTrackSwiftUITests: XCTestCase {
    
    var testContext: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!

    override func setUpWithError() throws {
        // Create in-memory Core Data stack for testing
        persistentContainer = NSPersistentContainer(name: "FitTrack")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        testContext = persistentContainer.viewContext
    }

    override func tearDownWithError() throws {
        testContext = nil
        persistentContainer = nil
    }
    
    // MARK: - Volume Calculation Tests
    
    func testVolumeCalculation_EmptySession() throws {
        let session = Session(context: testContext)
        session.id = UUID()
        session.createdAt = Date()
        
        let volume = MetricsCalculator.calculateVolume(for: session)
        XCTAssertEqual(volume, 0.0, "Empty session should have zero volume")
    }
    
    func testVolumeCalculation_SingleSet() throws {
        let session = Session(context: testContext)
        session.id = UUID()
        session.createdAt = Date()
        
        let set = SetEntry(context: testContext)
        set.id = UUID()
        set.reps = 10
        set.weightKg = 20.0
        set.session = session
        
        let volume = MetricsCalculator.calculateVolume(for: session)
        XCTAssertEqual(volume, 200.0, "Volume should be reps * weight = 10 * 20 = 200")
    }
    
    func testVolumeCalculation_MultipleSets() throws {
        let session = Session(context: testContext)
        session.id = UUID()
        session.createdAt = Date()
        
        // Set 1: 10 reps @ 20kg = 200
        let set1 = SetEntry(context: testContext)
        set1.id = UUID()
        set1.reps = 10
        set1.weightKg = 20.0
        set1.session = session
        set1.orderIndex = 0
        
        // Set 2: 8 reps @ 25kg = 200
        let set2 = SetEntry(context: testContext)
        set2.id = UUID()
        set2.reps = 8
        set2.weightKg = 25.0
        set2.session = session
        set2.orderIndex = 1
        
        // Set 3: 12 reps @ 15kg = 180
        let set3 = SetEntry(context: testContext)
        set3.id = UUID()
        set3.reps = 12
        set3.weightKg = 15.0
        set3.session = session
        set3.orderIndex = 2
        
        let volume = MetricsCalculator.calculateVolume(for: session)
        XCTAssertEqual(volume, 580.0, "Total volume should be 200 + 200 + 180 = 580")
    }
    
    func testVolumeCalculation_ZeroWeight() throws {
        let session = Session(context: testContext)
        session.id = UUID()
        session.createdAt = Date()
        
        let set = SetEntry(context: testContext)
        set.id = UUID()
        set.reps = 10
        set.weightKg = 0.0
        set.session = session
        
        let volume = MetricsCalculator.calculateVolume(for: session)
        XCTAssertEqual(volume, 0.0, "Zero weight should result in zero volume")
    }
    
    // MARK: - Personal Best Calculation Tests
    
    func testPersonalBest_EmptySessions() throws {
        let sessions: [Session] = []
        let pbs = MetricsCalculator.personalBest(from: sessions)
        XCTAssertTrue(pbs.isEmpty, "Empty sessions should return empty personal bests")
    }
    
    func testPersonalBest_SingleExercise() throws {
        let session1 = Session(context: testContext)
        session1.id = UUID()
        session1.createdAt = Date()
        
        let set1 = SetEntry(context: testContext)
        set1.id = UUID()
        set1.exerciseName = "Bench Press"
        set1.reps = 10
        set1.weightKg = 20.0
        set1.session = session1
        set1.orderIndex = 0
        
        let session2 = Session(context: testContext)
        session2.id = UUID()
        session2.createdAt = Date()
        
        let set2 = SetEntry(context: testContext)
        set2.id = UUID()
        set2.exerciseName = "Bench Press"
        set2.reps = 8
        set2.weightKg = 25.0  // 8 * 25 = 200 (better than 10 * 20 = 200)
        set2.session = session2
        set2.orderIndex = 0
        
        let sessions = [session1, session2]
        let pbs = MetricsCalculator.personalBest(from: sessions)
        
        XCTAssertEqual(pbs.count, 1, "Should have one personal best")
        XCTAssertEqual(pbs.first?.exercise, "Bench Press")
        XCTAssertEqual(pbs.first?.best, 200.0, "Best should be max(200, 200) = 200")
    }
    
    func testPersonalBest_MultipleExercises() throws {
        // Session 1: Bench Press 10x20 = 200, Squat 8x30 = 240
        let session1 = Session(context: testContext)
        session1.id = UUID()
        session1.createdAt = Date()
        
        let set1a = SetEntry(context: testContext)
        set1a.id = UUID()
        set1a.exerciseName = "Bench Press"
        set1a.reps = 10
        set1a.weightKg = 20.0
        set1a.session = session1
        set1a.orderIndex = 0
        
        let set1b = SetEntry(context: testContext)
        set1b.id = UUID()
        set1b.exerciseName = "Squat"
        set1b.reps = 8
        set1b.weightKg = 30.0
        set1b.session = session1
        set1b.orderIndex = 1
        
        // Session 2: Bench Press 12x25 = 300 (better), Deadlift 5x50 = 250
        let session2 = Session(context: testContext)
        session2.id = UUID()
        session2.createdAt = Date()
        
        let set2a = SetEntry(context: testContext)
        set2a.id = UUID()
        set2a.exerciseName = "Bench Press"
        set2a.reps = 12
        set2a.weightKg = 25.0
        set2a.session = session2
        set2a.orderIndex = 0
        
        let set2b = SetEntry(context: testContext)
        set2b.id = UUID()
        set2b.exerciseName = "Deadlift"
        set2b.reps = 5
        set2b.weightKg = 50.0
        set2b.session = session2
        set2b.orderIndex = 1
        
        let sessions = [session1, session2]
        let pbs = MetricsCalculator.personalBest(from: sessions)
        
        XCTAssertEqual(pbs.count, 3, "Should have three personal bests")
        
        let benchPB = pbs.first { $0.exercise == "Bench Press" }
        let squatPB = pbs.first { $0.exercise == "Squat" }
        let deadliftPB = pbs.first { $0.exercise == "Deadlift" }
        
        XCTAssertEqual(benchPB?.best, 300.0, "Bench Press PB should be 12 * 25 = 300")
        XCTAssertEqual(squatPB?.best, 240.0, "Squat PB should be 8 * 30 = 240")
        XCTAssertEqual(deadliftPB?.best, 250.0, "Deadlift PB should be 5 * 50 = 250")
    }
    
    func testPersonalBest_MultipleSetsSameExercise() throws {
        // Session with multiple sets of same exercise - should take the best
        let session = Session(context: testContext)
        session.id = UUID()
        session.createdAt = Date()
        
        let set1 = SetEntry(context: testContext)
        set1.id = UUID()
        set1.exerciseName = "Bench Press"
        set1.reps = 10
        set1.weightKg = 20.0  // 200
        set1.session = session
        set1.orderIndex = 0
        
        let set2 = SetEntry(context: testContext)
        set2.id = UUID()
        set2.exerciseName = "Bench Press"
        set2.reps = 8
        set2.weightKg = 30.0  // 240 (best)
        set2.session = session
        set2.orderIndex = 1
        
        let set3 = SetEntry(context: testContext)
        set3.id = UUID()
        set3.exerciseName = "Bench Press"
        set3.reps = 12
        set3.weightKg = 15.0  // 180
        set3.session = session
        set3.orderIndex = 2
        
        let sessions = [session]
        let pbs = MetricsCalculator.personalBest(from: sessions)
        
        XCTAssertEqual(pbs.count, 1)
        XCTAssertEqual(pbs.first?.best, 240.0, "Should pick the best set: 8 * 30 = 240")
    }
    
    // MARK: - Sync Queue Tests
    
    func testSyncQueue_Enqueue() throws {
        let service = SyncQueueService()
        let originalCount = service.fetchQueue().count
        
        service.enqueue(endpoint: "/sessions", json: "{\"test\": \"data\"}")
        
        let queue = service.fetchQueue()
        XCTAssertEqual(queue.count, originalCount + 1, "Queue should have one more item")
        
        let item = queue.last
        XCTAssertEqual(item?.endpoint, "/sessions")
        XCTAssertEqual(item?.payload, "{\"test\": \"data\"}")
        XCTAssertEqual(item?.attempts, 0, "New item should have zero attempts")
    }
    
    func testSyncQueue_FetchQueue() throws {
        let service = SyncQueueService()
        
        service.enqueue(endpoint: "/sessions", json: "{\"data1\": \"value1\"}")
        service.enqueue(endpoint: "/sessions", json: "{\"data2\": \"value2\"}")
        service.enqueue(endpoint: "/profile", json: "{\"data3\": \"value3\"}")
        
        let queue = service.fetchQueue()
        XCTAssertGreaterThanOrEqual(queue.count, 3, "Should have at least 3 items")
    }
    
    func testSyncQueue_Remove() throws {
        let service = SyncQueueService()
        
        service.enqueue(endpoint: "/sessions", json: "{\"test\": \"data\"}")
        let queueBefore = service.fetchQueue()
        let countBefore = queueBefore.count
        
        if let item = queueBefore.last {
            service.remove(item)
            let queueAfter = service.fetchQueue()
            XCTAssertEqual(queueAfter.count, countBefore - 1, "Queue should have one less item after removal")
        }
    }
    
    func testSyncQueue_IncrementAttempts() throws {
        let service = SyncQueueService()
        
        service.enqueue(endpoint: "/sessions", json: "{\"test\": \"data\"}")
        let queue = service.fetchQueue()
        
        if let item = queue.last {
            XCTAssertEqual(item.attempts, 0, "Initial attempts should be 0")
            
            service.incrementAttempts(item)
            XCTAssertEqual(item.attempts, 1, "Attempts should be incremented to 1")
            
            service.incrementAttempts(item)
            XCTAssertEqual(item.attempts, 2, "Attempts should be incremented to 2")
        }
    }
}
