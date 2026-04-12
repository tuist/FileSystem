//
//  File.System.Move+POSIX.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension File.System.Move {
        /// Moves a file using POSIX APIs.
        internal static func _movePOSIX(
            from source: File.Path,
            to destination: File.Path,
            options: Options
        ) throws(Error) {
            // Check if source exists
            var sourceStat = stat()
            guard stat(source.string, &sourceStat) == 0 else {
                throw _mapErrno(errno, source: source, destination: destination)
            }

            // Check if destination exists
            var destStat = stat()
            let destExists = stat(destination.string, &destStat) == 0

            if destExists && !options.overwrite {
                throw .destinationExists(destination)
            }

            // If overwrite is enabled and destination exists, remove it first
            // (rename on POSIX atomically replaces, but we check for option consistency)
            if destExists && options.overwrite {
                // rename() will atomically replace on same filesystem
            }

            // Try rename first (atomic, same device)
            if rename(source.string, destination.string) == 0 {
                return
            }

            let renameError = errno

            // If cross-device, fall back to copy+delete
            if renameError == EXDEV {
                try _copyAndDelete(from: source, to: destination, options: options)
                return
            }

            throw _mapErrno(renameError, source: source, destination: destination)
        }

        /// Fallback: copy then delete for cross-device moves.
        private static func _copyAndDelete(
            from source: File.Path,
            to destination: File.Path,
            options: Options
        ) throws(Error) {
            // Use Copy to copy the file
            let copyOptions = File.System.Copy.Options(
                overwrite: options.overwrite,
                copyAttributes: true,
                followSymlinks: true
            )

            do {
                try File.System.Copy._copyPOSIX(from: source, to: destination, options: copyOptions)
            } catch let copyError {
                // Map copy errors to move errors
                switch copyError {
                case .sourceNotFound(let path):
                    throw .sourceNotFound(path)
                case .destinationExists(let path):
                    throw .destinationExists(path)
                case .permissionDenied(let path):
                    throw .permissionDenied(path)
                case .isDirectory(let path):
                    throw .moveFailed(errno: EISDIR, message: "Is a directory: \(path)")
                case .copyFailed(let errno, let message):
                    throw .moveFailed(errno: errno, message: message)
                }
            }

            // Delete source
            if unlink(source.string) != 0 {
                // Source was copied but couldn't be deleted - log but don't fail
                // The move semantically succeeded (data is at destination)
            }
        }

        /// Maps errno to move error.
        private static func _mapErrno(
            _ errno: Int32,
            source: File.Path,
            destination: File.Path
        ) -> Error {
            switch errno {
            case ENOENT:
                return .sourceNotFound(source)
            case EEXIST:
                return .destinationExists(destination)
            case EACCES, EPERM:
                return .permissionDenied(source)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .moveFailed(errno: errno, message: message)
            }
        }
    }

#endif
