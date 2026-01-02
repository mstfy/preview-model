import Testing
import Foundation
@testable import PreviewModel

// MARK: - Array Tests
@Suite("Array PreviewValueProtocol Tests")
struct ArrayPreviewTests {

    @Test("Array previewValue returns 5 elements by default")
    func arrayPreviewValueDefault() {
        let strings = [String].previewValue
        let ints = [Int].previewValue

        #expect(strings.count == 5)
        #expect(ints.count == 5)
    }

    @Test("Array elements use Element.previewValue")
    func arrayElementsUsePreviewValue() {
        let strings = [String].previewValue
        let ints = [Int].previewValue

        #expect(strings.allSatisfy { $0 == String.previewValue })
        #expect(ints.allSatisfy { $0 == Int.previewValue })
    }
}

// MARK: - Set Tests
@Suite("Set PreviewValueProtocol Tests")
struct SetPreviewTests {

    @Test("Set previewValue returns 5 unique elements")
    func setPreviewValueDefault() {
        let strings = Set<String>.previewValue
        let ints = Set<Int>.previewValue

        #expect(strings.count == 5)
        #expect(ints.count == 5)
    }

    @Test("Set elements are unique using indexed values")
    func setElementsAreUnique() {
        let strings = Set<String>.previewValue
        let expectedStrings: Set<String> = [
            "previewValue_0", "previewValue_1", "previewValue_2",
            "previewValue_3", "previewValue_4"
        ]
        #expect(strings == expectedStrings)

        let ints = Set<Int>.previewValue
        let expectedInts: Set<Int> = [0, 1, 2, 3, 4]
        #expect(ints == expectedInts)
    }
}

// MARK: - Dictionary Tests
@Suite("Dictionary PreviewValueProtocol Tests")
struct DictionaryPreviewTests {

    @Test("Dictionary previewValue returns 3 entries")
    func dictionaryPreviewValueDefault() {
        let stringToInt = [String: Int].previewValue
        let intToString = [Int: String].previewValue

        #expect(stringToInt.count == 3)
        #expect(intToString.count == 3)
    }

    @Test("Dictionary keys are unique using indexed values")
    func dictionaryKeysAreUnique() {
        let dict = [String: Int].previewValue
        let expectedKeys: Set<String> = ["previewValue_0", "previewValue_1", "previewValue_2"]
        #expect(Set(dict.keys) == expectedKeys)
    }

    @Test("Dictionary values use Value.previewValue")
    func dictionaryValuesUsePreviewValue() {
        let dict = [String: Int].previewValue
        #expect(dict.values.allSatisfy { $0 == Int.previewValue })
    }

    @Test("Dictionary with Int keys works correctly")
    func dictionaryWithIntKeys() {
        let dict = [Int: String].previewValue
        let expectedKeys: Set<Int> = [0, 1, 2]
        #expect(Set(dict.keys) == expectedKeys)
        #expect(dict.values.allSatisfy { $0 == String.previewValue })
    }
}

// MARK: - Primitive Type Tests
@Suite("Primitive Type Conformance Tests")
struct PrimitiveTypeTests {

    @Test("String IndexedPreviewValueProtocol conformance")
    func stringConformance() {
        #expect(String.previewValue == "previewValue")
        #expect(String.previewValue(at: 0) == "previewValue_0")
        #expect(String.previewValue(at: 5) == "previewValue_5")
    }

    @Test("Int IndexedPreviewValueProtocol conformance")
    func intConformance() {
        #expect(Int.previewValue == 0)
        #expect(Int.previewValue(at: 0) == 0)
        #expect(Int.previewValue(at: 5) == 5)
    }

    @Test("Int64 IndexedPreviewValueProtocol conformance")
    func int64Conformance() {
        #expect(Int64.previewValue == 0)
        #expect(Int64.previewValue(at: 0) == 0)
        #expect(Int64.previewValue(at: 5) == 5)
    }

    @Test("Double IndexedPreviewValueProtocol conformance")
    func doubleConformance() {
        #expect(Double.previewValue == 0.0)
        #expect(Double.previewValue(at: 0) == 0.0)
        #expect(Double.previewValue(at: 5) == 5.0)
    }

