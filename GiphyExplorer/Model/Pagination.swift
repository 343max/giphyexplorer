// Copyright Max von Webel. All Rights Reserved.

import Foundation

struct Pagination: Decodable {
    let offset: Int
    let itemCount: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case offset = "offset"
        case itemCount = "count"
        case totalCount = "total_count"
    }
}
