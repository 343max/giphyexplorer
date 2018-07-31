// Copyright Max von Webel. All Rights Reserved.

import Foundation

struct Response<T: Decodable>: Decodable {
    let payload: T
    let page: Pagination
    
    enum CodingKeys: String, CodingKey {
        case payload = "data"
        case page = "pagination"
    }
    
    init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        self.payload = try! container.decode(T.self, forKey: CodingKeys.payload)
        self.page = try! container.decode(Pagination.self, forKey: CodingKeys.page)
    }
}
