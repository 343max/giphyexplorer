// Copyright Max von Webel. All Rights Reserved.

import Foundation

class GiphyNetworkingClient: NetworkingClient {
    private let apiKey: String
    
    private static let endpoint = URL(string: "https://api.giphy.com/v1/")!
    private var session: URLSession!
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    }
    
    func sendRequest(_ method: HTTPMethod, _ path: String, _ parameter: ParameterDict, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        var components = URLComponents(url: GiphyNetworkingClient.endpoint, resolvingAgainstBaseURL: false)!
        components.path += path
        var parameter = parameter
        parameter["api_key"] = apiKey
        components.queryItems = parameter.map { URLQueryItem(name: $0, value: $1) }
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        
        let task = session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse?
            callback(data, httpResponse, error)
        }
        
        task.resume()
    }
}

class GiphyClient {
    private let client: NetworkingClient
    
    init(client: NetworkingClient) {
        self.client = client
    }
    
    func trending(offset: Int, limit: Int = 50, rating: String = "g") -> Promise<Response<[Image]>> {
        return client.GET("gifs/trending", ["offset": String(offset), "limit": String(limit), "rating": rating], type: Response<[Image]>.self)
    }
}
