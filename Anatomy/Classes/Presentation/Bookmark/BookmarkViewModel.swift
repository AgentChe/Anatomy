//
//  BookmarkViewModel.swift
//  MedicalGuides
//
//  Created by Андрей Чернышев on 03.06.2023.
//

import RxSwift
import RxCocoa

final class BookmarkViewModel {
    enum Route {
        case anatomy(AnatomyGuideNodeElement)
        case condition(SymptomsInteractionConditionDetails)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()

    private lazy var nodes = makeNodes()
    private lazy var conditions = makeConditions()
    
    private lazy var didDeleteTrigger = PublishRelay<Bool>()
    
    private lazy var symptomsManager = SymptomsManager()
    private lazy var anatomyManager = AnatomyManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension BookmarkViewModel {
    struct Input {
        let didTapFilter: Signal<BookmarkFilterView.Filter>
        let didTapDone: Signal<Void>
        let didTapEdit: Signal<Void>
        let didTapDelete: Signal<Void>
        let didTapNode: Signal<AnatomyGuideNodeElement>
        let didTapCondition: Signal<SymptomsInteractionConditionDetails>
    }
    
    struct Output {
        let isEmpty: Driver<BookmarkEmptyView.Unit?>
        let navigationMode: Driver<BookmarkViewController.NavigationMode>
        let elements: Driver<[BookmarkTableElement]>
        let activity: Driver<Bool>
        let hasSelectedOnCurrentFilter: Driver<Bool>
        let route: Driver<Route>
        let disposable: Disposable
    }
    
    func configure(input: Input) -> Output {
        let didTapFilter = input
            .didTapFilter
            .startWith(.anatomy)
            .asDriver(onErrorDriveWith: .never())
        let navigationMode = makeNavigationMode(
            didTapDone: input.didTapDone,
            didTapEdit: input.didTapEdit,
            didDelete: didDeleteTrigger.asSignal()
        )
        let selectedNodes = makeSelectedNodesElements(
            navigationMode: navigationMode,
            didTapNodeElement: input.didTapNode
        )
        let selectedConditions = makeSelectedConditions(
            navigationMode: navigationMode,
            didTapCondition: input.didTapCondition
        )
        let nodesElements = makeNodesElements(
            navigationMode: navigationMode,
            selectedNodes: selectedNodes
        )
        let conditionsElements = makeConditionsElements(
            navigationMode: navigationMode,
            selectedConditions: selectedConditions
        )
        let route = makeRoute(
            navigationMode: navigationMode,
            didTapNodeElement: input.didTapNode,
            didTapCondition: input.didTapCondition
        )
        let didDelete = makeDelete(
            didTapFilter: didTapFilter,
            didTapDelete: input.didTapDelete,
            selectedNodes: selectedNodes,
            selectedConditions: selectedConditions
        )
        let disposable = didDelete
            .asSignal(onErrorSignalWith: .never())
            .emit(to: didDeleteTrigger)
        
        return Output(
            isEmpty: makeIsEmpty(
                didTapFilter: didTapFilter,
                nodesElements: nodesElements,
                conditionsElements: conditionsElements
            ),
            navigationMode: navigationMode,
            elements: makeElements(
                didTapFilter: didTapFilter,
                nodesElements: nodesElements,
                conditionsElements: conditionsElements
            ),
            activity: activity.asDriver(),
            hasSelectedOnCurrentFilter: makeHasSelectedOnCurrentFilter(
                didTapFilter: didTapFilter,
                selectedNodes: selectedNodes,
                selectedConditions: selectedConditions
            ),
            route: route,
            disposable: disposable
        )
    }
}

// MARK: Private
private extension BookmarkViewModel {
    enum DeleteAction {
        case nodes([Int])
        case conditions([Int])
    }
    
    func makeIsEmpty(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        nodesElements: Driver<[BookmarkTableElement]>,
        conditionsElements: Driver<[BookmarkTableElement]>
    ) -> Driver<BookmarkEmptyView.Unit?> {
        Driver
            .combineLatest(
                didTapFilter,
                nodesElements,
                conditionsElements
            ).map { filter, nodes, conditions -> BookmarkEmptyView.Unit? in
                switch filter {
                case .anatomy:
                    return nodes.isEmpty ? .anatomy : nil
                case .conditions:
                    return conditions.isEmpty ? .conditions : nil
                }
            }
    }
    
