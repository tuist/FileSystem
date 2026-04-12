//
//  String+DirectoryEntryName.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif os(Windows)
    import WinSDK
#endif

// MARK: - POSIX d_name

#if !os(Windows)
    extension String {
        /// Creates a string from a POSIX directory entry name (d_name).
        ///
        /// The `d_name` field in `dirent` is a fixed-size C character array.
        /// This initializer safely converts it to a Swift String.
        @usableFromInline
        internal init<T>(posixDirectoryEntryName dName: T) {
            self = withUnsafePointer(to: dName) { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX)) { cstr in
                    String(cString: cstr)
                }
            }
        }
    }
#endif

// MARK: - Windows cFileName

#if os(Windows)
    extension String {
        /// Creates a string from a Windows directory entry name (cFileName).
        ///
        /// The `cFileName` field in `WIN32_FIND_DATAW` is a fixed-size wide character array.
        /// This initializer safely converts it to a Swift String.
        @usableFromInline
        internal init<T>(windowsDirectoryEntryName cFileName: T) {
            self = withUnsafePointer(to: cFileName) { ptr in
                ptr.withMemoryRebound(to: UInt16.self, capacity: Int(MAX_PATH)) { wstr in
                    String(decodingCString: wstr, as: UTF16.self)
                }
            }
        }
    }
#endif
