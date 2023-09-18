//
//  GetAnatomyGuideNodeRequest.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Alamofire

struct GetAnatomyGuideNodeRequest: APIRequestBody {
    let userToken: String
    let id: Int

    var url: String {
        GlobalDefinitions.domain + "/api/anatomy/list/next"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var parameters: Parameters? {
        [
            "_api_key": GlobalDefinitions.apiKey,
            "_user_token": userToken,
            "id": id
        ]
    }
}
