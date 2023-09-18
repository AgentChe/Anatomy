//
//  ContentBlock.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import Foundation

enum ContentBlock: Codable, Hashable {
    case text(String)
    case image(URL)
}
