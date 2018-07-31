// Copyright Max von Webel. All Rights Reserved.

import XCTest
@testable import GiphyExplorer

class MediaRepresentationTests: XCTestCase {

    func testMediaRepresentation() {
        let data = """
{
    "url": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/100w.gif",
    "width": "100",
    "height": "57",
    "size": "90555",
    "mp4": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/100w.mp4",
    "mp4_size": "17429",
    "webp": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/100w.webp",
    "webp_size": "96022"
}
""".data(using: .utf8)!
        let mediaRepresentation = try! JSONDecoder().decode(MediaRepresentation.self, from: data)
        XCTAssertEqual(mediaRepresentation.dimensions.width, 100)
        XCTAssertEqual(mediaRepresentation.dimensions.height, 57)
        XCTAssertEqual(mediaRepresentation.mp4!.url, URL(string: "https://media0.giphy.com/media/jxcilyPDPuublRty5I/100w.mp4"))
        XCTAssertEqual(mediaRepresentation.mp4!.size, 17429)
    }
    
    func testNoMp4() {
        let data = """
{
    "url": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/giphy-preview.gif",
    "width": "149",
    "height": "84",
    "size": "49824"
}
""".data(using: .utf8)!
        let mediaRepresentation = try! JSONDecoder().decode(MediaRepresentation.self, from: data)
        XCTAssertNil(mediaRepresentation.mp4)
    }
}
