// Copyright Max von Webel. All Rights Reserved.

import Foundation

enum HTTPMethod : String {
    case GET = "GET"
    case POST = "POST"
}

protocol NetworkingClient {
    func sendRequest(_ method: HTTPMethod, _ path: String, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
}

extension NetworkingClient {
    func GET(_ path: String, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        self.sendRequest(.GET, path, callback: callback)
    }
    
    func GET<T>(_ path: String, type: T.Type) -> Promise<T> where T : Decodable {
        return Promise<T>({ (completion, promise) in
            self.GET(path) { (data, _, error) in
                guard let data = data else {
                    promise.throw(error: error!)
                    return
                }
                
                let result = try! JSONDecoder().decode(type, from: data)
                completion(result)
            }
        })
    }
}