    @Test("Float IndexedPreviewValueProtocol conformance")
    func floatConformance() {
        #expect(Float.previewValue == 0.0)
        #expect(Float.previewValue(at: 0) == 0.0)
        #expect(Float.previewValue(at: 5) == 5.0)
    }

    @Test("Bool PreviewValueProtocol conformance")
    func boolConformance() {
        #expect(Bool.previewValue == true)
    }

    @Test("UUID IndexedPreviewValueProtocol conformance generates unique values")
    func uuidConformance() {
        let uuid1 = UUID.previewValue(at: 0)
        let uuid2 = UUID.previewValue(at: 1)
        #expect(uuid1 != uuid2)
    }

    @Test("Date IndexedPreviewValueProtocol conformance")
    func dateConformance() {
        let date0 = Date.previewValue(at: 0)
        let date1 = Date.previewValue(at: 1)

        // Each index adds 1 day (86_400 seconds)
        let diff = date1.timeIntervalSince(date0)
        #expect(abs(diff - 86400) < 1)
    }

    @Test("URL IndexedPreviewValueProtocol conformance")
    func urlConformance() {
        #expect(URL.previewValue.absoluteString == "https://www.example.com")
        #expect(URL.previewValue(at: 0).absoluteString == "https://www.example.com/0")
        #expect(URL.previewValue(at: 5).absoluteString == "https://www.example.com/5")
    }
}

// MARK: - Update Helper Tests
@Suite("Update Helper Tests")
struct UpdateHelperTests {

    @Test("Global update function modifies value correctly")
    func globalUpdateFunction() {
        let original = String.previewValue
        let modified = update(original) { $0 = "modified" }

        #expect(original == "previewValue")
        #expect(modified == "modified")
    }

    @Test("KeyPath update method works correctly")
    func keyPathUpdateMethod() {
        struct TestStruct: PreviewValueProtocol {
            var name: String
            var count: Int

            static var previewValue: TestStruct {
                TestStruct(name: "test", count: 0)
            }
        }

        let original = TestStruct.previewValue
        let modified = original.update(\.name, "updated")

        #expect(original.name == "test")
        #expect(modified.name == "updated")
        #expect(modified.count == 0) // Other properties unchanged
    }

    @Test("Chained updates work correctly")
    func chainedUpdates() {
        struct TestStruct: PreviewValueProtocol {
            var a: Int
            var b: Int
            var c: Int

            static var previewValue: TestStruct {
                TestStruct(a: 0, b: 0, c: 0)
            }
        }

        let result = TestStruct.previewValue
            .update(\.a, 1)
            .update(\.b, 2)
            .update(\.c, 3)

        #expect(result.a == 1)
        #expect(result.b == 2)
        #expect(result.c == 3)
    }
}

// MARK: - Optional Support Tests
@Suite("Optional Support Tests")
struct OptionalSupportTests {

    @Test("Optional previewValue returns wrapped value")
    func optionalPreviewValue() {
        let optionalString: String? = String?.previewValue
        let optionalInt: Int? = Int?.previewValue

        #expect(optionalString == "previewValue")
        #expect(optionalInt == 0)
    }
}

// MARK: - Determinism Tests
@Suite("Determinism Tests")
struct DeterminismTests {

    @Test("String previewValue is deterministic")
    func stringDeterminism() {
        let first = String.previewValue
        let second = String.previewValue
        #expect(first == second)
    }

    @Test("Int previewValue is deterministic")
    func intDeterminism() {
        let first = Int.previewValue
        let second = Int.previewValue
        #expect(first == second)
    }

    @Test("Bool previewValue is deterministic")
    func boolDeterminism() {
        let first = Bool.previewValue
        let second = Bool.previewValue
        #expect(first == second)
        #expect(first == true)
    }

    @Test("Set previewValue is deterministic")
    func setDeterminism() {
        let first = Set<String>.previewValue
        let second = Set<String>.previewValue
        #expect(first == second)
    }

    @Test("Dictionary previewValue is deterministic")
    func dictionaryDeterminism() {
        let first = [String: Int].previewValue
        let second = [String: Int].previewValue
        #expect(first == second)
    }
}
