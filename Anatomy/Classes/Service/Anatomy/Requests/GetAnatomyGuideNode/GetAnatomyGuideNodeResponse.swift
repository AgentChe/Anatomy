//
//  GetAnatomyGuideNodeResponse.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Foundation

enum GetAnatomyGuideNodeResponse {
    static func map(from response: Any) -> AnatomyGuideNode? {
        guard
            let json = response as? [String: Any],
            let data = json["_data"] as? [String: Any],
            let content = data["content"] as? Int
        else {
            return nil
        }
        
        switch content {
        case 0:
            return GetAnatomyGuideNodeResponse.list(from: data)
        case 1:
            return GetAnatomyGuideNodeResponse.content(from: data)
        default:
            return nil
        }
    }
}

// MARK: Public
extension GetAnatomyGuideNodeResponse {
    static func list(from data: [String: Any]) -> AnatomyGuideNode? {
        var header: AnatomyGuideHeader? {
            guard
                let json = data["header"] as? [String: Any],
                let id = json["id"] as? Int,
                let imagePath = json["image"] as? String,
                let image = URL(string: imagePath),
                let title = json["title"] as? String,
                let text = json["text"] as? String,
                let saved = json["saved"] as? Bool
            else{
                return nil
            }
            
            return AnatomyGuideHeader(
                id: id,
                image: image,
                title: title,
                text: text,
                saved: saved
            )
        }
        
        let elementsArray = data["list"] as? [[String: Any]] ?? []
        let elements = GetAnatomyGuideResponse.elements(from: elementsArray)
        
        return .list(header: header, elements: elements)
    }
    
    static func content(from data: [String: Any]) -> AnatomyGuideNode? {
        guard
            let id = data["id"] as? Int,
            let name = data["name"] as? String,
            let saved = data["saved"] as? Bool,
            let blocksArray = data["sections"] as? [[String: Any]]
        else {
            return nil
        }
        
        let blocks = blocksArray.compactMap { json -> ContentBlock? in
            guard
                let text = json["text"] as? String,
                let type = json["type"] as? Int
            else {
                return nil
            }

            switch type {
            case 1:
                return .text(text)
            case 2:
                guard let url = URL(string: text) else {
                    return nil
                }

                return .image(url)
            default:
                return nil
            }
        }
        
        let content = AnatomyGuideContent(
            id: id,
            name: name,
            saved: saved,
            blocks: blocks
        )
        return .content(content)
    }
}
