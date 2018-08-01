// Copyright Max von Webel. All Rights Reserved.

import Foundation

struct Image : Decodable {
    typealias ImageDict = [String: MediaRepresentation]
    let id: String
    let slug: String
    
    let images: ImageDict
    let mp4s: ImageDict

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case slug = "slug"
        case mediaRepresentations = "images"
    }
    
    init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: CodingKeys.id)
        self.slug = try container.decode(String.self, forKey: CodingKeys.slug)
        self.images = try container.decode(ImageDict.self, forKey: CodingKeys.mediaRepresentations)
        self.mp4s = self.images.filter { $0.value.mp4 != nil }
    }
}
