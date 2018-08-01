// Copyright Max von Webel. All Rights Reserved.

import XCTest
@testable import GiphyExplorer

class ResponseTests: XCTestCase {

    func data(fileName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    func testResponse() {
        let response = try? JSONDecoder().decode(Response<[Image]>.self, from: data(fileName: "trendingResponse"))
        XCTAssertNotNil(response)
    }

    func testGiantResponse() {
        do {
            let response = try JSONDecoder().decode(Response<[Image]>.self, from: data(fileName: "giantResponse"))
            XCTAssertNotNil(response)
        } catch {
            XCTFail("error: \(error)")
        }
    }
}
