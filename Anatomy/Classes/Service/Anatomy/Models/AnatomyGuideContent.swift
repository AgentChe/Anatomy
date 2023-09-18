//
//  AnatomyGuideContent.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Foundation

struct AnatomyGuideContent: Codable, Hashable {
    let id: Int
    let name: String
    let saved: Bool
    let blocks: [ContentBlock]
}
