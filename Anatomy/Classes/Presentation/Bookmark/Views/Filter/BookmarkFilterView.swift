//
//  BookmarkFilterView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit

final class BookmarkFilterView: UIView {
    enum Filter {
        case anatomy, conditions
    }
    
    lazy var filter = Filter.anatomy {
        didSet {
            update()
        }
    }
    
    lazy var anatomyButton = makeButton(text: "Bookmark.Anatomy".localized)
    lazy var conditionsButton = makeButton(text: "Bookmark.Conditions".localized)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension BookmarkFilterView {
    func update() {
        anatomyButton.marked = filter == .anatomy
        conditionsButton.marked = filter == .conditions
    }
}

// MARK: Make constraints
private extension BookmarkFilterView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            anatomyButton.widthAnchor.constraint(equalToConstant: 172.scale),
            anatomyButton.heightAnchor.constraint(equalToConstant: 32.scale),
            anatomyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13.scale),
            anatomyButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            conditionsButton.widthAnchor.constraint(equalToConstant: 171.scale),
            conditionsButton.heightAnchor.constraint(equalToConstant: 32.scale),
            conditionsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 185.scale),
            conditionsButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension BookmarkFilterView {
    func makeButton(text: String) -> BookmarkFilterButton {
        let view = BookmarkFilterButton(text: text)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
