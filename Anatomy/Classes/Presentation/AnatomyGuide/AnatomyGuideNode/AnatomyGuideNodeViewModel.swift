//
//  AnatomyGuideNodeViewModel.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import RxSwift
import RxCocoa

final class AnatomyGuideNodeViewModel {
    enum Source {
        case nodeElement(AnatomyGuideNodeElement)
        case header(AnatomyGuideHeader)
    }
    
    enum Route {
        case element(AnatomyGuideNodeElement)
        case header(AnatomyGuideHeader)
        case paygate
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    private lazy var needPaygateTrigger = PublishRelay<Void>()
    
    private lazy var anatomyManager = AnatomyManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
    
    private let source: Driver<Source>
    
    init(element: AnatomyGuideNodeElement) {
        source = BehaviorRelay(value: Source.nodeElement(element)).asDriver()
    }
    
    init(header: AnatomyGuideHeader) {
        source = BehaviorRelay(value: Source.header(header)).asDriver()
    }
}

// MARK: Public
extension AnatomyGuideNodeViewModel {
    struct Input {
        let didSelect: Signal<AnatomyGuideNodeTableElement>
        let didTapMark: Signal<Bool>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let elements: Driver<[AnatomyGuideNodeTableElement]>
        let route: Driver<Route>
        let marked: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let node = makeNode()
        let activeSubscription = makeActiveSubscription()
        let bookmarkNodes = makeBookmarsNodes()
        let canSave = makeCanSave(
            bookmarkNodes: bookmarkNodes,
            activeSubscription: activeSubscription
        )
        
        return Output(
            activity: activity.asDriver(),
            elements: makeElements(node: node),
            route: makeRoute(didSelect: input.didSelect),
            marked: makeBookmark(
                node: node,
                didTapMark: input.didTapMark,
                canSave: canSave
            )
        )
    }
}

// MARK: Private
private extension AnatomyGuideNodeViewModel {
    func makeBookmark(
        node: Driver<AnatomyGuideNode>,
        didTapMark: Signal<Bool>,
        canSave: Driver<Bool>
    ) -> Driver<Bool> {
        let content = node
            .compactMap { node -> AnatomyGuideContent? in
                switch node {
                case .content(let content):
                    return content
                default:
                    return nil
                }
            }
        
        let initial = content
            .map { $0.saved }
        
        let action = didTapMark
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(canSave) { ($0, $1) }
            .withLatestFrom(content) {  ($0.0, $0.1, $1) }
            .flatMapLatest { [weak self] saved, canSave, content -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                if !saved && !canSave {
                    self.needPaygateTrigger.accept(Void())
                    return .just(saved)
                }
                
                func source() -> Single<Void> {
                    saved ? self.anatomyManager.unsave(ids: [content.id]) : self.anatomyManager.save(id: content.id)
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .asDriver(onErrorDriveWith: .never())
                    .map { !saved }
            }
        
        return Driver
            .merge(initial, action)
    }
    
    func makeElements(node: Driver<AnatomyGuideNode>) -> Driver<[AnatomyGuideNodeTableElement]> {
        node.map { node -> [AnatomyGuideNodeTableElement] in
            switch node {
            case let .list(header, elements):
                return Self.makeElementsAtList(header: header, elements: elements)
            case .content(let content):
                return Self.makeElementsAtContent(content)
            }
        }
    }
    
    func makeNode() -> Driver<AnatomyGuideNode> {
        source
            .flatMapLatest { [weak self] input -> Driver<AnatomyGuideNode> in
                guard let self else { return .never() }
                
                func source() -> Single<AnatomyGuideNode> {
                    self.anatomyManager
                        .obtainNode(id: input.id)
                        .map { node -> AnatomyGuideNode in
                            guard let node else { throw ContentError(.notContent) }
                            
                            return node
                        }
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(source: { source() },
                           trigger: { trigger(error: $0) })
                    .trackActivity(activity)
                    .asDriver(onErrorDriveWith: .never())
            }
    }
    
    func makeRoute(didSelect: Signal<AnatomyGuideNodeTableElement>) -> Driver<Route> {
        let select = didSelect
            .asDriver(onErrorDriveWith: .never())
            .compactMap { selection -> Route? in
                switch selection {
                case let .element(element, _):
                    return .element(element)
                case .header(let header):
                    return .header(header)
                default:
                    return nil
                }
            }
        
        let paygate = needPaygateTrigger
            .map { Route.paygate }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(select, paygate)
    }
    
    func makeCanSave(
        bookmarkNodes: Driver<[AnatomyGuideNodeElement]>,
        activeSubscription: Driver<Bool>
    ) -> Driver<Bool> {
        activeSubscription
            .flatMapLatest { activeSubscription -> Driver<Bool> in
                guard !activeSubscription else {
                    return .just(true)
                }
                
                return bookmarkNodes
                    .map { $0.count < 1 }
            }
    }
    
    func makeBookmarsNodes() -> Driver<[AnatomyGuideNodeElement]> {
        Driver
            .merge(
                AnatomyMediator.shared.didSaveNodeElementId
                    .map { id in Void() }
                    .asDriver(onErrorDriveWith: .never()),
                AnatomyMediator.shared.didUnsaveNodesElementsIds
                    .map { ids in Void() }
                    .asDriver(onErrorDriveWith: .never())
            )
            .startWith(Void())
            .flatMapLatest { [weak self] void -> Driver<[AnatomyGuideNodeElement]> in
                guard let self = self else {
                    return .never()
                }
                
                return self.anatomyManager
                    .obtainBookmarks()
                    .asDriver(onErrorJustReturn: [])
            }
    }
    
    func makeActiveSubscription() -> Driver<Bool> {
        PurchaseValidationObserver.shared
            .didValidatedWithActiveSubscription
            .map { SessionManager().hasActiveSubscriptions() }
            .startWith(SessionManager().hasActiveSubscriptions())
            .asDriver(onErrorJustReturn: false)
    }
}

// MARK: Additional
private extension AnatomyGuideNodeViewModel {
    static func makeElementsAtList(
        header: AnatomyGuideHeader?,
        elements: [AnatomyGuideNodeElement]
    ) -> [AnatomyGuideNodeTableElement] {
        var result = [AnatomyGuideNodeTableElement]()
        
        if let header {
            result.append(.header(header))
        }
        
        elements.enumerated().forEach { index, element in
            result.append(.element(element, separatorHidden: ((elements.count - 1) == index)))
        }
        
        return result
    }
    
    static func makeElementsAtContent(_ content: AnatomyGuideContent) -> [AnatomyGuideNodeTableElement] {
        var result = [AnatomyGuideNodeTableElement.title(content.name)]
        
        content.blocks.forEach { block in
            switch block {
            case .image(let url):
                result.append(.image(url))
            case .text(let text):
                result.append(.text(text))
            }
        }
        
        return result
    }
}

// MARK: Additional
private extension AnatomyGuideNodeViewModel.Source {
    var id: Int {
        switch self {
        case .nodeElement(let element):
            return element.id
        case .header(let element):
            return element.id
        }
    }
}
