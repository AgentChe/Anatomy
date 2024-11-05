//
//  ProfileCreateRequest.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 04.11.2024.
//

import Alamofire

struct ProfileCreateRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String?
    
    var url: String {
        GlobalDefinitions.aiDomain + "/api/v1/user/create"
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
        var params: Parameters = [
            "anonymous_id": anonymousId
        ]
        
        if let internalId {
            params["internal_id"] = internalId
        }
        
        return params
    }
}
