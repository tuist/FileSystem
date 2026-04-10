//
//  File.IO.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Dispatch

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif os(Windows)
    import WinSDK
#endif

extension File {
    /// Namespace for I/O coordination.
    ///
    /// Contains the `Executor` for running blocking I/O operations
    /// on a bounded cooperative pool.
    public enum IO {}
}

extension File.IO {
    /// Configuration for the I/O executor.
    public struct Configuration: Sendable {
        /// Thread model for executing I/O operations.
        public enum ThreadModel: Sendable {
            /// Cooperative thread pool using `Task.detached`.
            ///
            /// Uses Swift's default cooperative thread pool. Under sustained blocking I/O,
            /// this can starve unrelated async work.
            case cooperative

            /// Dedicated thread pool using `DispatchQueue`.
            ///
            /// Creates explicit dispatch queues with user-initiated QoS.
            /// Prevents blocking I/O from starving the cooperative pool.
            case dedicated
        }

        /// Number of concurrent workers.
        public var workers: Int

        /// Maximum number of jobs in the queue.
        public var queueLimit: Int

        /// Thread model for worker execution.
        ///
        /// - `.cooperative`: Uses `Task.detached` (default, backward compatible)
        /// - `.dedicated`: Uses dedicated `DispatchQueue` instances
        public var threadModel: ThreadModel

        /// Default number of workers based on system resources.
        public static var defaultWorkerCount: Int {
            #if canImport(Darwin)
                return Int(sysconf(_SC_NPROCESSORS_ONLN))
            #elseif canImport(Glibc)
                return Int(sysconf(Int32(_SC_NPROCESSORS_ONLN)))
            #elseif os(Windows)
                return Int(GetActiveProcessorCount(ALL_PROCESSOR_GROUPS))
            #else
                return 4  // Fallback for unknown platforms
            #endif
        }

        /// Creates a configuration.
        ///
        /// - Parameters:
        ///   - workers: Number of concurrent workers (default: active processor count).
        ///   - queueLimit: Maximum queue size (default: 10,000).
        ///   - threadModel: Thread model for execution (default: `.cooperative`).
        public init(
            workers: Int? = nil,
            queueLimit: Int = 10_000,
            threadModel: ThreadModel = .cooperative
        ) {
            self.workers = max(1, workers ?? Self.defaultWorkerCount)
            self.queueLimit = max(1, queueLimit)
            self.threadModel = threadModel
        }

        /// Default configuration for the shared executor.
        ///
        /// Conservative settings designed for the common case:
        /// - Workers: half of available cores (minimum 2)
        /// - Queue limit: 256 (bounded but reasonable)
        /// - Thread model: cooperative (non-blocking for most I/O)
        public static let `default` = Self(
            workers: max(2, defaultWorkerCount / 2),
            queueLimit: 256,
            threadModel: .cooperative
        )
    }
}
