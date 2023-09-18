//
//  GetAnatomyBookmarksResponse.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 18.09.2023.
//

enum GetAnatomyBookmarksResponse {
    static func map(from response: Any) -> [AnatomyGuideNodeElement] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [[String: Any]]
        else {
            return []
        }
        
        return data.compactMap { json -> AnatomyGuideNodeElement? in
            guard
                let id = json["id"] as? Int,
                let name = json["name"] as? String,
                let saved = json["saved"] as? Bool
            else {
                return nil
            }
            
            return AnatomyGuideNodeElement(
                id: id,
                name: name,
                saved: saved
            )
        }
    }
}
