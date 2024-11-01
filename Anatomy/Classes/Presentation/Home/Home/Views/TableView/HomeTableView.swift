//
//  HomeTableView.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 12.05.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeTableView: UITableView {
    lazy var elements = [HomeTableElement]()
    
    private lazy var didTapALConsultantTrigger = PublishRelay<Void>()
    private lazy var didTapAnatomyGuideTrigger = PublishRelay<Void>()
    private lazy var didTapSymptomCheckerTrigger = PublishRelay<Void>()
    private lazy var didTapBookmarkTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HomeTableView {
    func setup(elements: [HomeTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapALConsultant: Signal<Void> {
        didTapALConsultantTrigger.asSignal()
    }
    
    var didTapAnatomyGuide: Signal<Void> {
        didTapAnatomyGuideTrigger.asSignal()
    }
    
    var didTapSymptomChecker: Signal<Void> {
        didTapSymptomCheckerTrigger.asSignal()
    }
    
    var didTapBookmark: Signal<Void> {
        didTapBookmarkTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension HomeTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .alConsultant:
            return dequeueReusableCell(withIdentifier: String(describing: HomeTableALConsultantCell.self), for: indexPath)
        case .defaultBlock(let element):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HomeTableDefaultCell.self)) as! HomeTableDefaultCell
            cell.setup(element: element)
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension HomeTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .alConsultant:
            didTapALConsultantTrigger.accept(Void())
        case .defaultBlock(let element):
            switch element.block {
            case .anatomyGuide:
                didTapAnatomyGuideTrigger.accept(Void())
            case .symptomChecker:
                didTapSymptomCheckerTrigger.accept(Void())
            case .bookmark:
                didTapBookmarkTrigger.accept(Void())
            }
        }
    }
}

// MARK: Private
private extension HomeTableView {
    func initialize() {
        register(HomeTableALConsultantCell.self, forCellReuseIdentifier: String(describing: HomeTableALConsultantCell.self))
        register(HomeTableDefaultCell.self, forCellReuseIdentifier: String(describing: HomeTableDefaultCell.self))
        
        dataSource = self
        delegate = self
    }
}
