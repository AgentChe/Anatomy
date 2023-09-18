//
//  GetAnatomyGuideResponse.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

enum GetAnatomyGuideResponse {
    static func map(from response: Any) -> [AnatomyGuide] {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: [[String: Any]]]
        else {
            return []
        }
        
        return data.map { (name, nodes) -> AnatomyGuide in
            AnatomyGuide(
                name: name,
                nodes: elements(from: nodes)
            )
        }
    }
}

// MARK: Public
extension GetAnatomyGuideResponse {
    static func elements(from array: [[String: Any]]) -> [AnatomyGuideNodeElement] {
        array.compactMap { json -> AnatomyGuideNodeElement? in
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
