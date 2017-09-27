//
//  ProductModel.swift
//  Product-Hunt-API
//
//  Created by Elmer Astudillo on 9/21/17.
//  Copyright © 2017 Elmer Astudillo. All rights reserved.
//

import Foundation

struct Product {
    // Modeling the properties we want back from the JSON Data
    var name: String?
    var tagline: String?
    var votes: Int?
    var imageURL: String?
    var day: String?
    var postID : Int
    
    // What is the point of initalizing the data?
    init(name: String?, tagline: String?, votesCount: Int?, imageURL: String?, day: String?, postID: Int) {
        self.name = name
        self.tagline = tagline
        self.votes = votesCount
        self.imageURL = imageURL
        self.day = day
        self.postID = postID
    }
}

extension Product: Decodable {
    // Creating  our case statements to iterate over the data in the JSON File
    
    enum additionalKeys: String, CodingKey {
        // Creating case statements that are nested within the posts list embedded with dictionaries
        case name
        case tagline
        case votes = "votes"
        case day
        case thumbnail
        case postID = "id"
    }
    
    enum  thubnailImage: String, CodingKey {
        case imageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: additionalKeys.self)
        let votes = try container.decodeIfPresent(Int.self, forKey: .votes) ?? 0
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let tagline = try container.decodeIfPresent(String.self, forKey: .tagline)
        let day = try container.decodeIfPresent(String.self, forKey: .day) ?? "The day is not here"
        let postID = try container.decode(Int.self, forKey: .postID)
        let thumbnailContainer = try? container.nestedContainer(keyedBy: thubnailImage.self, forKey: .thumbnail)
        if let _ = thumbnailContainer {
            let imageURL = try thumbnailContainer?.decodeIfPresent(String.self, forKey: .imageURL) ?? "No Image"
            self.init(name: name, tagline: tagline, votesCount: votes, imageURL: imageURL, day: day, postID: postID)
            return
        }
        self.init(name: name, tagline: tagline, votesCount: votes, imageURL: "image", day: day, postID: postID)
    }
}

struct Producthunt: Decodable {
    let posts: [Product]
}



class NetworkProduct {
    static func networking(completion: @escaping ([Product])-> Void) {
        
        let session = URLSession.shared
        
        var url = URL(string: "https://api.producthunt.com/v1/posts")
        
        let date = Date()
        
        let urlParams = ["search[featured]": "true",
                         "scope": "public",
                         "created_at": String(describing: date),
                         "per_page": "20"]
        url = url?.appendingQueryParameters(urlParams)
        
        var getRequest = URLRequest(url: url!)
        getRequest.httpMethod = "GET"
        getRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.setValue("Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b", forHTTPHeaderField: "Authorization")
        // Formatting the network request with the neccesary headers by using the set value methods
        
        // And we had to structure the url request such as that in order to be able to use the formatting parameters function as well as desired protocols
        var posts = [Product]()
        

        session.dataTask(with: getRequest) { (data, response, error) in
            guard error == nil else{return}
            if let data = data {
                let producthunt = try? JSONDecoder().decode(Producthunt.self, from: data)
                
                guard let newPosts = producthunt?.posts else{return}
                posts = newPosts
                completion(posts)

            } else {

            }
            }.resume()
    }
}
    
    
    // We are essentially giving the ability to implement parameters in the dictionary succesfully
    
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

