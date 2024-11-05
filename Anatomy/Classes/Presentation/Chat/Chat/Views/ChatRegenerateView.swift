//
//  ChatRegenerateView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 29.10.2024.
//

import UIKit

final class ChatRegenerateView: UIView {
    lazy var iconView = makeIconView()
    lazy var textLabel = makeTextLabel()
    lazy var regenerateButton = makeRegenerateButton()
    
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
private extension ChatRegenerateView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension ChatRegenerateView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: 24.scale),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 27.scale),
            iconView.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 51.scale),
            textLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            regenerateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            regenerateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            regenerateButton.heightAnchor.constraint(equalToConstant: 54.scale),
            regenerateButton.topAnchor.constraint(equalTo: topAnchor, constant: 40.scale),
            regenerateButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatRegenerateView {
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Chat.Regenerate")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor(integralRed: 245, green: 0, blue: 0))
            .font(Fonts.Avenir.regular(size: 16.scale))
            .lineHeight(19.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Chat.Regenerate.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRegenerateButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.Avenir.bold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Chat.Regenerate.Button".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 16.scale
        view.backgroundColor = Appearance.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
