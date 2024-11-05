//
//  ChatViewController.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift
import PhotosUI

final class ChatViewController: UIViewController {
    private lazy var mainView = ChatView()
    
    private lazy var viewModel = ChatViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var historyButton = UIButton()
    
    private lazy var didSelectChatFromHistoryTrigger = PublishRelay<Chat>()
    private lazy var didAddedImageTrigger = PublishRelay<UIImage>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationButton()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        mainView.tableView
            .didChangeElementsCount
            .emit(to: Binder(mainView) { base, count in
                base.placeholderView.isHidden = (count > 0)
                base.tableView.isHidden = (count == 0)
            })
            .disposed(by: disposeBag)
        
        mainView.addFileButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.selectFileSource()
            })
            .disposed(by: disposeBag)
        
        let didSendTextMessage = mainView.inputField
            .sendButton.rx.tap
            .withLatestFrom(mainView.inputField.textField.rx.text)
            .compactMap { message -> ChatViewModel.DataForSendMessage? in
                guard let message, !message.isEmpty else { return nil }
                return (nil, message)
            }
            .asSignal(onErrorSignalWith: .never())
        let didSendTextImageMessage = didAddedImageTrigger
            .withLatestFrom(mainView.inputField.textField.rx.text) { ($0, $1) }
            .compactMap { args -> ChatViewModel.DataForSendMessage? in
                let (image, message) = args
                
                guard let message, !message.isEmpty else { return nil }
                return (image, message)
            }
            .asSignal(onErrorSignalWith: .never())
        let didSendMessage = Signal
            .merge(
                didSendTextMessage,
                didSendTextImageMessage
            )
        
        let didTapRegenerate = mainView.regenerateView
            .regenerateButton.rx.tap.asSignal()
            .withLatestFrom(didSendMessage)
        
        let output = viewModel.configure(input: ChatViewModel.Input(
            didTapHistory: historyButton.rx.tap.asSignal(),
            didSelectChatFromHistory: didSelectChatFromHistoryTrigger.asSignal(),
            didScrollToTop: mainView.tableView.didScrollToTop,
            didSendMessage: didSendMessage,
            didTapRegenerate: didTapRegenerate,
            didTapCopy: mainView.tableView.didCopy,
            didTapRefresh: mainView.tableView.didRefresh,
            didInputText: mainView.inputField
                .textField.rx.text
                .map { $0 ?? "" }
                .asSignal(onErrorSignalWith: .never())
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.lockAddFile
            .drive(Binder(mainView.addFileButton) { base, lock in
                base.isEnabled = !lock
                base.alpha = lock ? 0.5 : 1
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension ChatViewController {
    static func make() -> ChatViewController {
        let vc = ChatViewController()
        vc.navigationItem.title = "Chat.Title".localized
        vc.navigationItem.backButtonTitle = " "
        return vc
    }
}

// MARK: PHPickerViewControllerDelegate
extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results
            .map (\.itemProvider)
            .filter { $0.canLoadObject(ofClass: UIImage.self) }
            .first
        guard let itemProvider else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    self?.didAddedImageTrigger.accept(image)
                }
            }
        }
    }
}

// MARK: Private
private extension ChatViewController {
    func open(error: Error) -> Observable<Void> {
        Observable<Void>
            .create { [weak self] observe in
                guard let self = self else {
                    return Disposables.create()
                }
                
                let vc = TryAgainViewController.make(error: error) {
                    observe.onNext(())
                }
                self.present(vc, animated: true)
                
                return Disposables.create()
            }
    }
    
    func route(_ route: ChatViewModel.Route) {
        switch route {
        case .history:
            let vc = ChatsViewController.make { [weak self] chat in
                self?.didSelectChatFromHistoryTrigger.accept(chat)
            }
            present(vc, animated: true)
        }
    }
    
    func action(_ action: ChatViewModel.Action) {
        switch action {
        case .reset:
            mainView.tableView.reset()
        case .insertPage(let elements):
            mainView.tableView.insert(elements: elements)
        case .add(let elements):
            mainView.tableView.add(elements: elements)
        case .removeAnswer(let messageId):
            mainView.tableView.remove(answer: messageId)
        case .startWaiting:
            mainView.tableView.loading(waitAnswer: true)
        case .stopWaiting:
            mainView.tableView.loading(waitAnswer: false)
        case .changeInput(let input):
            mainView.inputField.isHidden = (input != .questionInput)
            mainView.regenerateView.isHidden = (input != .regenerateLastQuestion)
        case .clearInput:
            mainView.inputField.textField.text = ""
        case .copy(let text):
            UIPasteboard.general.string = text
            
            mainView.makeToast("Chat.Copied.Toast".localized)
        case .lockSendMessage(let lock):
            mainView.inputField.sendButton.isEnabled = !lock
        }
    }
    
    func addNavigationButton() {
        let historyItem = UIBarButtonItem(customView: historyButton)
        historyItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        historyItem.customView?.widthAnchor.constraint(equalToConstant: 24.scale).isActive = true
        historyItem.customView?.heightAnchor.constraint(equalToConstant: 24.scale).isActive = true
        
        historyButton.setImage(UIImage(named: "Chat.History"), for: .normal)
        
        navigationItem.rightBarButtonItem = historyItem
    }
    
    func selectFileSource() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Chat.FileSource.Gallery".localized, style: .default) { [weak self] action in
            guard let self else { return }
            
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            configuration.preferredAssetRepresentationMode = .automatic
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            present(picker, animated: true)
        }
        alert.addAction(galleryAction)
        
        let cameraAction = UIAlertAction(title: "Chat.FileSource.Camera".localized, style: .default) { [weak self] action in
            guard let self else { return }
            
            AnalyseScanAssembly().scan(from: self) { [weak self] image in
                self?.didAddedImageTrigger.accept(image)
            }
        }
        alert.addAction(cameraAction)
        
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
