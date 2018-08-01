// Copyright Max von Webel. All Rights Reserved.

import Foundation

class DownloadController: NSObject {
    typealias AssetPromise = Promise<Asset>
    struct Asset {
        let remoteUrl: URL
        let localURL: URL
    }
    
    enum DownloadError: Error {
        case unknownDownloadError
    }
    
    private var downloads: [URL:AssetPromise] = [:]
    private var cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    private var urlSession: URLSession!
    
    override init() {
        super.init()
        urlSession = URLSession.shared
    }
    
    func download(url: URL) -> AssetPromise {
        if let promise = downloads[url] {
            return promise
        }

        let localURL = self.localURL(url: url)
        let promise: AssetPromise
        if FileManager.default.fileExists(atPath: localURL.path) {
            promise = AssetPromise { (completion, promise) in
                completion(Asset(remoteUrl: url, localURL: localURL))
            }
        } else {
            promise = AssetPromise { (completion, promise) in
                let task = urlSession.downloadTask(with: url, completionHandler: { (tempURL, response, error) in
                    if let error = error {
                        promise.throw(error: error)
                        return
                    }
                    
                    guard let tempURL = tempURL else {
                        assert(false, "neither error nor tempURL?")
                        return
                    }
                    
                    do {
                        try FileManager.default.moveItem(at: tempURL, to: localURL)
                    } catch {
                        promise.throw(error: error)
                    }
                    
                    completion(Asset(remoteUrl: url, localURL: localURL))
                })
                task.resume()
            }
        }
        
        downloads[url] = promise
        
        return promise
    }
}

extension DownloadController {
    static func fileName(url: URL) -> String {
        return String(url.absoluteString.map { c in
            switch c {
            case Character("a")...Character("z"):
                return c
            case Character("A")...Character("Z"):
                return c
            case Character("0")...Character("9"):
                return c
            case Character("."):
                return c
            default:
                return "-"
            }
        })
    }
    
    func localURL(url: URL) -> URL {
        var localURL = cacheURL
        localURL.appendPathComponent(DownloadController.fileName(url: url), isDirectory: false)
        return localURL
    }
}