    func makeNavigationMode(
        didTapDone: Signal<Void>,
        didTapEdit: Signal<Void>,
        didDelete: Signal<Bool>
    ) -> Driver<BookmarkViewController.NavigationMode> {
        Signal<BookmarkViewController.NavigationMode>
            .merge(
                didTapDone.map { .normal },
                didTapEdit.map { .editable },
                didDelete.flatMapLatest { success in
                    success ? .just(.normal) : .never()
                }
            )
            .startWith(.normal)
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeElements(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        nodesElements: Driver<[BookmarkTableElement]>,
        conditionsElements: Driver<[BookmarkTableElement]>
    ) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                didTapFilter,
                nodesElements,
                conditionsElements
            )
            .map { filter, nodes, conditions -> [BookmarkTableElement] in
                switch filter {
                case .anatomy:
                    return nodes
                case .conditions:
                    return conditions
                }
            }
    }
    
    func makeHasSelectedOnCurrentFilter(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        selectedNodes: Driver<[AnatomyGuideNodeElement]>,
        selectedConditions: Driver<[SymptomsInteractionConditionDetails]>
    ) -> Driver<Bool> {
        Driver
            .combineLatest(
                didTapFilter,
                selectedNodes.startWith([]),
                selectedConditions.startWith([])
            )
            .map { filter, nodes, conditions -> Bool in
                switch filter {
                case .anatomy:
                    return !nodes.isEmpty
                case .conditions:
                    return !conditions.isEmpty
                }
            }
    }
    
