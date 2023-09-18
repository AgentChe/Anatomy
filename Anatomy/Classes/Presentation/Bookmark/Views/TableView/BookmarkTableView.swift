//
//  BookmarkTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class BookmarkTableView: UITableView {
    lazy var elements = [BookmarkTableElement]()
    
    private lazy var didTapNodeElementTrigger = PublishRelay<AnatomyGuideNodeElement>()
    private lazy var didTapConditionTrigger = PublishRelay<SymptomsInteractionConditionDetails>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension BookmarkTableView {
    func setup(elements: [BookmarkTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapNodeElement: Signal<AnatomyGuideNodeElement> {
        didTapNodeElementTrigger.asSignal()
    }
    
    var didTapCondition: Signal<SymptomsInteractionConditionDetails> {
        didTapConditionTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension BookmarkTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        switch element.unit {
        case .anatomy(let nodeElement):
            let cell = dequeueReusableCell(withIdentifier: String(describing: BookmarkAnatomyCell.self), for: indexPath) as! BookmarkAnatomyCell
            cell.setup(
                nodeElement: nodeElement,
                selected: element.seleted,
                separatorHidden: (elements.count - 1) == indexPath.row
            )
            return cell
        case .condition(let condition):
            let cell = dequeueReusableCell(withIdentifier: String(describing: BookmarkConditionCell.self), for: indexPath) as! BookmarkConditionCell
            cell.setup(condition: condition, selected: element.seleted)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension BookmarkTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        switch element.unit {
        case .anatomy(let nodeElement):
            didTapNodeElementTrigger.accept(nodeElement)
        case .condition(let condition):
            didTapConditionTrigger.accept(condition)
        }
    }
}

// MARK: Private
private extension BookmarkTableView {
    func initialize() {
        register(BookmarkAnatomyCell.self, forCellReuseIdentifier: String(describing: BookmarkAnatomyCell.self))
        register(BookmarkConditionCell.self, forCellReuseIdentifier: String(describing: BookmarkConditionCell.self))
        
        dataSource = self
        delegate = self
    }
}
