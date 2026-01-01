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
@Suite("Set PreviewCollectionValueProtocol Tests")
struct SetPreviewTests {

    @Test("Set previewValues returns correct count with unique elements")
    func setPreviewValuesCount() {
        let set0 = Set<String>.previewValues(count: 0)
        let set3 = Set<String>.previewValues(count: 3)
        let set10 = Set<Int>.previewValues(count: 10)

        #expect(set0.count == 0)
        #expect(set3.count == 3)
        #expect(set10.count == 10)
    }

    @Test("Set previewValue returns 5 elements by default")
    func setPreviewValueDefault() {
        let strings = Set<String>.previewValue
        let ints = Set<Int>.previewValue

        #expect(strings.count == 5)
        #expect(ints.count == 5)
    }

    @Test("Set elements are unique using indexed values")
    func setElementsAreUnique() {
        let strings = Set<String>.previewValues(count: 5)
        let expectedStrings: Set<String> = [
            "previewValue_0", "previewValue_1", "previewValue_2",
            "previewValue_3", "previewValue_4"
        ]
        #expect(strings == expectedStrings)

        let ints = Set<Int>.previewValues(count: 5)
        let expectedInts: Set<Int> = [0, 1, 2, 3, 4]
        #expect(ints == expectedInts)
    }

    @Test("Set with large count maintains uniqueness")
    func setLargeCountUniqueness() {
        let large = Set<Int>.previewValues(count: 100)
        #expect(large.count == 100)
    }
}

// MARK: - Dictionary Tests
@Suite("Dictionary PreviewCollectionValueProtocol Tests")
struct DictionaryPreviewTests {

    @Test("Dictionary previewValues returns correct count")
    func dictionaryPreviewValuesCount() {
        let dict0 = [String: Int].previewValues(count: 0)
        let dict3 = [String: Int].previewValues(count: 3)
        let dict10 = [Int: String].previewValues(count: 10)

        #expect(dict0.count == 0)
        #expect(dict3.count == 3)
        #expect(dict10.count == 10)
    }

    @Test("Dictionary previewValue returns 3 entries by default")
    func dictionaryPreviewValueDefault() {
        let stringToInt = [String: Int].previewValue
        let intToString = [Int: String].previewValue

        #expect(stringToInt.count == 3)
        #expect(intToString.count == 3)
    }

    @Test("Dictionary keys are unique using indexed values")
    func dictionaryKeysAreUnique() {
        let dict = [String: Int].previewValues(count: 3)
        let expectedKeys: Set<String> = ["previewValue_0", "previewValue_1", "previewValue_2"]
        #expect(Set(dict.keys) == expectedKeys)
    }

    @Test("Dictionary values use Value.previewValue")
    func dictionaryValuesUsePreviewValue() {
        let dict = [String: Int].previewValues(count: 3)
        #expect(dict.values.allSatisfy { $0 == Int.previewValue })
    }

    @Test("Dictionary with Int keys works correctly")
    func dictionaryWithIntKeys() {
        let dict = [Int: String].previewValues(count: 4)
        let expectedKeys: Set<Int> = [0, 1, 2, 3]
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
        #expect(String.previewValue(at: 100) == "previewValue_100")
    }

    @Test("Int IndexedPreviewValueProtocol conformance")
    func intConformance() {
        #expect(Int.previewValue == 0)
        #expect(Int.previewValue(at: 0) == 0)
        #expect(Int.previewValue(at: 5) == 5)
        #expect(Int.previewValue(at: 100) == 100)
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
        let date2 = Date.previewValue(at: 2)

        // Each index adds 1 day (86_400 seconds)
        let diff1 = date1.timeIntervalSince(date0)
        let diff2 = date2.timeIntervalSince(date1)

        #expect(abs(diff1 - 86400) < 1) // Allow 1 second tolerance
        #expect(abs(diff2 - 86400) < 1)
    }

    @Test("URL IndexedPreviewValueProtocol conformance")
    func urlConformance() {
        #expect(URL.previewValue.absoluteString == "https://www.example.com")
        #expect(URL.previewValue(at: 0).absoluteString == "https://www.example.com/0")
        #expect(URL.previewValue(at: 5).absoluteString == "https://www.example.com/5")
    }
}

// MARK: - Edge Cases
@Suite("Edge Cases Tests")
struct EdgeCaseTests {

    @Test("Empty collections are handled correctly")
    func emptyCollections() {
        let emptySet = Set<Int>.previewValues(count: 0)
        let emptyDict = [String: Bool].previewValues(count: 0)

        #expect(emptySet.isEmpty)
        #expect(emptyDict.isEmpty)
    }

    @Test("Single element collections work correctly")
    func singleElementCollections() {
        let set = Set<Int>.previewValues(count: 1)
        let dict = [String: Bool].previewValues(count: 1)

        #expect(set.count == 1)
        #expect(dict.count == 1)
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

    @Test("Set previewValues is deterministic")
    func setDeterminism() {
        let first = Set<String>.previewValues(count: 5)
        let second = Set<String>.previewValues(count: 5)
        #expect(first == second)
    }

    @Test("Dictionary previewValues is deterministic")
    func dictionaryDeterminism() {
        let first = [String: Int].previewValues(count: 5)
        let second = [String: Int].previewValues(count: 5)
        #expect(first == second)
    }

    @Test("Bool previewValue is deterministic")
    func boolDeterminism() {
        let first = Bool.previewValue
        let second = Bool.previewValue
        #expect(first == second)
        #expect(first == true)
    }
}
