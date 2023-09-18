//
//  AnatomyGuideTableView.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class AnatomyGuideTableView: UITableView {
    lazy var elements = [AnatomyGuideNodeElement]()
    
    private lazy var didSelectTrigger = PublishRelay<AnatomyGuideNodeElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AnatomyGuideTableView {
    func setup(elements: [AnatomyGuideNodeElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<AnatomyGuideNodeElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension AnatomyGuideTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: String(describing: AnatomyGuideTableCell.self)) as! AnatomyGuideTableCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension AnatomyGuideTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = elements[indexPath.row]
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension AnatomyGuideTableView {
    func initialize() {
        register(AnatomyGuideTableCell.self, forCellReuseIdentifier: String(describing: AnatomyGuideTableCell.self))
        
        dataSource = self
        delegate = self
    }
}
