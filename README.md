# PreviewModel

Swift macro for generating lightweight preview/mock data for SwiftUI previews and unit tests.

## What problem it solves
SwiftUI previews and tests often need sample data for models with many properties. Writing `init` values by hand is noisy and easy to keep out of sync. `@PreviewModel` generates a `previewValue` for you so you can focus on the view or test, not the boilerplate.

## How it works
Annotate a type with `@PreviewModel` and it will:
- Add `static var previewValue: Self`
- Conform the type to `PreviewValueProtocol`
- Fill stored properties with sensible placeholder values (and use nested `previewValue`s)

## Installation (Swift Package Manager)
```swift
dependencies: [
  .package(url: "https://github.com/<your-org-or-user>/PreviewModel.git", from: "0.1.0")
]
```

Then import it where you use it:
```swift
import PreviewModel
```

## Usage
```swift
import PreviewModel
import SwiftUI

@PreviewModel
struct User {
  let id: String
  var name: String
  var avatarURL: URL
  var isAdmin: Bool
  var tags: [String]
}

struct UserRow: View {
  let user: User

  var body: some View {
    Text(user.name)
  }
}

struct UserRow_Previews: PreviewProvider {
  static var previews: some View {
    UserRow(user: .previewValue)
  }
}
```

## Collection Preview Values
Generate collections with a specific count using `previewValues(count:)`:

```swift
// Arrays - any element conforming to PreviewValueProtocol
let users = [User].previewValues(count: 10)

// Sets - requires IndexedPreviewValueProtocol for uniqueness
let tags = Set<String>.previewValues(count: 5)
// -> {"previewValue_0", "previewValue_1", "previewValue_2", "previewValue_3", "previewValue_4"}

// Dictionaries - keys must conform to IndexedPreviewValueProtocol
let scores = [String: Int].previewValues(count: 3)
// -> ["previewValue_0": 0, "previewValue_1": 0, "previewValue_2": 0]
```

### Using Custom Types in Sets and Dictionaries
For custom types to work as Set elements or Dictionary keys, conform to `IndexedPreviewValueProtocol`:

```swift
@PreviewModel
struct Tag: Hashable {
  let id: Int
  let name: String
}

extension Tag: IndexedPreviewValueProtocol {
  static func previewValue(at index: UInt) -> Tag {
    Tag(id: Int(index), name: "tag_\(index)")
  }
}

// Now you can use it in Sets and as Dictionary keys
let tags = Set<Tag>.previewValues(count: 5)
let tagNames = [Tag: String].previewValues(count: 3)
```

## Customizing generated data
Use the helpers to tweak a value without creating a full fixture:
```swift
let admin = User.previewValue.update(\.isAdmin, true)

let renamed = update(User.previewValue) { $0.name = "Ada" }
```

If you want full control, provide your own `previewValue`:
```swift
extension User {
  static var previewValue: Self {
    Self(id: "user_1", name: "Taylor", avatarURL: URL(string: "https://example.com")!, isAdmin: false, tags: ["ios"])
  }
}
```

## Defaults and rules

### Macro-generated values (for `@PreviewModel` types)
- `String` -> `"propertyName"`
- `Int`/`Double`/`Float` -> `10`
- `Bool` -> `true`
- `Date` -> `Date()`
- `URL` -> `https://www.example.com`
- `Array<Primitive>` -> 5 elements
- `Optional<T>` -> `T.previewValue` (non-nil)
- Property names containing `id` get random unique values
- Property names containing `image`/`icon` with URL type get image URLs

### Protocol conformances (for collection generation)
These primitive types conform to `IndexedPreviewValueProtocol` and can be used in Sets/Dictionary keys:
- `String` -> `"previewValue"` / `"previewValue_0"`, `"previewValue_1"`, ...
- `Int`, `Int64` -> `0` / `0`, `1`, `2`, ...
- `Double`, `Float` -> `0.0` / `0.0`, `1.0`, `2.0`, ...
- `UUID` -> random UUID (unique per call)
- `Date` -> current date / offset by index days
- `URL` -> `https://www.example.com` / `https://www.example.com/0`, `/1`, ...

`Bool` conforms to `PreviewValueProtocol` only (returns `true`) since there are only two possible values.

## Enum support
- If the enum is `CaseIterable`, the first case is used
- Otherwise the first case without associated values is used

## Notes and limitations
- Stored properties must have explicit types
- Computed properties and `private`/`fileprivate` stored properties are ignored
- `let` properties with a default value are ignored (to avoid double init)
