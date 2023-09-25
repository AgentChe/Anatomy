//
//  SCReferencesViewController.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 25.09.2023.
//

import UIKit
import RxSwift

final class SCReferencesViewController: UIViewController {
    lazy var mainView = SCReferencesView()
    
    private lazy var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable
            .merge(
                mainView.link1Button.rx.tap
                    .map { "References.Link1".localized },
                mainView.link2Button.rx.tap
                    .map { "References.Link2".localized }
            )
            .bind(to: Binder(self) { base, link in
                guard let url = URL(string: link) else {
                    return
                }
                
                UIApplication.shared.open(url)
            })
            .disposed(by: disposeBag)
        
        mainView.okButton.rx.tap
            .bind(to: Binder(self) { base, void in
                base.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension SCReferencesViewController {
    static func make() -> SCReferencesViewController {
        let vc = SCReferencesViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}
