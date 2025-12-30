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
- `String` -> `"propertyName"`
- `Int`/`Double`/`Float` -> `10`
- `Bool` -> `true`
- `Date` -> `Date()`
- `URL` -> `https://www.example.com`
- `Array<Primitive>` -> 5 elements
- `Optional<T>` -> `T.previewValue` (non-nil)
- `Set<T>` -> 5 elements
- `[String: T]` -> 1-3 key/value pairs
- Property names containing `id` or `image`/`icon` get specialized values

## Enum support
- If the enum is `CaseIterable`, the first case is used
- Otherwise the first case without associated values is used

## Notes and limitations
- Stored properties must have explicit types
- Computed properties and `private`/`fileprivate` stored properties are ignored
- `let` properties with a default value are ignored (to avoid double init)

