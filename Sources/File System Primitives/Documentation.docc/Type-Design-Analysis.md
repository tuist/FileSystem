# File and File.System Type Design: Academic Analysis

## Current State

```swift
public enum File {}           // Empty namespace
public enum File.System {}    // Empty namespace for operations
public struct File.Path {}    // Wraps SystemPackage.FilePath
public struct File.Handle {}  // ~Copyable, wraps File.Descriptor
public struct File.Descriptor {} // ~Copyable, raw file descriptor
```

Operations are static methods on nested enums:
```swift
File.System.Read.Full.read(from: path)
File.System.Write.Atomic.write(bytes, to: path)
```

---

## Question 1: What Should `File` Represent?

### Option A: File as Path-like Value Type

**Concept**: `File` represents a filesystem location (path), with operations as methods.

```swift
struct File: Hashable, Sendable {
    let path: Path  // or directly wraps FilePath

    func exists() -> Bool
    func isDirectory() -> Bool
    func read() throws -> [UInt8]
    func delete() throws
    // ...
}

let file = File("/tmp/data.txt")
let contents = try file.read()
```

**Academic Basis**:
- Python's `pathlib.Path` - operations on path objects
- Ruby's `Pathname`
- This models "a file" as "a location that may or may not exist"

**Pros**:
- Intuitive OO interface: `file.read()` vs `File.System.Read.Full.read(from: path)`
- Discoverability via autocomplete on `file.`
- Path and operations unified in one type

**Cons**:
- **Conflates two concepts**: A path (pure data) vs filesystem operations (effects)
- **Hidden side effects**: `file.read()` looks pure but performs I/O
- **Not referentially transparent**: Same `file.read()` can return different results
- **Mutable world illusion**: Suggests the File object "contains" data, but it's just a reference

**Academic Verdict**: **Impure**. Violates separation of concerns. A value type should represent immutable data, not be a facade over effectful operations.

---

### Option B: File as Open Resource Type (Rust model)

**Concept**: `File` represents an open file handle. Must explicitly open/close.

```swift
struct File: ~Copyable {
    static func open(_ path: Path, mode: Mode) throws -> File
    mutating func read(count: Int) throws -> [UInt8]
    mutating func write(_ bytes: [UInt8]) throws
    consuming func close()
}
```

**Academic Basis**:
- Rust's `std::fs::File`
- C's `FILE*`
- Linear types / affine types theory

**Pros**:
- **Explicit resource lifecycle**: Open → use → close
- **~Copyable enforces ownership**: Can't accidentally duplicate handle
- **Clear semantics**: File means "open file", not "path to file"

**Cons**:
- **Name collision**: "File" commonly means "a file on disk", not "open handle"
- **We already have this**: It's called `File.Handle`
- Renaming `File.Handle` to `File` would be confusing

**Academic Verdict**: **Correct semantically**, but naming is wrong. `Handle` is the right name for this concept.

---

### Option C: File as Pure Namespace (Current)

**Concept**: `File` is an empty enum that namespaces related types.

```swift
enum File {
    struct Path { ... }
    struct Handle: ~Copyable { ... }
    struct Descriptor: ~Copyable { ... }
    enum System { ... }
}
```

**Academic Basis**:
- Module/namespace pattern
- Swift's own approach (e.g., `Calendar.Component`, `URLSession.Configuration`)
- Separates path (data) from handle (resource) from operations

**Pros**:
- **Clean separation of concerns**:
  - `File.Path` = pure data (location)
  - `File.Handle` = linear resource (open file)
  - `File.System.*` = effectful operations
- **No semantic confusion**: Each type has clear meaning
- **Extensible**: Easy to add `File.Watcher`, `File.Lock`, etc.

**Cons**:
- `File` itself is "useless" - just a namespace
- Verbose: `File.System.Read.Full.read(from:)`
- Less discoverable than `file.read()`

**Academic Verdict**: **Most principled**. Cleanly separates pure data, linear resources, and effects.

---

### Option D: Hybrid - File as Path + Convenience Methods

**Concept**: `File` wraps a path and provides convenience methods that delegate to `File.System.*`

```swift
struct File: Hashable, Sendable {
    let path: Path

    // Convenience - delegates to File.System.Read.Full.read
    func read() throws -> [UInt8] {
        try File.System.Read.Full.read(from: path)
    }

    // Pure queries - no hidden I/O in these
    var parent: File? { path.parent.map(File.init) }
    var name: String { path.lastComponent?.string ?? "" }
}
```

**Academic Basis**:
- Facade pattern
- Convenience layer over pure core

**Pros**:
- Ergonomic: `file.read()`
- Pure core preserved: `File.System.*` still available
- `File` is Hashable/Sendable (just wraps path)

**Cons**:
- Still conflates path and operations in the API
- `file.read()` looks like a property access but does I/O
- Duplicates API surface

**Academic Verdict**: **Pragmatic compromise**. Acceptable if clearly documented that methods perform I/O.

---

## Question 2: What Should `File.System` Represent?

