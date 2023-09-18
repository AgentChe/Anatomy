//
//  AnatomyGuideNodeTableElement.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import Foundation

enum AnatomyGuideNodeTableElement {
    case header(AnatomyGuideHeader)
    case element(AnatomyGuideNodeElement, separatorHidden: Bool)
    case title(String)
    case image(URL)
    case text(String)
}
