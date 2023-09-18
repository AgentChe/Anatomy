//
//  AnatomyManager.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 14.09.2023.
//

import RxSwift

protocol AnatomyManagerProtocol {
    func obtainAnatomyGuide(forceUpdate: Bool) -> Single<[AnatomyGuide]>
    func obtainNode(id: Int) -> Single<AnatomyGuideNode?>
    func save(id: Int) -> Single<Void>
    func unsave(ids: [Int]) -> Single<Void>
    func obtainBookmarks() -> Single<[AnatomyGuideNodeElement]>
}

final class AnatomyManager {
    enum Constants {
        static let anatomyGuide = "anatomy_manager_anatomy_guide_key"
    }
    
    private lazy var sessionManager = SessionManager()

    private lazy var defaultRequestWrapper = DefaultRequestWrapper()
}

// MARK: Public
extension AnatomyManager {
    func obtainAnatomyGuide(forceUpdate: Bool) -> Single<[AnatomyGuide]> {
        forceUpdate ? loadAnatomyGuide() : cachedAnatomyGuide()
    }
    
    func obtainNode(id: Int) -> Single<AnatomyGuideNode?> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetAnatomyGuideNodeRequest(userToken: userToken, id: id)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetAnatomyGuideNodeResponse.map(from: $0) }
    }
    
    func save(id: Int) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = SaveAnatomeGuideElementRequest(userToken: userToken, id: id)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                AnatomyMediator.shared.saveNodeElement(id: id)
            })
    }
    
    func unsave(ids: [Int]) -> Single<Void> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = UnsaveAnatomeGuideElementRequest(userToken: userToken, ids: ids)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .mapToVoid()
            .do(onSuccess: {
                AnatomyMediator.shared.unsaveNodesElements(ids: ids)
            })
    }
    
    func obtainBookmarks() -> Single<[AnatomyGuideNodeElement]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetAnatomyBookmarksRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetAnatomyBookmarksResponse.map(from: $0) }
    }
}

// MARK: Private
private extension AnatomyManager {
    func loadAnatomyGuide() -> Single<[AnatomyGuide]> {
        guard let userToken = sessionManager.getSession()?.userToken else {
            return .error(SignError.tokenNotFound)
        }
        
        let request = GetAnatomyGuideRequest(userToken: userToken)
        
        return defaultRequestWrapper
            .callServerApi(requestBody: request)
            .map { GetAnatomyGuideResponse.map(from: $0) }
            .do(onSuccess: { anatomyGuide in
                guard let data = try? JSONEncoder().encode(anatomyGuide) else {
                    return
                }
                
                UserDefaults.standard.set(data, forKey: Constants.anatomyGuide)
            })
    }
    
    func cachedAnatomyGuide() -> Single<[AnatomyGuide]> {
        Single<[AnatomyGuide]>.create { single in
            var anatomyGuide: [AnatomyGuide] = []
            
            if
                let data = UserDefaults.standard.data(forKey: Constants.anatomyGuide),
                    let result = try? JSONDecoder().decode([AnatomyGuide].self, from: data) {
                anatomyGuide = result
            }
            
            single(.success(anatomyGuide))
            
            return Disposables.create()
        }
    }
}