### Current: Namespace for Operations

```swift
enum File.System {
    enum Read { enum Full { static func read() } }
    enum Write { enum Atomic { static func write() } }
}
```

**Analysis**: Pure namespace. Static methods perform effects. No state.

### Alternative: Protocol-Based FileSystem

```swift
protocol FileSystem {
    func read(from: File.Path) throws -> [UInt8]
    func write(_ bytes: [UInt8], to: File.Path) throws
    func exists(_ path: File.Path) -> Bool
}

struct LocalFileSystem: FileSystem { ... }
struct InMemoryFileSystem: FileSystem { ... }
```

**Pros**:
- Testability: Mock filesystem in tests
- Portability: Different implementations
- Dependency injection

**Cons**:
- Added complexity
- Must pass FileSystem instance everywhere
- Real filesystem is a singleton anyway

**Academic Verdict**: Protocol is more flexible but adds ceremony. For a primitives library, static methods are acceptable.

### Future Extension: Actor for Async Coordination

If async coordination is needed, an actor can be added:
```swift
extension File.System {
    actor Actor {
        func read(from path: File.Path) async throws -> [UInt8]
    }
}
```

---

## Question 3: File.Path vs SystemPackage.FilePath

### Option A: Typealias

```swift
public typealias Path = SystemPackage.FilePath
// or
extension File {
    public typealias Path = SystemPackage.FilePath
}
```

**Pros**:
- Zero overhead
- Full API compatibility with swift-system ecosystem
- No wrapper maintenance
- Users familiar with FilePath get identical behavior

**Cons**:
- **No validation at construction**: FilePath allows empty paths, control chars
- **Loses our invariants**: File.Path guarantees non-empty, no control chars
- **API surface we don't control**: FilePath may add methods we don't want
- **Different error types**: FilePath operations throw different errors

### Option B: Struct Wrapper (Current)

```swift
struct File.Path {
    internal var _path: FilePath
    init(_ string: String) throws(Error) { /* validates */ }
}
```

**Pros**:
- **Validation guarantees**: Non-empty, no control characters
- **Controlled API surface**: Expose only what we want
- **Custom error types**: Consistent with rest of library
- **Can add methods FilePath doesn't have**

**Cons**:
- Maintenance burden
- Conversion needed for interop (`path.filePath`)
- Slight overhead (negligible)

### Option C: Conditional Extension (No Wrapper, Add Validation via Factory)

```swift
extension FilePath {
    static func validated(_ string: String) throws -> FilePath {
        guard !string.isEmpty else { throw ... }
        // ...
        return FilePath(string)
    }
}
public typealias File.Path = FilePath
```

**Pros**:
- Direct use of FilePath
- Validation available but optional

**Cons**:
- Validation not enforced at type level
- Easy to bypass

---

## Recommendation

### For `File` Type:

**Keep as namespace** (Option C) in Primitives layer.

In the convenience layer (File System target), optionally add **Option D (Hybrid)**:

```swift
// In File System (convenience layer)
extension File {
    /// A file at a specific path, providing convenient access to operations.
    struct Instance: Hashable, Sendable {
        public let path: File.Path

        public init(_ path: File.Path) { self.path = path }
        public init(_ string: String) throws { self.path = try File.Path(string) }

        // Convenience I/O methods
        public func read() throws -> [UInt8] {
            try File.System.Read.Full.read(from: path)
        }

        public func exists() -> Bool {
            File.System.Stat.exists(path)
        }

        // Pure path operations
        public var parent: Instance? { path.parent.map(Instance.init) }
        public var name: String { path.lastComponent?.string ?? "" }
    }
}

// Usage
let file = File.Instance("/tmp/data.txt")
let data = try file.read()
```

This preserves the principled primitives layer while providing ergonomic convenience.

### For `File.System`:

Keep as namespace. Add `File.System.Actor` if async coordination needed later.

### For `File.Path`:

**Keep struct wrapper** (Option B). The validation guarantees are valuable:
- Prevents bugs from empty paths
- Prevents security issues from control characters
- Type-level guarantee, not runtime check

---

## Summary Table

| Type | Current | Recommendation |
|------|---------|----------------|
| `File` | Empty enum namespace | Keep as namespace |
| `File.Path` | Struct wrapping FilePath | Keep (validation valuable) |
| `File.Handle` | ~Copyable struct | Keep as-is |
| `File.System` | Nested enum namespace | Keep as namespace |
| New: `File.Instance` | N/A | Optional: add in convenience layer |

---

## Conclusion

The current design is academically principled:

1. **Separation of concerns**: Path (data), Handle (resource), System (effects)
2. **Type safety**: File.Path validates at construction
3. **Resource safety**: ~Copyable types prevent handle leaks
4. **Extensibility**: Namespace pattern allows growth

The tradeoff is verbosity (`File.System.Read.Full.read(from:)`) vs ergonomics (`file.read()`). If ergonomics are needed, add convenience wrappers in the File System layer while keeping primitives pure.
