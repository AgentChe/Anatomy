//
//  SCReferencesView.swift
//  Anatomy
//
//  Created by Андрей Чернышев on 25.09.2023.
//

import UIKit

final class SCReferencesView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var titleLabel = makeTitleLabel()
    lazy var textLabel = makeTextLabel()
    lazy var link1Button = makeButton(link: "References.Link1".localized)
    lazy var link2Button = makeButton(link: "References.Link2".localized)
    lazy var okButton = makeOkButton()
    
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
private extension SCReferencesView {
    func initialize() {
        backgroundColor = Appearance.background
    }
}

// MARK: Make constraints
private extension SCReferencesView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -2.scale)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            textLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.scale)
        ])
        
        NSLayoutConstraint.activate([
            link1Button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            link1Button.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            link1Button.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 10.scale),
            link1Button.heightAnchor.constraint(equalToConstant: 21.scale)
        ])
        
        NSLayoutConstraint.activate([
            link2Button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            link2Button.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            link2Button.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            link2Button.topAnchor.constraint(equalTo: link1Button.bottomAnchor, constant: 10.scale),
            link2Button.heightAnchor.constraint(equalToConstant: 21.scale)
        ])
        
        NSLayoutConstraint.activate([
            okButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            okButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            okButton.heightAnchor.constraint(equalToConstant: 63.scale),
            okButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: ScreenSize.isIphoneXFamily ? -60.scale : -30.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SCReferencesView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.contentInset = UIEdgeInsets(top: 24.scale, left: 0, bottom: 24.scale, right: 0)
        view.setContentOffset(CGPoint(x: 0, y: -24.scale), animated: false)
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 25.scale))
            .lineHeight(28.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "References.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.regular(size: 15.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "References.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeButton(link: String) -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.secondary2)
            .font(Fonts.Avenir.regular(size: 15.scale))
        
        let view = UIButton()
        view.contentHorizontalAlignment = .left
        view.setAttributedTitle(link.attributed(with: attrs), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeOkButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.Avenir.regular(size: 20.scale))
                  
        let view = UIButton()
        view.setAttributedTitle("OK".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.primary
        view.layer.cornerRadius = 10.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
