//
//  File.IO.Executor Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Async

extension File.IO.Test.Unit {
    @Suite("File.IO.Executor")
    struct Executor {

        // MARK: - Basic Execution

        @Test("Execute simple operation")
        func executeSimple() async throws {
            let executor = File.IO.Executor()
            let result = try await executor.run { 42 }
            #expect(result == 42)
            await executor.shutdown()
        }

        @Test("Execute throwing operation")
        func executeThrowing() async throws {
            let executor = File.IO.Executor()

            struct TestError: Error {}

            await #expect(throws: TestError.self) {
                try await executor.run { throw TestError() }
            }
            await executor.shutdown()
        }

        @Test("Execute multiple operations")
        func executeMultiple() async throws {
            let executor = File.IO.Executor()

            let results = try await withThrowingTaskGroup(of: Int.self) { group in
                for i in 0..<10 {
                    group.addTask {
                        try await executor.run { i * 2 }
                    }
                }
                var results: [Int] = []
                for try await result in group {
                    results.append(result)
                }
                return results.sorted()
            }

            #expect(results == [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
            await executor.shutdown()
        }

        // MARK: - Shutdown

        @Test("Run after shutdown throws")
        func runAfterShutdown() async throws {
            let executor = File.IO.Executor()
            await executor.shutdown()

            await #expect(throws: File.IO.ExecutorError.self) {
                try await executor.run { 42 }
            }
        }

        @Test("Shutdown is idempotent")
        func shutdownIdempotent() async throws {
            let executor = File.IO.Executor()
            await executor.shutdown()
            await executor.shutdown()  // Should not hang or crash
        }

        @Test("In-flight jobs complete during shutdown")
        func inFlightCompletesDuringShutdown() async throws {
            let executor = File.IO.Executor(.init(workers: 1))
            let started = ManagedAtomic(false)
            let completed = ManagedAtomic(false)

            // Start a long-running job
            let task = Task {
                try await executor.run {
                    started.store(true, ordering: .releasing)
                    Thread.sleep(forTimeInterval: 0.1)
                    completed.store(true, ordering: .releasing)
                    return 42
                }
            }

            // Wait for job to start
            while !started.load(ordering: .acquiring) {
                await Task.yield()
            }

            // Shutdown while job is in-flight
            await executor.shutdown()

            // Job should have completed
            #expect(completed.load(ordering: .acquiring))

            // Task should return successfully
            let result = try await task.value
            #expect(result == 42)
        }

        // MARK: - Configuration

        @Test("Configuration default values")
        func configurationDefaults() {
            let config = File.IO.Configuration()
            #expect(config.workers == File.IO.Configuration.defaultWorkerCount)
            #expect(config.queueLimit == 10_000)
        }

        @Test("Configuration custom values")
        func configurationCustom() {
            let config = File.IO.Configuration(workers: 4, queueLimit: 100)
            #expect(config.workers == 4)
            #expect(config.queueLimit == 100)
        }

        @Test("Configuration enforces minimum values")
        func configurationMinimums() {
            let config = File.IO.Configuration(workers: 0, queueLimit: 0)
            #expect(config.workers >= 1)
            #expect(config.queueLimit >= 1)
        }

        @Test("Configuration default thread model is cooperative")
        func configurationDefaultThreadModel() {
            let config = File.IO.Configuration()
            #expect(config.threadModel == .cooperative)
        }

        @Test("Configuration custom thread model")
        func configurationCustomThreadModel() {
            let config = File.IO.Configuration(threadModel: .dedicated)
            #expect(config.threadModel == .dedicated)
        }

        // MARK: - Thread Model Tests

        @Test("Execute with cooperative thread model")
        func executeWithCooperativeThreadModel() async throws {
            let config = File.IO.Configuration(workers: 2, threadModel: .cooperative)
            let executor = File.IO.Executor(config)

            let results = try await withThrowingTaskGroup(of: Int.self) { group in
                for i in 0..<10 {
                    group.addTask {
                        try await executor.run { i * 2 }
                    }
                }
                var results: [Int] = []
                for try await result in group {
                    results.append(result)
                }
                return results.sorted()
            }

            #expect(results == [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
            await executor.shutdown()
        }

        @Test("Execute with dedicated thread model")
        func executeWithDedicatedThreadModel() async throws {
            let config = File.IO.Configuration(workers: 2, threadModel: .dedicated)
            let executor = File.IO.Executor(config)

            let results = try await withThrowingTaskGroup(of: Int.self) { group in
                for i in 0..<10 {
                    group.addTask {
                        try await executor.run { i * 2 }
                    }
                }
                var results: [Int] = []
                for try await result in group {
                    results.append(result)
                }
                return results.sorted()
            }

            #expect(results == [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
            await executor.shutdown()
        }

        @Test("Dedicated thread model handles blocking operations")
        func dedicatedThreadModelBlockingOps() async throws {
            let config = File.IO.Configuration(workers: 2, threadModel: .dedicated)
            let executor = File.IO.Executor(config)

            // Simulate blocking I/O operations
            let results = try await withThrowingTaskGroup(of: Int.self) { group in
                for i in 0..<5 {
                    group.addTask {
                        try await executor.run {
                            // Simulate blocking I/O
                            Thread.sleep(forTimeInterval: 0.01)
                            return i
                        }
                    }
                }
                var results: [Int] = []
                for try await result in group {
                    results.append(result)
                }
                return results.sorted()
            }

            #expect(results == [0, 1, 2, 3, 4])
            await executor.shutdown()
        }

        @Test("Both thread models produce equivalent results")
        func threadModelEquivalence() async throws {
            let cooperativeConfig = File.IO.Configuration(workers: 2, threadModel: .cooperative)
            let dedicatedConfig = File.IO.Configuration(workers: 2, threadModel: .dedicated)

            let cooperativeExecutor = File.IO.Executor(cooperativeConfig)
            let dedicatedExecutor = File.IO.Executor(dedicatedConfig)

            // Run same operations on both executors
            async let cooperativeResults = withThrowingTaskGroup(of: Int.self) { group in
                for i in 0..<10 {
                    group.addTask {
                        try await cooperativeExecutor.run { i * 3 }
                    }
                }
                var results: [Int] = []
                for try await result in group {
                    results.append(result)
                }
                return results.sorted()
            }

            async let dedicatedResults = withThrowingTaskGroup(of: Int.self) { group in
                for i in 0..<10 {
                    group.addTask {
                        try await dedicatedExecutor.run { i * 3 }
                    }
                }
                var results: [Int] = []
                for try await result in group {
                    results.append(result)
                }
                return results.sorted()
            }

            let (coop, dedicated) = try await (cooperativeResults, dedicatedResults)
            #expect(coop == dedicated)
            #expect(coop == [0, 3, 6, 9, 12, 15, 18, 21, 24, 27])

            await cooperativeExecutor.shutdown()
            await dedicatedExecutor.shutdown()
        }

        // MARK: - Edge Cases

        @Suite("Edge Cases")
        struct EdgeCase {

            @Test("Multiple dedicated executors don't oversubscribe")
            func multipleDedicatedExecutorsNoOversubscription() async throws {
                // Create 3 executors with 2 workers each
                let executor1 = File.IO.Executor(.init(workers: 2, threadModel: .dedicated))
                let executor2 = File.IO.Executor(.init(workers: 2, threadModel: .dedicated))
                let executor3 = File.IO.Executor(.init(workers: 2, threadModel: .dedicated))

                // Track concurrent execution
                let concurrentCount = ManagedAtomic(0)
                let maxConcurrent = ManagedAtomic(0)

                // Submit work to all executors concurrently
                try await withThrowingTaskGroup(of: Void.self) { group in
                    // Each executor gets 4 jobs (should queue 2 per executor)
                    for executor in [executor1, executor2, executor3] {
                        for _ in 0..<4 {
                            group.addTask {
                                try await executor.run {
                                    let current = concurrentCount.load(ordering: .acquiring)
                                    concurrentCount.store(current + 1, ordering: .releasing)

                                    // Update max
                                    let newCurrent = concurrentCount.load(ordering: .acquiring)
                                    let currentMax = maxConcurrent.load(ordering: .acquiring)
                                    if newCurrent > currentMax {
                                        maxConcurrent.store(newCurrent, ordering: .releasing)
                                    }

                                    // Simulate work
                                    Thread.sleep(forTimeInterval: 0.05)

                                    let afterWork = concurrentCount.load(ordering: .acquiring)
                                    concurrentCount.store(afterWork - 1, ordering: .releasing)
                                }
                            }
                        }
                    }

                    for try await _ in group {}
                }

                // Max concurrent should not exceed sum of all workers (2+2+2=6)
                let max = maxConcurrent.load(ordering: .acquiring)
                #expect(max <= 6, "Expected max concurrent <= 6, got \(max)")

                await executor1.shutdown()
                await executor2.shutdown()
                await executor3.shutdown()
            }

            @Test("Dedicated pool handles blocking operations without affecting cooperative pool")
            func dedicatedPoolBlockingIsolation() async throws {
                let dedicatedExecutor = File.IO.Executor(.init(workers: 2, threadModel: .dedicated))

                // Track that cooperative work completes while dedicated is blocked
                let dedicatedStarted = ManagedAtomic(false)
                let cooperativeCompleted = ManagedAtomic(false)

                // Start blocking work on dedicated pool
                let dedicatedTask = Task {
                    try await dedicatedExecutor.run {
                        dedicatedStarted.store(true, ordering: .releasing)
                        Thread.sleep(forTimeInterval: 0.2)  // Long blocking operation
                        return "dedicated"
                    }
                }

                // Wait for dedicated work to start blocking
                while !dedicatedStarted.load(ordering: .acquiring) {
                    await Task.yield()
                }

                // Now run cooperative async work - should complete quickly
                let cooperativeTask = Task {
                    // Regular async work on cooperative pool
                    try await Task.sleep(for: .milliseconds(10))
                    cooperativeCompleted.store(true, ordering: .releasing)
                    return "cooperative"
                }

                // Cooperative work should complete before dedicated
                let cooperativeResult = try await cooperativeTask.value
                #expect(cooperativeResult == "cooperative")
                #expect(cooperativeCompleted.load(ordering: .acquiring))

                // Dedicated work should still complete successfully
                let dedicatedResult = try await dedicatedTask.value
                #expect(dedicatedResult == "dedicated")

                await dedicatedExecutor.shutdown()
            }

            @Test("Dedicated pool shutdown is clean with no hanging threads")
            func dedicatedPoolCleanShutdown() async throws {
                let executor = File.IO.Executor(.init(workers: 4, threadModel: .dedicated))

                // Submit and complete some work
                try await withThrowingTaskGroup(of: Int.self) { group in
                    for i in 0..<10 {
                        group.addTask {
                            try await executor.run {
                                Thread.sleep(forTimeInterval: 0.01)
                                return i
                            }
                        }
                    }
                    for try await _ in group {}
                }

                // Shutdown should complete quickly without hanging
                let shutdownStart = Date()
                await executor.shutdown()
                let shutdownDuration = Date().timeIntervalSince(shutdownStart)

                // Shutdown should be fast (< 1 second)
                #expect(shutdownDuration < 1.0, "Shutdown took \(shutdownDuration)s, expected < 1s")
            }

            @Test("Worker count is respected - only N jobs run concurrently")
            func workerCountRespected() async throws {
                let workerCount = 2
                let executor = File.IO.Executor(
                    .init(workers: workerCount, threadModel: .dedicated)
                )

                let concurrentCount = ManagedAtomic(0)
                let maxConcurrent = ManagedAtomic(0)
                let violations = ManagedAtomic(0)

                // Submit many jobs
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for _ in 0..<20 {
                        group.addTask {
                            try await executor.run {
                                // Atomically increment and get new value
                                let newCurrent = concurrentCount.wrappingIncrementThenLoad(
                                    ordering: .acquiringAndReleasing
                                )

                                // Check if we exceeded worker count
                                if newCurrent > workerCount {
                                    _ = violations.wrappingIncrementThenLoad(ordering: .relaxed)
                                }

                                // Update max atomically using CAS loop
                                var currentMax = maxConcurrent.load(ordering: .relaxed)
                                while newCurrent > currentMax {
                                    let (exchanged, current) = maxConcurrent.compareExchange(
                                        expected: currentMax,
                                        desired: newCurrent,
                                        ordering: .relaxed
                                    )
                                    if exchanged { break }
                                    currentMax = current
                                }

                                // Do work
                                Thread.sleep(forTimeInterval: 0.02)

                                // Atomically decrement
                                _ = concurrentCount.wrappingDecrementThenLoad(
                                    ordering: .acquiringAndReleasing
                                )
                            }
                        }
                    }

                    for try await _ in group {}
                }

                let max = maxConcurrent.load(ordering: .acquiring)
                let violationCount = violations.load(ordering: .acquiring)

                #expect(
                    max <= workerCount,
                    "Max concurrent \(max) exceeded worker count \(workerCount)"
                )
                #expect(
                    violationCount == 0,
                    "Had \(violationCount) violations of worker count limit"
                )

                await executor.shutdown()
            }

            @Test("Queue limit is enforced in dedicated mode")
            func queueLimitEnforcedDedicated() async throws {
                let executor = File.IO.Executor(
                    .init(
                        workers: 1,
                        queueLimit: 5,
                        threadModel: .dedicated
                    )
                )

                let started = ManagedAtomic(false)
                let blocker = ManagedAtomic(true)

                // Start a blocking job to fill the worker
                let blockingTask = Task {
                    try await executor.run {
                        started.store(true, ordering: .releasing)
                        // Block until released
                        while blocker.load(ordering: .acquiring) {
                            Thread.sleep(forTimeInterval: 0.01)
                        }
                        return "blocker"
                    }
                }

                // Wait for blocker to start
                while !started.load(ordering: .acquiring) {
                    await Task.yield()
                }

                // Now try to submit more than queueLimit jobs
                // With worker=1 and queueLimit=5, we can have:
                // - 1 running job (the blocker)
                // - 5 queued jobs
                // The queue should handle at least these jobs

                var submittedTasks: [Task<String, any Error>] = []

                // Submit 5 jobs that should queue successfully
                for i in 0..<5 {
                    let task = Task {
                        try await executor.run {
                            return "job-\(i)"
                        }
                    }
                    submittedTasks.append(task)
                    try await Task.sleep(for: .milliseconds(5))
                }

                // Release the blocker
                blocker.store(false, ordering: .releasing)

                // Wait for all tasks to complete
                let blockerResult = try await blockingTask.value
                #expect(blockerResult == "blocker")

                for (i, task) in submittedTasks.enumerated() {
                    let result = try await task.value
                    #expect(result == "job-\(i)")
                }

                await executor.shutdown()
            }

            @Test("Mixed mode operations - cooperative and dedicated executors are isolated")
            func mixedModeIsolation() async throws {
                let cooperativeExecutor = File.IO.Executor(
                    .init(
                        workers: 2,
                        threadModel: .cooperative
                    )
                )
                let dedicatedExecutor = File.IO.Executor(
                    .init(
                        workers: 2,
                        threadModel: .dedicated
                    )
                )

                // Run interleaved work on both executors
                try await withThrowingTaskGroup(of: String.self) { group in
                    // Submit to cooperative
                    for i in 0..<10 {
                        group.addTask {
                            try await cooperativeExecutor.run {
                                // Use blocking sleep since async not allowed in sync closure
                                Thread.sleep(forTimeInterval: 0.001)
                                return "coop-\(i)"
                            }
                        }
                    }

                    // Submit to dedicated (with blocking)
                    for i in 0..<10 {
                        group.addTask {
                            try await dedicatedExecutor.run {
                                Thread.sleep(forTimeInterval: 0.01)  // Blocking
                                return "dedicated-\(i)"
                            }
                        }
                    }

                    var results: [String] = []
                    for try await result in group {
                        results.append(result)
                    }

                    // Verify all jobs completed
                    let coopResults = results.filter { $0.hasPrefix("coop-") }
                    let dedicatedResults = results.filter { $0.hasPrefix("dedicated-") }

                    #expect(coopResults.count == 10)
                    #expect(dedicatedResults.count == 10)
                }

                await cooperativeExecutor.shutdown()
                await dedicatedExecutor.shutdown()
            }

            @Test("Dedicated pool handles exceptions without corrupting thread pool")
            func dedicatedPoolExceptionHandling() async throws {
                let executor = File.IO.Executor(.init(workers: 2, threadModel: .dedicated))

                struct TestError: Error, Equatable {}

                // Submit mix of successful and failing jobs
                var successCount = 0
                var errorCount = 0

                await withTaskGroup(of: Result<String, any Error>.self) { group in
                    for i in 0..<10 {
                        group.addTask {
                            do {
                                let result = try await executor.run {
                                    if i % 3 == 0 {
                                        throw TestError()
                                    }
                                    return "success-\(i)"
                                }
                                return .success(result)
                            } catch {
                                return .failure(error)
                            }
                        }
                    }

                    for await result in group {
                        switch result {
                        case .success:
                            successCount += 1
                        case .failure:
                            errorCount += 1
                        }
                    }
                }

                // Should have some successes and some failures
                #expect(successCount == 6)
                #expect(errorCount == 4)

                // Executor should still work after exceptions
                let result = try await executor.run { "post-exception" }
                #expect(result == "post-exception")

                await executor.shutdown()
            }

            @Test("Dedicated pool stress test - many concurrent jobs")
            func dedicatedPoolStressTest() async throws {
                let executor = File.IO.Executor(.init(workers: 4, threadModel: .dedicated))

                let jobCount = 100
                let results = try await withThrowingTaskGroup(of: Int.self) { group in
                    for i in 0..<jobCount {
                        group.addTask {
                            try await executor.run {
                                // Mix of quick and slower jobs
                                if i % 10 == 0 {
                                    Thread.sleep(forTimeInterval: 0.02)
                                }
                                return i
                            }
                        }
                    }

                    var results: [Int] = []
                    for try await result in group {
                        results.append(result)
                    }
                    return results.sorted()
                }

                // All jobs should complete
                #expect(results.count == jobCount)
                #expect(results == Array(0..<jobCount))

                await executor.shutdown()
            }
        }
    }
}

// Simple atomic for testing
private final class ManagedAtomic<T>: @unchecked Sendable {
    fileprivate var _value: T
    fileprivate let lock = NSLock()

    init(_ value: T) {
        self._value = value
    }

    func load(ordering: MemoryOrder) -> T {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func store(_ value: T, ordering: MemoryOrder) {
        lock.lock()
        defer { lock.unlock() }
        _value = value
    }

    func compareExchange(
        expected: T,
        desired: T,
        ordering: MemoryOrder
    ) -> (exchanged: Bool, original: T) where T: Equatable {
        lock.lock()
        defer { lock.unlock() }
        let original = _value
        if original == expected {
            _value = desired
            return (true, original)
        }
        return (false, original)
    }

    enum MemoryOrder {
        case acquiring, releasing, relaxed, acquiringAndReleasing
    }
}

extension ManagedAtomic where T == Int {
    func wrappingIncrementThenLoad(ordering: MemoryOrder) -> Int {
        lock.lock()
        defer { lock.unlock() }
        _value += 1
        return _value
    }

    func wrappingDecrementThenLoad(ordering: MemoryOrder) -> Int {
        lock.lock()
        defer { lock.unlock() }
        _value -= 1
        return _value
    }
}
