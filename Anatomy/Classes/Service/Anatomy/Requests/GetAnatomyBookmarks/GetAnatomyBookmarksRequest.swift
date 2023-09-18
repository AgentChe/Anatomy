//
//  GetAnatomyBookmarksRequest.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 18.09.2023.
//

import Alamofire

struct GetAnatomyBookmarksRequest: APIRequestBody {
    let userToken: String

    var url: String {
        GlobalDefinitions.domain + "/api/anatomy/bookmarks"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken
        ]
    }
}
