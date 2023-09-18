//
//  AnatomyGuideNodeTableView.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class AnatomyGuideNodeTableView: UITableView {
    lazy var elements = [AnatomyGuideNodeTableElement]()
    
    private lazy var didSelectTrigger = PublishRelay<AnatomyGuideNodeTableElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AnatomyGuideNodeTableView {
    func setup(elements: [AnatomyGuideNodeTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<AnatomyGuideNodeTableElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension AnatomyGuideNodeTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case let .element(element, separatorHidden):
            let cell = dequeueReusableCell(withIdentifier: String(describing: AGNElementCell.self)) as! AGNElementCell
            cell.setup(element: element, separatorHidden: separatorHidden)
            return cell
        case .header(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: AGNHeaderCell.self)) as! AGNHeaderCell
            cell.setup(element: element)
            return cell
        case .title(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: AGNTitleCell.self)) as! AGNTitleCell
            cell.setup(element: element)
            return cell
        case .image(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: AGNImageCell.self)) as! AGNImageCell
            cell.setup(element: element)
            return cell
        case .text(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: AGNTextCell.self)) as! AGNTextCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension AnatomyGuideNodeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTrigger.accept(elements[indexPath.row])
    }
}

// MARK: Private
private extension AnatomyGuideNodeTableView {
    func initialize() {
        register(AGNElementCell.self, forCellReuseIdentifier: String(describing: AGNElementCell.self))
        register(AGNHeaderCell.self, forCellReuseIdentifier: String(describing: AGNHeaderCell.self))
        register(AGNTitleCell.self, forCellReuseIdentifier: String(describing: AGNTitleCell.self))
        register(AGNImageCell.self, forCellReuseIdentifier: String(describing: AGNImageCell.self))
        register(AGNTextCell.self, forCellReuseIdentifier: String(describing: AGNTextCell.self))
        
        delegate = self
        dataSource = self
    }
}
