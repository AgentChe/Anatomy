//
//  ChatsView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit

final class ChatsView: UIView {
    lazy var closeButton = makeCloseButton()
    lazy var titleLabel = makeTitleLabel()
    lazy var tableView = makeTableView()
    lazy var preloader = makePreloader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ChatsView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 247, green: 247, blue: 247)
    }
}

// MARK: Make constraints
private extension ChatsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 24.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 24.scale),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatsView {
    func makeCloseButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "Chats.Close"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }

    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 21.scale))
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Chats.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> ChatsTableView {
        let view = ChatsTableView()
        view.contentInset = UIEdgeInsets(top: 16.scale, left: 0, bottom: 16.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor(integralRed: 247, green: 247, blue: 247)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = Appearance.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
