//
//  AnatomyGuideFilterCell.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 15.09.2023.
//

import UIKit

final class AnatomyGuideFilterCell: UICollectionViewCell {
    lazy var nameLabel = makeNameLabel()
    lazy var separator = makeSeparator()
    
    static private let attrs = TextAttributes()
        .textColor(UIColor(integralRed: 75, green: 57, blue: 38))
        .font(Fonts.Avenir.medium(size: 17.scale))
        .lineHeight(20.4.scale)
        .letterSpacing(-0.17.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AnatomyGuideFilterCell {
    static func width(for element: AnatomyGuideFilterElement) -> CGFloat {
        let string = element.group.attributed(with: AnatomyGuideFilterCell.attrs)
        return string.size().width
    }
    
    func setup(element: AnatomyGuideFilterElement) {
        nameLabel.attributedText = element.group.attributed(with: AnatomyGuideFilterCell.attrs)
        nameLabel.alpha = element.isSelected ? 1 : 0.4
        
        separator.isHidden = !element.isSelected
    }
}

// MARK: Private
private extension AnatomyGuideFilterCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.clear
        selectedBackgroundView = selectedView
    }
}

// MARK: Make constraints
private extension AnatomyGuideFilterCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 2.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AnatomyGuideFilterCell {
    func makeNameLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(integralRed: 75, green: 57, blue: 38)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
