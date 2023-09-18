//
//  AnatomyMediator.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import RxSwift
import RxCocoa

final class AnatomyMediator {
    static let shared = AnatomyMediator()
    
    private lazy var didSaveNodeElementIdTrigger = PublishRelay<Int>()
    private lazy var didUnsaveNodesElementsIdsTrigger = PublishRelay<[Int]>()
    
    private init() {}
}

// MARK: Public
extension AnatomyMediator {
    func saveNodeElement(id: Int) {
        DispatchQueue.main.async {
            Self.shared.didSaveNodeElementIdTrigger.accept(id)
        }
    }
    
    func unsaveNodesElements(ids: [Int]) {
        DispatchQueue.main.async {
            Self.shared.didUnsaveNodesElementsIdsTrigger.accept(ids)
        }
    }
    
    var didSaveNodeElementId: Signal<Int> {
        didSaveNodeElementIdTrigger.asSignal()
    }
    
    var didUnsaveNodesElementsIds: Signal<[Int]> {
        didUnsaveNodesElementsIdsTrigger.asSignal()
    }
}