    func makeNodesElements(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        selectedNodes: Driver<[AnatomyGuideNodeElement]>
    ) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                navigationMode,
                nodes,
                selectedNodes
            )
            .map { mode, bookmarkNodes, selectedNodes -> [BookmarkTableElement] in
                bookmarkNodes.map { node -> BookmarkTableElement in
                    BookmarkTableElement(
                        unit: .anatomy(node),
                        seleted: mode == .editable ? selectedNodes.contains(where: { $0.id == node.id }) : nil
                    )
                }
            }
    }
    
    func makeConditionsElements(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        selectedConditions: Driver<[SymptomsInteractionConditionDetails]>
    ) -> Driver<[BookmarkTableElement]> {
        Driver
            .combineLatest(
                navigationMode,
                conditions,
                selectedConditions
            )
            .map { mode, conditions, selectedConditions -> [BookmarkTableElement] in
                conditions.map { condition -> BookmarkTableElement in
                    BookmarkTableElement(
                        unit: .condition(condition),
                        seleted: mode == .editable ? selectedConditions.contains(where: { $0.id == condition.id }) : nil
                    )
                }
            }
    }
    
    func makeSelectedNodesElements(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapNodeElement: Signal<AnatomyGuideNodeElement>
    ) -> Driver<[AnatomyGuideNodeElement]> {
        makeSelectedUnits(
            navigationMode: navigationMode,
            didTapUnit: didTapNodeElement,
            index: { didTapNodeElement, selecteddidTapNodesElements -> Int? in
                selecteddidTapNodesElements.firstIndex(where: { $0.id == didTapNodeElement.id })
            }
        )
    }
    
    func makeSelectedConditions(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapCondition: Signal<SymptomsInteractionConditionDetails>
    ) -> Driver<[SymptomsInteractionConditionDetails]> {
        makeSelectedUnits(
            navigationMode: navigationMode,
            didTapUnit: didTapCondition,
            index: { condition, selectedConditions -> Int? in
                selectedConditions.firstIndex(where: { $0.id == condition.id })
            }
        )
    }
    
    func makeSelectedUnits<T>(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapUnit: Signal<T>,
        index: @escaping ((T, [T]) -> Int?)
    ) -> Driver<[T]> {
        navigationMode
            .flatMapLatest { mode -> Driver<[T]> in
                switch mode {
                case .editable:
                    return didTapUnit
                        .scan([]) { array, unit -> [T] in
                            if let index = index(unit, array) {
                                var result = array
                                result.remove(at: index)
                                return result
                            } else {
                                return array + [unit]
                            }
                        }
                        .startWith([])
                        .asDriver(onErrorJustReturn: [])
                case .normal:
                    return .just([])
                }
            }
    }
    
    func makeNodes() -> Driver<[AnatomyGuideNodeElement]> {
        makeUnits(
            downloadTrigger: AnatomyMediator.shared
                .didSaveNodeElementId
                .map { id in Void() },
            removeTrigger: AnatomyMediator.shared
                .didUnsaveNodesElementsIds,
            source: { [weak self] in
                guard let self = self else {
                    return .never()
                }
                
                return self.anatomyManager
                    .obtainBookmarks()
            },
            remove: { ids, nodeElement -> Bool in
                ids.contains(where: { $0 == nodeElement.id })
            }
        )
    }
    
    func makeConditions() -> Driver<[SymptomsInteractionConditionDetails]> {
        makeUnits(
            downloadTrigger: SymptomsMediator.shared
                .didSaveConditionId
                .map { id in Void() },
            removeTrigger: SymptomsMediator.shared
                .didUnsaveConditionsIds,
            source: { [weak self] in
                guard let self = self else {
                    return .never()
                }

                return self.symptomsManager
                    .obtainBookmarksConditions()
            },
            remove: { ids, condition -> Bool in
                ids.contains(where: { $0 == condition.id })
            }
        )
    }
    
    func makeUnits<T>(
        downloadTrigger: Signal<Void>,
        removeTrigger: Signal<[Int]>,
        source: @escaping () -> Single<[T]>,
        remove: @escaping ([Int], T) -> Bool
    ) -> Driver<[T]> {
        let download = downloadTrigger
            .map { id in Void() }
            .startWith(Void())
            .flatMapLatest { [weak self] void -> Driver<[T]> in
                guard let self = self else {
                    return .never()
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
                    .trackActivity(self.activity)
                    .asDriver(onErrorDriveWith: .never())
            }
        
        return download
            .flatMapLatest { units -> Driver<[T]> in
                removeTrigger
                    .startWith([])
                    .asDriver(onErrorJustReturn: [])
                    .scan(units) { array, ids -> [T] in
                        guard !ids.isEmpty else {
                            return array
                        }
                        
                        var result = array
                        result.removeAll(where: { t -> Bool in
                            remove(ids, t)
                        })
                        
                        return result
                    }
            }
    }
    
    func makeRoute(
        navigationMode: Driver<BookmarkViewController.NavigationMode>,
        didTapNodeElement: Signal<AnatomyGuideNodeElement>,
        didTapCondition: Signal<SymptomsInteractionConditionDetails>
    ) -> Driver<Route> {
        Signal<Route>
            .merge(
                didTapNodeElement.map { Route.anatomy($0) },
                didTapCondition.map { Route.condition($0) }
            )
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(navigationMode) { ($0, $1) }
            .compactMap { $1 == .normal ? $0 : nil }
    }
    
    func makeDelete(
        didTapFilter: Driver<BookmarkFilterView.Filter>,
        didTapDelete: Signal<Void>,
        selectedNodes: Driver<[AnatomyGuideNodeElement]>,
        selectedConditions: Driver<[SymptomsInteractionConditionDetails]>
    ) -> Driver<Bool> {
        let filter = didTapDelete
            .withLatestFrom(didTapFilter)
            .asDriver(onErrorDriveWith: .never())

        let selected = Driver
            .combineLatest(
                selectedNodes.startWith([]),
                selectedConditions.startWith([])
            )

        return filter
            .withLatestFrom(selected) { ($0, $1) }
            .flatMapLatest { [weak self] filter, args -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }

                let (nodes, conditions) = args

                func source() -> Single<Void> {
                    switch filter {
                    case .anatomy:
                        return self.anatomyManager
                            .unsave(ids: nodes.map { $0.id })
                    case .conditions:
                        return self.symptomsManager
                            .unsave(conditionsIds: conditions.map { $0.id })
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
                    .map { true }
                    .asDriver(onErrorJustReturn: false)
            }
    }
}
