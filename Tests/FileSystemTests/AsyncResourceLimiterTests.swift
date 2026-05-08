import Testing
@testable import FileSystem

private enum AsyncResourceLimiterTestError: Error, Equatable {
    case exceededLimit
    case operationFailed
}

@Suite struct AsyncResourceLimiterTests {
    @Test func defaultMaximumConcurrentFileOperationsIsBounded() {
        let limit = FileSystem.defaultMaximumConcurrentFileOperations

        #expect(limit > 0)
        #expect(limit <= 256)
    }

    @Test func withPermitLimitsConcurrentOperations() async throws {
        let limit = 3
        let subject = AsyncResourceLimiter(limit: limit)
        let tracker = ConcurrentOperationTracker()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 24 {
                group.addTask {
                    try await subject.withPermit {
                        let activeOperations = await tracker.enter()
                        do {
                            if activeOperations > limit {
                                throw AsyncResourceLimiterTestError.exceededLimit
                            }
                            try await Task.sleep(nanoseconds: 5_000_000)
                            await tracker.leave()
                        } catch {
                            await tracker.leave()
                            throw error
                        }
                    }
                }
            }

            try await group.waitForAll()
        }

        let maximumActiveOperations = await tracker.maximumActiveOperations
        #expect(maximumActiveOperations == limit)
    }

    @Test func withPermitReleasesPermitWhenOperationThrows() async throws {
        let subject = AsyncResourceLimiter(limit: 1)

        do {
            try await subject.withPermit {
                throw AsyncResourceLimiterTestError.operationFailed
            }
            #expect(Bool(false), "Expected the operation to throw.")
        } catch AsyncResourceLimiterTestError.operationFailed {}

        let acquiredAfterFailure = try await subject.withPermit { true }

        #expect(acquiredAfterFailure)
    }
}

private actor ConcurrentOperationTracker {
    private var activeOperations = 0
    private(set) var maximumActiveOperations = 0

    func enter() -> Int {
        activeOperations += 1
        maximumActiveOperations = max(maximumActiveOperations, activeOperations)
        return activeOperations
    }

    func leave() {
        activeOperations -= 1
    }
}
