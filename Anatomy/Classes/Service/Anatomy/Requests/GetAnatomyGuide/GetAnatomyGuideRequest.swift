//
//  GetAnatomyGuideRequest.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Alamofire

struct GetAnatomyGuideRequest: APIRequestBody {
    let userToken: String

    var url: String {
        GlobalDefinitions.domain + "/api/anatomy/list"
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
