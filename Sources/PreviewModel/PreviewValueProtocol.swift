import Foundation

public protocol PreviewValueProtocol {
  static var previewValue: Self { get }
}

public extension Optional where Wrapped: PreviewValueProtocol {
  static var previewValue: Wrapped? {
    return Wrapped.previewValue
  }
}

extension Array: PreviewValueProtocol where Element: PreviewValueProtocol {
  public static var previewValue: [Element] {
    (0..<5).map { _ in Element.previewValue }
  }
}

extension Set: PreviewValueProtocol where Element: PreviewValueProtocol {
  public static var previewValue: Set<Element> { Set(Array<Element>.previewValue) }
}

extension Dictionary: PreviewValueProtocol where Key == String, Value: PreviewValueProtocol {
  public static var previewValue: [String: Value] {
    let n = Int.random(in: 1...3)
    var dict: [String: Value] = [:]
    for i in 1...n { dict["key\(i)"] = Value.previewValue }
    return dict
  }
}

public func update<Value: PreviewValueProtocol>(
  _ val: Value,
  _ update: (inout Value) -> Void
) -> Value {
  var val = val
  update(&val)
  return val
}

public extension PreviewValueProtocol {
  func update<Value>(
    _ key: WritableKeyPath<Self, Value>, _ value: Value
  ) -> Self {
    var copy = self
    copy[keyPath: key] = value
    return copy
  }
}
