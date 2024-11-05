//
//  PaygateInteractor.swift
//  Manga
//
//  Created by Андрей Чернышев on 02.09.2022.
//

import RxSwift
import RxCocoa
import OtterScaleiOS

final class PaygateInteractor {
    enum Action {
        case buy(String)
        case restore
    }
    
    enum PurchaseActionResult {
        case cancelled
        case completed(Bool)
    }
    
    private lazy var iapManager = IAPManager()
    private lazy var sessionManager = SessionManager()
    private lazy var profileManager = ProfileManager()
    private lazy var validationObserver = PurchaseValidationObserver.shared
    
    private lazy var disposables = [Disposable]()
    
    private lazy var callback = PublishRelay<PurchaseActionResult>()
    
    deinit {
        OtterScale.shared.removeReceiptValidation(delegate: self)
        
        disposables.forEach { $0.dispose() }
    }
}

// MARK: Public
extension PaygateInteractor {
    func makeActiveSubscription(by action: Action) -> Single<PurchaseActionResult> {
        OtterScale.shared.removeReceiptValidation(delegate: self)
        OtterScale.shared.addReceiptValidation(delegate: self)
        
        disposables.forEach { $0.dispose() }
        
        let disposable: Disposable
        switch action {
        case .buy(let productId):
            disposable = purchase(productId: productId)
        case .restore:
            disposable = restore()
        }
        
        disposables = [disposable]
        
        return Single<PurchaseActionResult>.create { [weak self] event in
            guard let self = self else {
                return Disposables.create()
            }
            
            let disposable = self.callback.subscribe(onNext: { result in
                event(.success(result))
            })
            
            self.disposables.append(disposable)
            
            return Disposables.create()
        }
    }
}

// MARK: OtterScaleReceiptValidationDelegate
extension PaygateInteractor: OtterScaleReceiptValidationDelegate {
    func otterScaleDidValidatedReceipt(with result: AppStoreValidateResult?) {
        OtterScale.shared.removeReceiptValidation(delegate: self)
        
        let complete: Single<Void> = {
            let anonymousId = sessionManager.anonymousId
            let internalId = sessionManager.internalId
        
            let scinCare = (anonymousId == internalId) ? profileManager.create() : profileManager.binding()
            let dermatology = (anonymousId == internalId) ? profileManager.anatomyLogin() : profileManager.anatomySyncTokens()
        
            return Single
                .zip(scinCare, dermatology)
                .mapToVoid()
                .catchAndReturn(())
        }()
        
        let disposable = complete.subscribe(onSuccess: { [weak self] in
            guard let self = self else {
                return
            }
            
            let session = Session(userToken: OtterScale.shared.getInternalID())
            self.sessionManager.store(session: session)
            
            let hasActiveSubscriptions = self.sessionManager.hasActiveSubscriptions()
            let callbackResult = PurchaseActionResult.completed(hasActiveSubscriptions)
            self.callback.accept(callbackResult)
        })
        
        disposables.append(disposable)
    }
}

// MARK: Private
private extension PaygateInteractor {
    func purchase(productId: String) -> Disposable {
        iapManager
            .buyProduct(with: productId)
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self, case .cancelled = result else {
                    return
                }
                
                self.callback.accept(.cancelled)
            })
    }
    
    func restore() -> Disposable {
        iapManager
            .restorePurchases()
            .subscribe()
    }
}
