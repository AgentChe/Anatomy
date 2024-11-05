//
//  AnalyseImageResizeOptionsView.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 31.10.2024.
//

import UIKit
import RxSwift

final class AnalyseImageResizeOptionsView: UIView {
    lazy var acceptButton = makeAcceptButton()
    lazy var retakeButton = makeRetakeButton()
    
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
private extension AnalyseImageResizeOptionsView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension AnalyseImageResizeOptionsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            acceptButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            acceptButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            acceptButton.heightAnchor.constraint(equalToConstant: 54.scale),
            acceptButton.bottomAnchor.constraint(equalTo: retakeButton.topAnchor, constant: -12.scale)
        ])
        
        NSLayoutConstraint.activate([
            retakeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            retakeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            retakeButton.heightAnchor.constraint(equalToConstant: 54.scale),
            retakeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AnalyseImageResizeOptionsView {
    func makeAcceptButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.white)
            .font(Fonts.Avenir.bold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("AnalyseImageResize.AcceptPhoto".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = Appearance.secondary3
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeRetakeButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.black)
            .font(Fonts.Avenir.bold(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("AnalyseImageResize.Retake".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor(integralRed: 239, green: 233, blue: 220)
        view.layer.cornerRadius = 16.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
