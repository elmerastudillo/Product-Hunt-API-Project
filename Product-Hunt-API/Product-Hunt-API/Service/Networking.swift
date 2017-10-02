//
//  Networking.swift
//  Product-Hunt-API
//
//  Created by Elmer Astudillo on 10/1/17.
//  Copyright © 2017 Elmer Astudillo. All rights reserved.
//

import Foundation

enum Route
{
    case post
    case comments(postId: Int)
    
    // Path
    func path() -> String {
        switch self {
        case .post:
            return "posts"
        case .comments:
            return "comments"
        }
    }
    
    // URL Parameters - query
    func urlParameters() -> [String : String]
    {
        let date = Date()
        switch self {
        case .post:
            let postParameters = ["search[featured]": "true",
                                  "scope": "public",
                                  "created_at": String(describing: date),
                                  "per_page": "20"]
            return postParameters
        case .comments(let postID):
            let commentsParameters = ["search[post_id]": String(describing: postID),
                                      "scope": "public",
                                      "created_at": String(describing: date),
                                      "per_page": "20"]
            return commentsParameters
        }
    }

    
    // Headers
    func headers() -> [String: String]
    {
        let urlHeaders = ["Authorization" : "Bearer ae3328ef2b38c2fb625fe7d44fa7904810488646fb4cbf1ed9c86d61570b1090",
                          "Accept": "application/json",
                          "Content-Type": "application/json",
                          "Host": "api.producthunt.com"]
        return urlHeaders
    }
    
    // Body
    // If http body is needed for Post request
    func body() -> Data?
    {
        switch self {
        case .post:
            return Data()
        default:
            return nil
        }
    }
}


class Networking
{
    // Singleton
    static let shared = Networking()
    
    let baseUrl = "https://api.producthunt.com/v1/"
    let session = URLSession.shared
    
    // model: Decodable  - If you want parse the data into a decodable object
    func fetch(route: Route,completion: @escaping (Data) -> Void) {
        
        var fullUrlString = URL(string: baseUrl.appending(route.path()))
        fullUrlString = fullUrlString?.appendingQueryParameters(route.urlParameters())
        
        var getReuqest = URLRequest(url: fullUrlString!)
        getReuqest.allHTTPHeaderFields = route.headers()
        
        
        session.dataTask(with: getReuqest) { (data, response, error) in
            if let data = data {
                completion(data)
            }
            else
            {
                print(error?.localizedDescription ?? "Error")
            }
            }.resume()
    }
}

extension URL {
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
    // This is formatting the query parameters with an ascii table reference therefore we can be returned a json file
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}


extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}
