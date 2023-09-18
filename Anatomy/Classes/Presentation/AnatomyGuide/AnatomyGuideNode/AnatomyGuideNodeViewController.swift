//
//  AnatomyGuideNodeViewController.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import UIKit
import RxSwift
import RxCocoa

final class AnatomyGuideNodeViewController: UIViewController {
    lazy var mainView = AnatomyGuideNodeView()
    
    private let viewModel: AnatomyGuideNodeViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var didTapMarkedTrigger = PublishRelay<Bool>()
    
    private lazy var markedButton = UIButton()
    
    private init(element: AnatomyGuideNodeElement) {
        viewModel = AnatomyGuideNodeViewModel(element: element)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    private init(header: AnatomyGuideHeader) {
        viewModel = AnatomyGuideNodeViewModel(header: header)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.tryAgain = { [weak self] error -> Observable<Void> in
            guard let self = self else {
                return .never()
            }
            
            return self.open(error: error)
        }
        
        let output = viewModel.configure(input: AnatomyGuideNodeViewModel.Input(
            didSelect: mainView.tableView.didSelect,
            didTapMark: didTapMarkedTrigger.asSignal()
        ))
        
        output.activity
            .drive(Binder(self) { base, activity in
                self.activity(activity)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                self.route(route)
            })
            .disposed(by: disposeBag)
        
        let marked = output.marked
        
        markedButton.rx.tap
            .withLatestFrom(marked)
            .bind(to: didTapMarkedTrigger)
            .disposed(by: disposeBag)
        
        marked
            .drive(Binder(self) { base, marked in
                base.update(marked: marked)
            })
            .disposed(by: disposeBag)
        
        addMarkedButton()
    }
}

// MARK: Public
extension AnatomyGuideNodeViewController {
    static func make(element: AnatomyGuideNodeElement) -> AnatomyGuideNodeViewController {
        let vc = AnatomyGuideNodeViewController(element: element)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = element.name
        return vc
    }
    
    static func make(header: AnatomyGuideHeader) -> AnatomyGuideNodeViewController {
        let vc = AnatomyGuideNodeViewController(header: header)
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = header.title
        return vc
    }
}

// MARK: Private
private extension AnatomyGuideNodeViewController {
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
    
    func addMarkedButton() {
        let item = UIBarButtonItem(customView: markedButton)
        item.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        item.customView?.widthAnchor.constraint(equalToConstant: 12.scale).isActive = true
        item.customView?.heightAnchor.constraint(equalToConstant: 18.scale).isActive = true
        
        navigationItem.rightBarButtonItem = item
    }
    
    func update(marked: Bool) {
        let image = UIImage(named: marked ? "SIC.Saved" : "SIC.Unsaved")
        markedButton.setImage(image, for: .normal)
    }
    
    func activity(_ activity: Bool) {
        mainView.tableView.isHidden = activity
        activity ? mainView.preloader.startAnimating() : mainView.preloader.stopAnimating()
    }
    
    func route(_ route: AnatomyGuideNodeViewModel.Route) {
        switch route {
        case .element(let anatomyGuideNodeElement):
            let vc = AnatomyGuideNodeViewController.make(element: anatomyGuideNodeElement)
            navigationController?.pushViewController(vc, animated: true)
        case .header(let anatomyGuideHeader):
            let vc = AnatomyGuideNodeViewController.make(header: anatomyGuideHeader)
            navigationController?.pushViewController(vc, animated: true)
        case .paygate:
            let vc = PaygateViewController.make()
            present(vc, animated: true)
        }
    }
}
