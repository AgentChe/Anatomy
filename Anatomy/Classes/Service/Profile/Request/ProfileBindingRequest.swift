//
//  ProfileBindingRequest.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 04.11.2024.
//

import Alamofire

struct ProfileBindingRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    
    var url: String {
        GlobalDefinitions.aiDomain + "/api/v1/user/binding"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var headers: HTTPHeaders? {
        [
            "Access-Token": GlobalDefinitions.aiApiKey
        ]
    }
    
    var parameters: Parameters? {
        [
            "anonymous_id": anonymousId,
            "internal_id": internalId
        ]
    }
}
