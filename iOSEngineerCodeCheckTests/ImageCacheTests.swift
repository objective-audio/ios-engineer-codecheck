import XCTest

@testable import iOSEngineerCodeCheck

private final class DownloaderMock: DownloaderForImageCache {
    let result: Result<UIImage, Error>

    init(result: Result<UIImage, Error>) {
        self.result = result
    }

    func download(from url: URL) async throws -> UIImage {
        try result.get()
    }
}

private enum ImageCacheMatchState {
    case initial
    case loading
    case loaded
    case failed
}

extension ImageCacheState {
    fileprivate func isMatch(_ rhs: ImageCacheMatchState) -> Bool {
        switch (self, rhs) {
        case (.initial, .initial), (.loading, .loading), (.loaded, .loaded), (.failed, .failed):
            true
        default:
            false
        }
    }
}

@MainActor
final class ImageCacheTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_ロードが成功してimageが返る() throws {
        let imageCache = ImageCache(downloader: DownloaderMock(result: .success(testImage)))

        var receivedStates: [ImageCacheState] = []
        let expectation = XCTestExpectation(description: "loaded")

        let canceller = imageCache.statePublisher.sink { state in
            receivedStates.append(state)

            if state.isMatch(.loaded) {
                expectation.fulfill()
            }
        }

        XCTContext.runActivity(named: "ロード前は初期状態") { _ in
            XCTAssertTrue(imageCache.state.isMatch(.initial))
            XCTAssertEqual(receivedStates.count, 1)
            XCTAssertTrue(receivedStates[0].isMatch(.initial))
        }

        imageCache.load(url: testImageUrl)

        self.wait(for: [expectation], timeout: 10.0)

        XCTContext.runActivity(named: "ロード開始すると、ロード中・ロード済みと呼ばれる") { _ in
            XCTAssertTrue(imageCache.state.isMatch(.loaded))
            XCTAssertEqual(receivedStates.count, 3)
            XCTAssertTrue(receivedStates[1].isMatch(.loading))
            XCTAssertTrue(receivedStates[2].isMatch(.loaded))
        }

        canceller.cancel()
    }

    func test_ロードが失敗してエラーが返る() throws {
        let imageCache = ImageCache(downloader: DownloaderMock(result: .failure(TestError.dummy)))

        var receivedStates: [ImageCacheState] = []
        let expectation = XCTestExpectation(description: "loaded")

        let canceller = imageCache.statePublisher.sink { state in
            receivedStates.append(state)

            if state.isMatch(.failed) {
                expectation.fulfill()
            }
        }

        XCTContext.runActivity(named: "ロード前は初期状態") { _ in
            XCTAssertTrue(imageCache.state.isMatch(.initial))
            XCTAssertEqual(receivedStates.count, 1)
            XCTAssertTrue(receivedStates[0].isMatch(.initial))
        }

        imageCache.load(url: testImageUrl)

        self.wait(for: [expectation], timeout: 10.0)

        XCTContext.runActivity(named: "ロード開始すると、ロード中・ロード失敗と呼ばれる") { _ in
            XCTAssertTrue(imageCache.state.isMatch(.failed))
            XCTAssertEqual(receivedStates.count, 3)
            XCTAssertTrue(receivedStates[1].isMatch(.loading))
            XCTAssertTrue(receivedStates[2].isMatch(.failed))
        }

        canceller.cancel()
    }
}
