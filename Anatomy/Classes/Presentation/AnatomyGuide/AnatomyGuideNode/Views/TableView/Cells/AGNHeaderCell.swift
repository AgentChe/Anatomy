//
//  AGNHeaderCell.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import UIKit
import Kingfisher

final class AGNHeaderCell: UITableViewCell {
    lazy var container = makeContainer()
    lazy var iconView = makeImageViwe()
    lazy var titleLabel = makeLabel()
    lazy var subTitleLabel = makeLabel()
    lazy var seeMoreLabel = makeSeeMoreLabel()
    
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.bold(size: 21.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
    private lazy var subTitleAttrs = TextAttributes()
        .textColor(Appearance.black)
        .font(Fonts.Avenir.regular(size: 15.scale))
        .lineHeight(21.scale)
        .textAlignment(.left)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconView.kf.cancelDownloadTask()
        iconView.image = nil
    }
}

// MARK: Public
extension AGNHeaderCell {
    func setup(element: AnatomyGuideHeader) {
        iconView.kf.setImage(with: element.image)
        titleLabel.attributedText = element.title.attributed(with: titleAttrs)
        subTitleLabel.attributedText = element.text.attributed(with: subTitleAttrs)
    }
}

// MARK: Private
private extension AGNHeaderCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension AGNHeaderCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 73.scale),
            iconView.heightAnchor.constraint(equalToConstant: 69.scale),
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 99.scale),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 99.scale),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4.scale),
            subTitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            seeMoreLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 99.scale),
            seeMoreLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 4.scale),
            seeMoreLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale),
            seeMoreLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AGNHeaderCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.white
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeImageViwe() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeSeeMoreLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.primary)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .lineHeight(21.scale)
            .underlineStyle(.single)
            .underlineColor(Appearance.primary)
        
        let view = UILabel()
        view.attributedText = "AGN.SeeMore".localized.attributed(with: attrs)
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
