// Duration.swift
// swift-standards
//
// Extensions for Swift standard library Duration

#if compiler(>=5.7)

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    extension Duration {
        /// Create a Duration from seconds
        ///
        /// Converts floating-point seconds to Duration with nanosecond precision.
        ///
        /// Example:
        /// ```swift
        /// let duration = Duration.seconds(1.5)  // 1 second, 500 milliseconds
        /// let duration2 = Duration.seconds(0.001)  // 1 millisecond
        /// ```
        public static func seconds(_ value: Double) -> Duration {
            let components = value.splitIntegerAndFraction()
            return .seconds(Int64(components.integer))
                + .nanoseconds(Int64(components.fraction * 1_000_000_000))
        }

        /// Convert Duration to seconds as Double
        ///
        /// Example:
        /// ```swift
        /// let duration = Duration.seconds(1) + Duration.milliseconds(500)
        /// duration.inSeconds  // 1.5
        /// ```
        public var inSeconds: Double {
            let (seconds, attoseconds) = self.components
            return Double(seconds) + (Double(attoseconds) / 1_000_000_000_000_000_000.0)
        }

        /// Convert Duration to milliseconds
        ///
        /// Example:
        /// ```swift
        /// let duration = Duration.seconds(1.5)
        /// duration.inMilliseconds  // 1500.0
        /// ```
        public var inMilliseconds: Double {
            inSeconds * 1000
        }

        /// Convert Duration to microseconds
        ///
        /// Example:
        /// ```swift
        /// let duration = Duration.milliseconds(1)
        /// duration.inMicroseconds  // 1000.0
        /// ```
        public var inMicroseconds: Double {
            inSeconds * 1_000_000
        }

        /// Convert Duration to nanoseconds
        ///
        /// Example:
        /// ```swift
        /// let duration = Duration.microseconds(1)
        /// duration.inNanoseconds  // 1000.0
        /// ```
        public var inNanoseconds: Double {
            inSeconds * 1_000_000_000
        }
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    extension Double {
        fileprivate func splitIntegerAndFraction() -> (integer: Int64, fraction: Double) {
            let integer = Int64(self)
            let fraction = self - Double(integer)
            return (integer, fraction)
        }
    }
#endif
