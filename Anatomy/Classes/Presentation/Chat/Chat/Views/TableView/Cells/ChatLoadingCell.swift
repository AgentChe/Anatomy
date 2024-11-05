//
//  ChatLoadingCell.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 29.10.2024.
//

import UIKit
import Lottie

final class ChatLoadingCell: UITableViewCell {
    lazy var iconView = makeIconView()
    lazy var container = makeContainer()
    lazy var animationView = makeAnimationView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ChatLoadingCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ChatLoadingCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            iconView.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalToConstant: 112.scale),
            animationView.heightAnchor.constraint(equalToConstant: 56.scale),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatLoadingCell {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Chat.Robot")
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 16.scale
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.shadowColor = Appearance.black.withAlphaComponent(0.4).cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 4.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeAnimationView() -> LottieAnimationView {
        let view = LottieAnimationView()
        view.animation = LottieAnimation.named("Chat.Preloader")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
