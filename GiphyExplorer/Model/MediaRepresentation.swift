// Copyright Max von Webel. All Rights Reserved.

import Foundation

struct MediaRepresentation : Decodable {
    struct Size {
        let width: Int
        let height: Int
    }
    
    struct Format {
        let url: URL
        let size: Int
        
        init?(url: URL?, size: Int?) {
            if let url = url, let size = size {
                self.url = url
                self.size = size
            } else {
                return nil
            }
        }
    }

    let dimensions: Size?
    let mp4: Format?
    
    enum CodingKeys: String, CodingKey {
        case width = "width"
        case height = "height"
        case mp4url = "mp4"
        case mp4size = "mp4_size"
    }
    
    init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        
        if let width = Int((try? container.decode(String.self, forKey: .width)) ?? ""),
            let height = Int((try? container.decode(String.self, forKey: .height)) ?? "") {
            self.dimensions = Size(width: width, height: height)
        } else {
            self.dimensions = nil
        }
        
        do {
            let url = try? container.decode(URL.self, forKey: .mp4url)
            let size = Int(try container.decode(String.self, forKey: .mp4size))
            self.mp4 = Format(url: url, size: size)
        } catch {
            self.mp4 = nil
        }
    }
}

extension MediaRepresentation {
    static func dict(data: Data) {
        
    }
}
