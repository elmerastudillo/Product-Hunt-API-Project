//
//  Comment.swift
//  Product-Hunt-API
//
//  Created by Elmer Astudillo on 9/22/17.
//  Copyright © 2017 Elmer Astudillo. All rights reserved.
//

import Foundation

struct Comment {
    // Modeling the properties we want back from the JSON Data
    var body : String?
    // What is the point of initalizing the data?
    init(body: String) {
        self.body = body
    }
}

extension Comment: Decodable {
    // Creating  our case statements to iterate over the data in the JSON File
    
    enum additionalKeys: String, CodingKey {
        // Creating case statements that are nested within the posts list embedded with dictionaries
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: additionalKeys.self)
        let body = try container.decodeIfPresent(String.self, forKey: .body) ?? "No body"
        self.init(body: body)
    }
}

struct Comments: Decodable {
    let comments: [Comment]
}



class NetworkComments {
    static func networking(postID: Int,completion: @escaping ([Comment])-> Void) {
        
        let session = URLSession.shared
        //var customizableParamters = "posts"
        //        let dg = DispatchGroup()
        var url = URL(string: "https://api.producthunt.com/v1/comments")
        
        let date = Date()
        
        let urlParams = ["search[post_id]": String(postID),
                         "scope": "public",
                         "created_at": String(describing: date),
                         "per_page": "20"]
        url = url?.appendingQueryParameters(urlParams)
        
        var getRequest = URLRequest(url: url!)
        getRequest.httpMethod = "GET"
        getRequest.setValue("Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b", forHTTPHeaderField: "Authorization")
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        // Formatting the network request with the neccesary headers by using the set value methods
        
        // And we had to structure the url request such as that in order to be able to use the formatting parameters function as well as desired protocols
        var comments = [Comment]()
        
        //        dg.enter()
        session.dataTask(with: getRequest) { (data, response, error) in
            guard error == nil else{return}
            if let data = data {
                let comment = try? JSONDecoder().decode(Comments.self, from: data)
                
                guard let newComments = comment?.comments else{return}
                print(newComments)
                comments = newComments
                //                print(producthunt)
                //                print(urlParams["created_at"])
                
                //                dg.leave()
                completion(comments)
            } else {
                //                dg.leave()
            }
            }.resume()
        //        dg.notify(queue: .main, execute:
        //            {
        
        //})
    }
}
