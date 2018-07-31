// Copyright Max von Webel. All Rights Reserved.

import XCTest
@testable import GiphyExplorer


class ImageTests: XCTestCase {
    
    func testImage() {
        let image = try? JSONDecoder().decode(Image.self, from: ImageTests.data())
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.id, "jxcilyPDPuublRty5I")
        XCTAssertEqual(image?.slug, "wetv-lol-television-omg-jxcilyPDPuublRty5I")
        XCTAssertEqual(image?.images.count, 3)
        XCTAssertNotNil(image?.images["original_still"])
    }
    
    func testMp4s() {
        let image = try! JSONDecoder().decode(Image.self, from: ImageTests.data())
        XCTAssertEqual(image.mp4s.count, 1)
        XCTAssertNotNil(image.mp4s["fixed_width"])
    }

    static func data() -> Data {
        return """
{
    "type": "gif",
    "id": "jxcilyPDPuublRty5I",
    "slug": "wetv-lol-television-omg-jxcilyPDPuublRty5I",
    "url": "https://giphy.com/gifs/wetv-lol-television-omg-jxcilyPDPuublRty5I",
    "bitly_gif_url": "https://gph.is/2v0jOts",
    "bitly_url": "https://gph.is/2v0jOts",
    "embed_url": "https://giphy.com/embed/jxcilyPDPuublRty5I",
    "username": "wetv",
    "source": "https://www.wetv.com/",
    "rating": "pg-13",
    "content_url": "",
    "source_tld": "www.wetv.com",
    "source_post_url": "https://www.wetv.com/",
    "is_sticker": 0,
    "import_datetime": "2018-07-30 14:25:09",
    "trending_datetime": "2018-07-30 15:28:27",
    "user": {
        "avatar_url": "https://media.giphy.com/avatars/wetv/ez6Knwamyn0A.jpg",
        "banner_url": "https://media.giphy.com/headers/wetv/kZKU1TvGXJcJ.jpg",
        "profile_url": "https://giphy.com/wetv/",
        "username": "wetv",
        "display_name": "WE tv",
        "guid": "amFtZXMrd2V0dkBiZXRhd29ya3MuY29t"
    },
    "images": {
        "fixed_height_still": {
            "url": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/200_s.gif",
            "width": "356",
            "height": "200",
            "size": "44182"
        },
        "original_still": {
            "url": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/giphy_s.gif",
            "width": "480",
            "height": "270",
            "size": "75828"
        },
        "fixed_width": {
            "url": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/200w.gif",
            "width": "200",
            "height": "113",
            "size": "325865",
            "mp4": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/200w.mp4",
            "mp4_size": "49195",
            "webp": "https://media0.giphy.com/media/jxcilyPDPuublRty5I/200w.webp",
            "webp_size": "236598"
        }
    },
    "title": "honey boo boo lol GIF by WE tv",
    "_score": 0
}
""".data(using: .utf8)!
    }
    
}
