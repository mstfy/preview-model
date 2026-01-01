import Foundation

// MARK: - Core Protocols

/// A type that provides a default preview value for SwiftUI previews and testing.
///
/// Conform to this protocol to enable automatic preview data generation.
/// Types conforming to this protocol can be used as elements in collections.
///
/// Example:
/// ```swift
/// struct User: PreviewValueProtocol {
///     static var previewValue: User {
///         User(name: "John")
///     }
/// }
/// ```
public protocol PreviewValueProtocol {
    /// A default instance for use in SwiftUI previews and tests.
    static var previewValue: Self { get }
}

/// A type that provides preview values with configurable count.
///
/// Collection types conform to this protocol to enable generating
/// collections with a specific number of elements.
///
/// Example:
/// ```swift
/// let tags = Set<String>.previewValues(count: 5)
/// let scores = [String: Int].previewValues(count: 3)
/// ```
public protocol PreviewCollectionValueProtocol where Self: Collection {
    /// Creates a collection with the specified number of preview elements.
    /// - Parameter count: The number of elements to generate.
    /// - Returns: A collection with `count` elements.
    static func previewValues(count: UInt) -> Self
}

/// A type that generates unique preview values based on an index.
///
/// Required for `Set` elements and `Dictionary` keys to ensure uniqueness.
/// Primitive types like `String`, `Int`, `Date`, and `URL` conform to this protocol.
///
/// To use custom types in `Set` or as `Dictionary` keys, conform to this protocol:
/// ```swift
/// struct Tag: IndexedPreviewValueProtocol {
///     let id: Int
///     static var previewValue: Tag { Tag(id: 0) }
///     static func previewValue(at index: UInt) -> Tag { Tag(id: Int(index)) }
/// }
///
/// let tags: Set<Tag> = Set<Tag>.previewValues(count: 5)
/// ```
public protocol IndexedPreviewValueProtocol: PreviewValueProtocol {
    /// Creates a unique preview value for the given index.
    /// - Parameter index: The index used to generate a unique value.
    /// - Returns: A unique instance based on the index.
    static func previewValue(at index: UInt) -> Self
}

// MARK: - Optional Support
public extension Optional where Wrapped: PreviewValueProtocol {
    /// Returns the wrapped type's preview value (non-nil).
    static var previewValue: Wrapped? {
        return Wrapped.previewValue
    }
}

// MARK: - Collection Conformances
extension Array: PreviewValueProtocol where Element: PreviewValueProtocol {
    /// Returns an array with 5 elements using `Element.previewValue`.
    public static var previewValue: Array<Element> {
        Array(repeating: Element.previewValue, count: 5)
    }
}

extension Set: PreviewValueProtocol where Element: IndexedPreviewValueProtocol {
    /// Returns a set with 5 unique elements using `Element.previewValue(at:)`.
    public static var previewValue: Set<Element> {
        previewValues(count: 5)
    }
}

extension Set: PreviewCollectionValueProtocol where Element: IndexedPreviewValueProtocol {
    /// Creates a set with the specified count of unique elements.
    /// - Parameter count: Number of elements to generate.
    /// - Returns: Set with `count` unique elements.
    /// - Note: Requires `Element: IndexedPreviewValueProtocol` to ensure uniqueness.
    public static func previewValues(count: UInt) -> Set<Element> {
        Set((0..<count).map { Element.previewValue(at: $0) })
    }
}

extension Dictionary: PreviewValueProtocol where Key: IndexedPreviewValueProtocol, Value: PreviewValueProtocol {
    /// Returns a dictionary with 3 entries using indexed keys and `Value.previewValue`.
    public static var previewValue: Dictionary<Key, Value> {
        previewValues(count: 3)
    }
}

