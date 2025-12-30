@attached(member, names: named(preview), named(previewValue))
@attached(extension, conformances: PreviewValueProtocol)
public macro PreviewModel() = #externalMacro(
  module: "PreviewModelMacros",
  type: "PreviewModelMacro"
)
