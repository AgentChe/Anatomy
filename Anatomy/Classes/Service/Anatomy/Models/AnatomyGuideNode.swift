//
//  AnatomyGuideNode.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

enum AnatomyGuideNode: Codable, Hashable {
    case list(header: AnatomyGuideHeader?, elements: [AnatomyGuideNodeElement])
    case content(AnatomyGuideContent)
}
