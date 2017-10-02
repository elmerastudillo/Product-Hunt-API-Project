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

