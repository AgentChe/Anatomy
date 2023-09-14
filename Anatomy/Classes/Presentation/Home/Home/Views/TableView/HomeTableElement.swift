//
//  HomeTableElement.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

struct HomeTableElement {
    enum Block {
        case anatomyGuide, symptomChecker, bookmark
    }
    
    let block: Block
    let title: String
    let text: String
    let imageName: String
    
    init(block: Block) {
        self.block = block
        
        switch block {
        case .anatomyGuide:
            title = "Home.AnatomyGuide.Title".localized
            text = "Home.AnatomyGuide.Text".localized
            imageName = "Home.AnatomyGuide"
        case .symptomChecker:
            title = "Home.SymptomChecker.Title".localized
            text = "Home.SymptomChecker.Text".localized
            imageName = "Home.SymptomChecker"
        case .bookmark:
            title = "Home.Bookmark.Title".localized
            text = "Home.Bookmark.Text".localized
            imageName = "Home.Bookmark"
        }
    }
}