extension Dictionary: PreviewCollectionValueProtocol where Key: IndexedPreviewValueProtocol, Value: PreviewValueProtocol {
    /// Creates a dictionary with the specified count of unique key-value pairs.
    /// - Parameter count: Number of entries to generate.
    /// - Returns: Dictionary with `count` entries.
    /// - Note: Requires `Key: IndexedPreviewValueProtocol` to ensure key uniqueness.
    public static func previewValues(count: UInt) -> Dictionary<Key, Value> {
        Dictionary(uniqueKeysWithValues: (0..<count).map { (Key.previewValue(at: $0), Value.previewValue) })
    }
}

// MARK: - Update Helpers

/// Creates a modified copy of a preview value using a closure.
/// - Parameters:
///   - val: The value to copy and modify.
///   - update: A closure that modifies the copy.
/// - Returns: The modified copy.
///
/// Example:
/// ```swift
/// let admin = update(User.previewValue) { $0.isAdmin = true }
/// ```
public func update<Value: PreviewValueProtocol>(
    _ val: Value,
    _ update: (inout Value) -> Void
) -> Value {
    var val = val
    update(&val)
    return val
}

public extension PreviewValueProtocol {
    /// Creates a modified copy with the specified key path updated.
    /// - Parameters:
    ///   - key: The key path to update.
    ///   - value: The new value.
    /// - Returns: A copy with the updated value.
    ///
    /// Example:
    /// ```swift
    /// let admin = User.previewValue.update(\.isAdmin, true)
    /// ```
    func update<Value>(
        _ key: WritableKeyPath<Self, Value>, _ value: Value
    ) -> Self {
        var copy = self
        copy[keyPath: key] = value
        return copy
    }
}

// MARK: - Indexed Preview Value Conformances
extension String: IndexedPreviewValueProtocol {
    /// Returns `"previewValue"`.
    public static var previewValue: String { "previewValue" }

    /// Returns `"previewValue_\(index)"` for unique string generation.
    public static func previewValue(at index: UInt) -> String { "previewValue_\(index)" }
}

extension Int: IndexedPreviewValueProtocol {
    /// Returns `0` by default.
    public static var previewValue: Int { 0 }

    /// Returns the index value as an Int.
    public static func previewValue(at index: UInt) -> Int { Int(index) }
}

extension Int64: IndexedPreviewValueProtocol {
    /// Returns `0` by default.
    public static var previewValue: Int64 { 0 }

    /// Returns the index value as an Int64.
    public static func previewValue(at index: UInt) -> Int64 { Int64(index) }
}

extension Double: IndexedPreviewValueProtocol {
    /// Returns `0.0` by default.
    public static var previewValue: Double { 0.0 }

    /// Returns the index value as a Double.
    public static func previewValue(at index: UInt) -> Double { Double(index) }
}

extension Float: IndexedPreviewValueProtocol {
    /// Returns `0.0` by default.
    public static var previewValue: Float { 0.0 }

    /// Returns the index value as a Float.
    public static func previewValue(at index: UInt) -> Float { Float(index) }
}

extension UUID: IndexedPreviewValueProtocol {
    /// Returns a new random UUID by default.
    public static var previewValue: UUID { UUID() }

    /// Returns a new random UUID (unique for each call).
    public static func previewValue(at index: UInt) -> UUID { UUID() }
}

extension Date: IndexedPreviewValueProtocol {
    /// Returns the current date and time by default.
    public static var previewValue: Date { Date() }

    /// Returns a date offset by `index` days from now.
    public static func previewValue(at index: UInt) -> Date {
        Date(timeIntervalSinceNow: TimeInterval(index) * 86_400)
    }
}

extension URL: IndexedPreviewValueProtocol {
    /// Returns `https://www.example.com`  by default.
    public static var previewValue: URL { URL(string: "https://www.example.com")! }

    /// Returns `https://www.example.com/\(index)` for unique URL generation.
    public static func previewValue(at index: UInt) -> URL {
        URL(string: "https://www.example.com/\(index)")!
    }
}

// MARK: - Preview Value Only Conformances

extension Bool: PreviewValueProtocol {
    /// Returns `true`.
    public static var previewValue: Bool { true }
}
