//
//  BookmarkTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

final class BookmarkTableElement {
    enum Unit {
        case anatomy(AnatomyGuideNodeElement)
        case condition(SymptomsInteractionConditionDetails)
    }
    
    let unit: Unit
    var seleted: Bool?
    
    init(
        unit: Unit,
        seleted: Bool?
    ) {
        self.unit = unit
        self.seleted = seleted
    }
}
