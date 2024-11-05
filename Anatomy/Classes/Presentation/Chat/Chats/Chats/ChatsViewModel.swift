//
//  ChatsViewModel.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import RxSwift
import RxCocoa

final class ChatsViewModel {
    enum Route {
        case close
        case requestConfirmDelete(Chat)
        case chat(Chat)
    }
    
    var tryAgain: ((Error) -> (Observable<Void>))?
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var chatManager = ChatManager()
    
    private lazy var observableRetrySingle = ObservableRetrySingle()
}

// MARK: Public
extension ChatsViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didWantDelete: Signal<Chat>
        let didConfirmDelete: Signal<Chat>
        let selectChat: Signal<Chat>
    }
    
    struct Output {
        let route: Driver<Route>
        let elements: Driver<[Chat]>
        let activity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        let chatDeleted = makeDeleteChat(didConfirmDelete: input.didConfirmDelete)
        
        return Output(
            route: makeRoute(
                didTapClose: input.didTapClose,
                didWantDelete: input.didWantDelete,
                selectChat: input.selectChat
            ),
            elements: makeElements(chatDeleted: chatDeleted),
            activity: activity.asDriver()
        )
    }
}

// MARK: Private
private extension ChatsViewModel {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_GB")
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    func makeRoute(
        didTapClose: Signal<Void>,
        didWantDelete: Signal<Chat>,
        selectChat: Signal<Chat>
    ) -> Driver<Route> {
        let close = didTapClose
            .map { Route.close }
            .asDriver(onErrorDriveWith: .never())
        
        let requestConfirmDelete = didWantDelete
            .map { Route.requestConfirmDelete($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let chat = selectChat
            .map { Route.chat($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(close, requestConfirmDelete, chat)
    }
    
    func makeElements(chatDeleted: Signal<Void>) -> Driver<[Chat]> {
        chatManager
            .chats()
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: [])
            .flatMapLatest { [weak self] chats -> Driver<[Chat]> in
                chatDeleted
                    .flatMapLatest { [weak self] void -> Driver<[Chat]> in
                        guard let self else { return .never() }
                        
                        return chatManager
                            .chats()
                            .asDriver(onErrorJustReturn: [])
                    }
                    .startWith(chats)
            }
            .map { $0.sorted(by: { $0.created > $1.created }) }
    }
    
    func makeDeleteChat(didConfirmDelete: Signal<Chat>) -> Signal<Void> {
        didConfirmDelete
            .flatMapLatest { [weak self] chat -> Signal<Void> in
                guard let self = self else {
                    return .never()
                }
                
                func source() -> Single<Void> {
                    self.chatManager
                        .deleteChat(id: chat.id)
                }
                
                func trigger(error: Error) -> Observable<Void> {
                    guard let tryAgain = self.tryAgain?(error) else {
                        return .empty()
                    }
                    
                    return tryAgain
                }
                
                return self.observableRetrySingle
                    .retry(
                        source: { source() },
                        trigger: { trigger(error: $0) }
                    )
                    .asSignal(onErrorSignalWith: .never())
            }
    }
}
