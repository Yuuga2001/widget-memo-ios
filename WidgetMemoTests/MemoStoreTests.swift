import Testing
import SwiftUI
@testable import WidgetMemo

struct MemoStoreTests {

    private func makeStore() -> (MemoStore, UserDefaults) {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let store = MemoStore(defaults: defaults)
        return (store, defaults)
    }

    // MARK: - Default Values

    @Test func initialState_hasDefaultValues() {
        let (store, _) = makeStore()
        #expect(store.text == "")
        #expect(store.fontSize == AppConstants.defaultFontSize)
    }

    // MARK: - Text Persistence

    @Test func textPersistence_savesAndLoads() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let store1 = MemoStore(defaults: defaults)
        store1.text = "テストメモ"

        let store2 = MemoStore(defaults: defaults)
        #expect(store2.text == "テストメモ")
    }

    @Test func textPersistence_emptyString() {
        let (store, defaults) = makeStore()
        store.text = "何か"
        store.text = ""

        let reloaded = MemoStore(defaults: defaults)
        #expect(reloaded.text == "")
    }

    // MARK: - Font Size Persistence

    @Test func fontSizePersistence_savesAndLoads() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let store1 = MemoStore(defaults: defaults)
        store1.fontSize = 24.0

        let store2 = MemoStore(defaults: defaults)
        #expect(store2.fontSize == 24.0)
    }

    @Test func fontSizeDefault_whenNotSet() {
        let (store, _) = makeStore()
        #expect(store.fontSize == AppConstants.defaultFontSize)
    }

    // MARK: - Color Persistence

    @Test func colorPersistence_backgroundColorRoundTrip() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let store1 = MemoStore(defaults: defaults)
        let testColor = Color(red: 0.5, green: 0.3, blue: 0.8, opacity: 1.0)
        store1.backgroundColor = testColor

        // Verify raw data was saved
        let saved = defaults.array(forKey: AppConstants.backgroundColorKey) as? [Double]
        #expect(saved != nil)
        #expect(saved?.count == 4)

        // Verify reload works
        let store2 = MemoStore(defaults: defaults)
        let loaded = store2.backgroundColor
        // Color comparison via RGBA components
        let uiLoaded = UIColor(loaded)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiLoaded.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 0.5) < 0.01)
        #expect(abs(g - 0.3) < 0.01)
        #expect(abs(b - 0.8) < 0.01)
    }

    @Test func colorPersistence_textColorRoundTrip() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let store1 = MemoStore(defaults: defaults)
        let testColor = Color(red: 0.1, green: 0.9, blue: 0.4, opacity: 1.0)
        store1.textColor = testColor

        let store2 = MemoStore(defaults: defaults)
        let loaded = store2.textColor
        let uiLoaded = UIColor(loaded)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiLoaded.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 0.1) < 0.01)
        #expect(abs(g - 0.9) < 0.01)
        #expect(abs(b - 0.4) < 0.01)
    }

    // MARK: - Color Static Helpers

    @Test func loadColor_returnsNilForMissingKey() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let color = MemoStore.loadColor(from: defaults, key: "nonexistent")
        #expect(color == nil)
    }

    @Test func loadColor_returnsNilForInvalidData() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        defaults.set([1.0, 2.0], forKey: "bad_color") // Only 2 components
        let color = MemoStore.loadColor(from: defaults, key: "bad_color")
        #expect(color == nil)
    }

    @Test func saveAndLoadColor_staticMethods() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let original = Color(red: 0.2, green: 0.6, blue: 0.9, opacity: 1.0)

        MemoStore.saveColor(original, forKey: "test_color", in: defaults)
        let loaded = MemoStore.loadColor(from: defaults, key: "test_color")

        #expect(loaded != nil)
        if let loaded {
            let uiLoaded = UIColor(loaded)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            uiLoaded.getRed(&r, green: &g, blue: &b, alpha: &a)
            #expect(abs(r - 0.2) < 0.01)
            #expect(abs(g - 0.6) < 0.01)
            #expect(abs(b - 0.9) < 0.01)
        }
    }
}
