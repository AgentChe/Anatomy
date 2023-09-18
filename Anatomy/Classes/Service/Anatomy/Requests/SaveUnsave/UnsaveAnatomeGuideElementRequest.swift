//
//  UnsaveAnatomeGuideElementRequest.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Alamofire

struct UnsaveAnatomeGuideElementRequest: APIRequestBody {
    let userToken: String
    let ids: [Int]

    var url: String {
        GlobalDefinitions.domain + "/api/anatomy/unsave"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "ids": ids
        ]
    }
}
