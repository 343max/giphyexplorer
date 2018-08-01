// Copyright Max von Webel. All Rights Reserved.

import XCTest
@testable import GiphyExplorer

class DownloadControllerTests: XCTestCase {

    func testFileName() {
        let url = URL(string: "https://media3.giphy.com/media/3ohc1d8d9tCaBQdUe4/giphy-loop.mp4")!
        let fileName = DownloadController.fileName(url: url)
        XCTAssertEqual("https---media3.giphy.com-media-3ohc1d8d9tCaBQdUe4-giphy-loop.mp4", fileName)
    }

}
