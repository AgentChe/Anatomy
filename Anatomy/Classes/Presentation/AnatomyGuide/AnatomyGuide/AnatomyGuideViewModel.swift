//
//  AnatomyGuideViewModel.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import RxSwift
import RxCocoa

final class AnatomyGuideViewModel {
    enum Route {
        case nodeElement(AnatomyGuideNodeElement)
    }
    
    private lazy var anatomyManager = AnatomyManager()
}

// MARK: Public
extension AnatomyGuideViewModel {
    struct Input {
        let didSearch: Signal<String>
        let didSelect: Signal<AnatomyGuideNodeElement>
        let didSelectFilter: Signal<AnatomyGuideFilterElement>
    }
    
    struct Output {
        let filters: Driver<[AnatomyGuideFilterElement]>
        let route: Driver<Route>
        let elements: Driver<[AnatomyGuideNodeElement]>
        let isEmpty: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let anatomyGuide = makeAnatomyGuide()
        let filters = makeFilters(anatomyGuide: anatomyGuide)
        let currentNodeElements = makCurrentNodeElements(
            filter: makeFilter(
                didSelect: input.didSelectFilter,
                filters: filters
            ),
            anatomyGuide: anatomyGuide
        )
        let elements = makeElements(
            search: input.didSearch,
            currentNodeElements: currentNodeElements
        )
        
        return Output(
            filters: filters,
            route: makeRoute(didSelect: input.didSelect),
            elements: elements,
            isEmpty: makeIsEmpty(
                didSearch: input.didSearch,
                elements: elements
            )
        )
    }
}

// MARK: Private
private extension AnatomyGuideViewModel {
    func makeFilter(
        didSelect: Signal<AnatomyGuideFilterElement>,
        filters: Driver<[AnatomyGuideFilterElement]>
    ) -> Driver<AnatomyGuideFilterElement> {
        let initial = filters
            .compactMap { $0.first }
            .asDriver(onErrorDriveWith: .never())
        let action = didSelect
            .asDriver(onErrorDriveWith: .never())
        return Driver.merge(initial, action)
    }
    
    func makeRoute(
        didSelect: Signal<AnatomyGuideNodeElement>) -> Driver<Route> {
        didSelect
            .asDriver(onErrorDriveWith: .never())
            .map { Route.nodeElement($0) }
    }
    
    func makeElements(
        search: Signal<String>,
        currentNodeElements: Driver<[AnatomyGuideNodeElement]>
    ) -> Driver<[AnatomyGuideNodeElement]> {
        Driver
            .combineLatest(
                search.asDriver(onErrorDriveWith: .never()),
                currentNodeElements
            )
            .map { search, elements -> [AnatomyGuideNodeElement] in
                guard !search.isEmpty else {
                    return elements
                }
                
                return elements.filter { element -> Bool in
                    element.name.contains(search)
                }
            }
    }
    
    func makeIsEmpty(didSearch: Signal<String>, elements: Driver<[AnatomyGuideNodeElement]>) -> Driver<Bool> {
        Driver
            .combineLatest(
                didSearch.asDriver(onErrorJustReturn: ""),
                elements
            )
            .map { search, elements -> Bool in
                guard !search.isEmpty else {
                    return false
                }
                
                return elements.isEmpty
            }
            .startWith(false)
    }
    
    func makCurrentNodeElements(
        filter: Driver<AnatomyGuideFilterElement>,
        anatomyGuide: Driver<[AnatomyGuide]>
    ) -> Driver<[AnatomyGuideNodeElement]> {
        Driver
            .combineLatest(filter, anatomyGuide)
            .compactMap { filter, anatomyGuide -> [AnatomyGuideNodeElement]? in
                anatomyGuide.first(where: { $0.name == filter.group }).map { $0.nodes }
            }
    }
    
    func makeFilters(anatomyGuide: Driver<[AnatomyGuide]>) -> Driver<[AnatomyGuideFilterElement]> {
        anatomyGuide
            .map { anatomyGuide -> [AnatomyGuideFilterElement] in
                anatomyGuide.enumerated().map {
                    AnatomyGuideFilterElement(
                        group: $1.name,
                        isSelected: $0 == 0
                    )
                }
            }
    }
    
    func makeAnatomyGuide() -> Driver<[AnatomyGuide]> {
        anatomyManager
            .obtainAnatomyGuide(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}
