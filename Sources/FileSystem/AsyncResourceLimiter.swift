import Foundation

actor AsyncResourceLimiter {
    private struct Waiter {
        let id: UUID
        let continuation: CheckedContinuation<Bool, Never>
    }

    private let limitProvider: @Sendable () -> Int
    private var limit: Int
    private var activePermits = 0
    private var waiters: [Waiter] = []

    init(limit: Int) {
        precondition(limit > 0, "AsyncResourceLimiter limit must be greater than zero.")
        self.init(limitProvider: { limit })
    }

    init(limitProvider: @escaping @Sendable () -> Int) {
        let limit = limitProvider()
        precondition(limit > 0, "AsyncResourceLimiter limit must be greater than zero.")
        self.limitProvider = limitProvider
        self.limit = limit
    }

    func withPermit<T>(_ operation: @Sendable () async throws -> T) async throws -> T {
        try await acquire()

        do {
            try Task.checkCancellation()
            let value = try await operation()
            release()
            return value
        } catch {
            release()
            throw error
        }
    }

    private func acquire() async throws {
        try Task.checkCancellation()
        refreshLimit()

        if activePermits < limit, waiters.isEmpty {
            activePermits += 1
            return
        }

        let waiterID = UUID()
        let wasGrantedPermit = await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                waiters.append(Waiter(id: waiterID, continuation: continuation))
                grantAvailablePermits()
            }
        } onCancel: {
            Task { await self.cancelWaiter(id: waiterID) }
        }

        guard wasGrantedPermit else {
            throw CancellationError()
        }
    }

    private func release() {
        refreshLimit()
        activePermits -= 1
        precondition(activePermits >= 0, "AsyncResourceLimiter released more permits than it acquired.")
        grantAvailablePermits()
    }

    private func refreshLimit() {
        let refreshedLimit = limitProvider()
        precondition(refreshedLimit > 0, "AsyncResourceLimiter limit must be greater than zero.")
        limit = refreshedLimit
    }

    private func grantAvailablePermits() {
        while activePermits < limit, !waiters.isEmpty {
            let waiter = waiters.removeFirst()
            activePermits += 1
            waiter.continuation.resume(returning: true)
        }
    }

    private func cancelWaiter(id: UUID) {
        guard let index = waiters.firstIndex(where: { $0.id == id }) else { return }
        let waiter = waiters.remove(at: index)
        waiter.continuation.resume(returning: false)
        refreshLimit()
        grantAvailablePermits()
    }
}
