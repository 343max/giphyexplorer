// Copyright Max von Webel. All Rights Reserved.

import XCTest
@testable import GiphyExplorer

class PaginationTests: XCTestCase {

    func testPagination() {
        let data = """
{
    "total_count": 100351,
    "count": 25,
    "offset": 10
}
""".data(using: .utf8)!
        let page = try? JSONDecoder().decode(Pagination.self, from: data)
        XCTAssertNotNil(page)
        XCTAssertEqual(page?.offset, 10)
        XCTAssertEqual(page?.itemCount, 25)
        XCTAssertEqual(page?.totalCount, 100351)
    }

}
