import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import SwiftSyntaxMacros
import Foundation

public struct PreviewModelMacro: MemberMacro, ExtensionMacro {

  // Generate members
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf decl: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    // Enum support
    if let enumDecl = decl.as(EnumDeclSyntax.self) {
      let inheritsCaseIterable = enumDecl.inheritanceClause?.inheritedTypes.contains(where: { inherited in
        inherited.type.trimmedDescription == "CaseIterable"
      }) ?? false

      if inheritsCaseIterable {
        let previewValueMember: DeclSyntax =
        """
        static var previewValue: Self {
          Self.allCases.first!
        }
        """
        return [previewValueMember]
      } else if let simpleCase = firstSimpleEnumCaseName(in: enumDecl) {
        let previewValueMember: DeclSyntax =
        """
        static var previewValue: Self {
          .\(raw: strippedBackticks(simpleCase))
        }
        """
        return [previewValueMember]
      } else {
        // No suitable case found; don't emit anything
        return []
      }
    }

    // Struct/class support (existing)
    let props = storedProperties(in: decl)

    // Build args; special-case primitive types
    let args: [String] = props.enumerated().compactMap { idx, pair in
      guard let name = pair.0, let type = pair.1 else { return nil }
      if let arg = primitiveArg(for: name, type: type, index: idx) {
        return arg
      } else {
        return "\(name): \(type).previewValue"
      }
    }

    let initCall = "Self(\(args.joined(separator: ", ")))"

    // Always provide `previewValue` to satisfy the conformance.
    let previewValueMember: DeclSyntax =
    """
    static var previewValue: Self {
      \(raw: initCall)
    }
    """

    return [previewValueMember]
  }

  // Provide attached extensions (eg. to add conformances)
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    // If no conformances were requested, nothing to add.
    guard !protocols.isEmpty else { return [] }

    // Build: extension <Type>: Proto1, Proto2 {}
    let protocolList = protocols.map { $0.trimmedDescription }.joined(separator: ", ")

    let extDecl: DeclSyntax =
    """
    extension \(type.trimmed): \(raw: protocolList) {}
    """

    guard let ext = extDecl.as(ExtensionDeclSyntax.self) else {
      return []
    }

    return [ext]
  }
}

// MARK: - Helpers

private extension PreviewModelMacro {
  static func strippedBackticks(_ name: String) -> String {
    var result = name
    if result.hasPrefix("`") && result.hasSuffix("`") && result.count >= 2 {
      result.removeFirst()
      result.removeLast()
    }
    return result
  }

  static func storedProperties(in decl: some DeclGroupSyntax) -> [(String?, String?)] {
    var out: [(String?, String?)] = []

    for m in decl.memberBlock.members {
      guard let v = m.decl.as(VariableDeclSyntax.self) else { continue }

      // Skip type properties: static or class
      if v.modifiers.contains(where: { mod in
        let t = mod.name.text
        return t == "static" || t == "class"
      }) { continue }

      // Skip private/fileprivate declarations (but keep private(set))
      let isPrivateDecl = v.modifiers.contains { mod in
        let t = mod.name.text
        guard t == "private" || t == "fileprivate" else { return false }
        // detail == nil means it's not something like `private(set)`
        return mod.detail == nil
      }
      if isPrivateDecl { continue }

      // Determine if this declaration is a `let`
      let isLet = v.bindingSpecifier.text == "let"

      for b in v.bindings {
        // Skip computed properties:
        if let a = b.accessorBlock {
          switch a.accessors {
          case .getter:
            // getter-only computed property
            continue
          case .accessors(let list):
            // If any accessor is get/set, it's computed; willSet/didSet alone means stored with observers.
            let hasGetOrSet = list.contains { acc in
              let spec = acc.accessorSpecifier.text
              return spec == "get" || spec == "set"
            }
            if hasGetOrSet { continue }
          }
        }

        // Omit `let` properties that already have a default value
        if isLet, b.initializer != nil {
          continue
        }

        let nameRaw = b.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        let name = nameRaw.map { strippedBackticks($0) }
        // Require explicit type
        let type = b.typeAnnotation?.type.trimmedDescription
        out.append((name, type))
      }
    }

    return out
  }

