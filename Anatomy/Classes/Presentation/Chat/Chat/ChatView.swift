//
//  ChatView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 26.10.2024.
//

import UIKit

final class ChatView: UIView {
    lazy var placeholderView = makePlaceholderView()
    lazy var tableView = makeTableView()
    lazy var inputField = makeInputField()
    lazy var regenerateView = makeRegenerateView()
    
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
private extension ChatView {
    func initialize() {
        backgroundColor = UIColor(integralRed: 247, green: 247, blue: 247)
    }
}

// MARK: Make constraints
private extension ChatView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            placeholderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            placeholderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            placeholderView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 58.scale)
        ])
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 2.scale),
            tableView.bottomAnchor.constraint(equalTo: inputField.topAnchor, constant: -8.scale)
        ])
        
        NSLayoutConstraint.activate([
            inputField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            inputField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            inputField.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -14.scale)
        ])
        
        NSLayoutConstraint.activate([
            regenerateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            regenerateView.trailingAnchor.constraint(equalTo: trailingAnchor),
            regenerateView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -14.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatView {
    func makePlaceholderView() -> ChatPlaceholderView {
        let view = ChatPlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTableView() -> ChatTableView {
        let view = ChatTableView()
        view.contentInset = UIEdgeInsets(top: 16.scale, left: 0, bottom: 42.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeInputField() -> ChatInputField {
        let view = ChatInputField()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRegenerateView() -> ChatRegenerateView {
        let view = ChatRegenerateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
