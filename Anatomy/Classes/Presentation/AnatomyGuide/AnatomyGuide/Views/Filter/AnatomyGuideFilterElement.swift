//
//  AnatomyGuideFilterElement.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

final class AnatomyGuideFilterElement {
    let group: String
    var isSelected: Bool
    
    init(
        group: String,
        isSelected: Bool = false
    ) {
        self.group = group
        self.isSelected = isSelected
    }
}
