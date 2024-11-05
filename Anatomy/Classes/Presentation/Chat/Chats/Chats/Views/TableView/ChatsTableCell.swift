//
//  ChatsTableCell.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 28.10.2024.
//

import UIKit

final class ChatsTableCell: UITableViewCell {
    var didTapDelete: (() -> Void)?
    
    lazy var container = makeContainer()
    lazy var messageLabel = makeLabel()
    lazy var createdLabel = makeLabel()
    
    private lazy var messageAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.regular(size: 16.scale))
        .lineHeight(19.scale)
        .textAlignment(.left)
        .lineBreakMode(.byTruncatingTail)
    private lazy var createdAttrs = TextAttributes()
        .textColor(Appearance.black.withAlphaComponent(0.5))
        .font(Fonts.Avenir.regular(size: 12.scale))
        .lineHeight(14.scale)
        .textAlignment(.left)
    
    private lazy var createdFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_GB")
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ChatsTableCell {
    func setup(chat: Chat) {
        let message = chat.lastMessage.content
        let html: NSAttributedString = {
            let font = Fonts.Avenir.regular(size: 16.scale)
            let htmlWithStyle = "<span style=\"font-family: \(font.fontName); font-style: regular; font-size: \(font.pointSize); line-height: \(22.scale)px;\">\(message)</span>"
            
            guard let data = htmlWithStyle.data(using: .utf8) else { return message.attributed(with: messageAttrs) }
            
            let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            guard let attributedString else { return message.attributed(with: messageAttrs) }
            
            return attributedString
        }()
        messageLabel.attributedText = html
        
        createdLabel.attributedText = createdFormatter.string(from: chat.created).attributed(with: createdAttrs)
    }
}

// MARK: Private
private extension ChatsTableCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
    
    @objc
    func deleteTapped() {
        didTapDelete?()
    }
}

// MARK: Make constraints
private extension ChatsTableCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -48.scale),
            messageLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            createdLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            createdLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -48.scale),
            createdLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 6.scale),
            createdLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ChatsTableCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 16.scale
        layer.shadowColor = Appearance.black.withAlphaComponent(0.4).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
