//
//  SaveAnatomeGuideElementRequest.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Alamofire

struct SaveAnatomeGuideElementRequest: APIRequestBody {
    let userToken: String
    let id: Int

    var url: String {
        GlobalDefinitions.domain + "/api/anatomy/save"
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