  // Produce a literal arg for primitive types we special-case; otherwise nil.
  static func primitiveArg(for name: String, type: String, index: Int) -> String? {
    let base = normalizedTypeName(type)

    // --- Custom ID handling ---
    if name.range(of: "id", options: .caseInsensitive) != nil {
      switch base {
      case "String":
        return "\(name): UUID().uuidString"
      case "Int":
        return "\(name): Int.random(in: 1000...1000000)"
      case "Int64":
        return "\(name): Int64.random(in: 1000...1000000)"
      default:
        break
      }
    }

    // --- Custom image/icon URL handling ---
    if (name.range(of: "image", options: .caseInsensitive) != nil ||
        name.range(of: "icon", options: .caseInsensitive) != nil)
        && (base == "URL")
    {
      return "\(name): URL(string: \"https://www.gstatic.com/webp/gallery/4.jpg\")!"
    }

    // Arrays of primitive element types -> 5-element literals
    if let element = arrayElementType(from: base) {
      switch element {
      case "String":
        let items = (1...5).map { "\"\(name)_\($0)\"" }.joined(separator: ", ")
        return "\(name): [\(items)]"
      case "Int":
        return "\(name): [1, 2, 3, 4, 5]"
      case "Double":
        return "\(name): [1.0, 2.0, 3.0, 4.0, 5.0]"
      case "Float":
        let items = (1...5).map { "Float(\($0))" }.joined(separator: ", ")
        return "\(name): [\(items)]"
      case "Bool":
        return "\(name): [true, true, true, true, true]"
      case "URL":
        let items = (1...5).map { "URL(string: \"https://www.example.com/\($0)\")!" }.joined(separator: ", ")
        return "\(name): [\(items)]"
      default:
        break
      }
    }

    switch base {
    case "String":
      // Use the property name as the preview string.
      return "\(name): \"\(name)\""
    case "Int":
      return "\(name): 10"
    case "Double":
      // Random Double in 1...10 at runtime
      return "\(name): 10"
    case "Float":
      // Random Float in 1...10 at runtime
      return "\(name): 10"
    case "URL":
      // Example URL
      return "\(name): URL(string: \"https://www.example.com\")!"
    case "Bool":
      return "\(name): true"
    case "Date":
      return "\(name): Date()"
    default:
      return nil
    }
  }

  // Normalize a type's textual representation to a simple base name for checks.
  static func normalizedTypeName(_ type: String) -> String {
    var t = type.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

    // Strip module qualification
    if t.hasPrefix("Swift.") {
      t.removeFirst("Swift.".count)
    }
    if t.hasPrefix("Foundation.") {
      t.removeFirst("Foundation.".count)
    }

    // Remove trailing optional/implicitly-unwrapped markers
    while t.hasSuffix("?") || t.hasSuffix("!") {
      t.removeLast()
    }

    // Optional<T> -> T
    if t.hasPrefix("Optional<"), t.hasSuffix(">") {
      t = String(t.dropFirst("Optional<".count).dropLast())
    }

    return t
  }

  // Extract the element type from array syntax like "[T]" or "Array<T>"
  static func arrayElementType(from type: String) -> String? {
    let t = type

    // [T]
    if t.hasPrefix("["), t.hasSuffix("]") {
      let inner = String(t.dropFirst().dropLast())
      return normalizedTypeName(inner)
    }

    // Array<T> or Swift.Array<T>
    if t.hasPrefix("Array<") || t.hasPrefix("Swift.Array<") {
      let start = t.firstIndex(of: "<")!
      let end = t.lastIndex(of: ">")!
      let inner = String(t[t.index(after: start)..<end])
      return normalizedTypeName(inner)
    }

    return nil
  }

  static func firstSimpleEnumCaseName(in enumDecl: EnumDeclSyntax) -> String? {
    for member in enumDecl.memberBlock.members {
      guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
      for elem in caseDecl.elements {
        // Prefer a case without associated values
#if compiler(>=6.0)
        // SwiftSyntax 5.9+ naming
        if elem.parameterClause == nil {
          return elem.name.text
        }
#else
        // Fallback (older SwiftSyntax might use `associatedValue`)
        if elem.associatedValue == nil {
          return elem.identifier.text
        }
#endif
      }
    }
    return nil
  }
}

@main
struct PreviewModelPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    PreviewModelMacro.self
  ]
}
