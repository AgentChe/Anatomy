//
//  AnatomyGuideHeader.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Foundation

struct AnatomyGuideHeader: Codable, Hashable {
    let id: Int
    let image: URL
    let title: String
    let text: String
    let saved: Bool
}
