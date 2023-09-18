//
//  AnatomyGuide.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

struct AnatomyGuide: Codable, Hashable {
    let name: String
    let nodes: [AnatomyGuideNodeElement]
}
