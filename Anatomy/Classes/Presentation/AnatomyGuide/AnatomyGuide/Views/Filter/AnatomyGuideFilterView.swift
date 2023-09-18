//
//  AnatomyGuideFilterView.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class AnatomyGuideFilterView: UICollectionView {
    lazy var elements = [AnatomyGuideFilterElement]()
    
    private lazy var didSelectTrigger = PublishRelay<AnatomyGuideFilterElement>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AnatomyGuideFilterView {
    func setup(elements: [AnatomyGuideFilterElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didSelect: Signal<AnatomyGuideFilterElement> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UICollectionViewDataSource
extension AnatomyGuideFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: AnatomyGuideFilterCell.self), for: indexPath) as! AnatomyGuideFilterCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension AnatomyGuideFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let element = elements[indexPath.row]
        let width = AnatomyGuideFilterCell.width(for: element)
        return CGSize(width: width, height: 30.scale)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        elements.forEach { $0.isSelected = false }
        
        let element = elements[indexPath.row]
        element.isSelected = true
        
        reloadData()
        
        didSelectTrigger.accept(element)
    }
}

// MARK: Private
private extension AnatomyGuideFilterView {
    func initialize() {
        register(AnatomyGuideFilterCell.self, forCellWithReuseIdentifier: String(describing: AnatomyGuideFilterCell.self))
        
        dataSource = self
        delegate = self
    }
}
