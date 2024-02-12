import XCTest

@testable import iOSEngineerCodeCheck

final class ImageCacheStateTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_image() throws {
        XCTContext.runActivity(named: "loadedで保持しているimageが返る") { _ in
            XCTAssertEqual(ImageCacheState.loaded(TestData.image).image, TestData.image)
            XCTAssertNotEqual(ImageCacheState.loaded(TestData.image).image, TestData.otherImage)
        }

        XCTContext.runActivity(named: "loaded以外はnilを返す") { _ in
            XCTAssertNil(ImageCacheState.initial.image)
            XCTAssertNil(ImageCacheState.loading.image)
            XCTAssertNil(ImageCacheState.failed(TestError.dummy).image)
        }
    }

    func test_canLoad() throws {
        XCTContext.runActivity(named: "初期状態か失敗状態なら読み込み可能") { _ in
            XCTAssertTrue(ImageCacheState.initial.canLoad)
            XCTAssertTrue(ImageCacheState.failed(TestError.dummy).canLoad)
        }

        XCTContext.runActivity(named: "読み込み中か成功状態なら読み込み不可") { _ in
            XCTAssertFalse(ImageCacheState.loading.canLoad)
            XCTAssertFalse(ImageCacheState.loaded(TestData.image).canLoad)
        }
    }
}
