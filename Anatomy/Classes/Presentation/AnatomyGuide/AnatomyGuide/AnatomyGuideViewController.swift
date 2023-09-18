//
//  AnatomyGuideViewController.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import UIKit
import RxSwift

final class AnatomyGuideViewController: UIViewController {
    lazy var mainView = AnatomyGuideView()
    
    private lazy var viewModel = AnatomyGuideViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: AnatomyGuideViewModel.Input(
            didSearch: mainView.searchView.changedText,
            didSelect: mainView.tableView.didSelect,
            didSelectFilter: mainView.filterView.didSelect
        ))
        
        output.filters
            .drive(Binder(mainView.filterView) { base, filters in
                base.setup(elements: filters)
            })
            .disposed(by: disposeBag)
        
        output.elements
            .drive(Binder(mainView.tableView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.isEmpty
            .drive(Binder(self) { base, empty in
                base.empty(empty)
            })
            .disposed(by: disposeBag)
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        mainView.rx.keyboardHeight
            .bind(to: Binder(mainView.tableView) { base, keyboardHeight in
                base.contentInset.bottom = keyboardHeight > 0 ? keyboardHeight + 20.scale : 20.scale
            })
            .disposed(by: disposeBag)
        
        mainView.searchView.textField.becomeFirstResponder()
    }
}

// MARK: Public
extension AnatomyGuideViewController {
    static func make() -> AnatomyGuideViewController {
        let vc = AnatomyGuideViewController()
        vc.navigationItem.backButtonTitle = " "
        vc.navigationItem.title = "AnatomyGuide.Title".localized
        return vc
    }
}

// MARK: Private
private extension AnatomyGuideViewController {
    func empty(_ empty: Bool) {
        mainView.tableView.isHidden = empty
        mainView.emptyView.isHidden = !empty
    }
    
    func route(_ route: AnatomyGuideViewModel.Route) {
        switch route {
        case .nodeElement(let element):
            let vc = AnatomyGuideNodeViewController.make(element: element)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
