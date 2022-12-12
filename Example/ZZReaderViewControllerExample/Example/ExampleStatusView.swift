//
//  ExampleStatusView.swift
//  ZZReaderViewControllerExample
//
//  Created by Ethan on 2022/11/3.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

class ExampleStatusView: UIView {

    private let divider = UIView()
    private let indexPathLabel = UILabel()
    private let identityLabel = UILabel()
    private let activeScrollLabel = UILabel()

    override var tintColor: UIColor! {
        didSet {
            updateForTintColor()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(divider)
        addSubview(stackView)
        divider.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1.0),
            bottomAnchor.constraint(equalTo: divider.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 8.0),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
        stackView.addArrangedSubview(indexPathLabel)
        stackView.addArrangedSubview(identityLabel)
        stackView.addArrangedSubview(activeScrollLabel)
        updateIndexPath(nil)
        updateIdentity(nil)
        updateActiveScroll(false)
        if #available(iOS 13.0, *) {
            tintColor = UIColor.secondaryLabel
        } else {
            tintColor = UIColor.darkGray
        }
        indexPathLabel.font = .systemFont(ofSize: 11)
        identityLabel.font = .systemFont(ofSize: 11)
        activeScrollLabel.font = .systemFont(ofSize: 11)
        updateForTintColor()
    }

    private func updateForTintColor() {
        divider.backgroundColor = tintColor
        indexPathLabel.textColor = tintColor
        identityLabel.textColor = tintColor
        activeScrollLabel.textColor = tintColor
    }
    
    func updateIndexPath(_ indexPath: IndexPath?) {
        indexPathLabel.text = "IndexPath: \(indexPath?.description ?? "")"
    }

    func updateIdentity(_ identity: String?) {
        identityLabel.text = "Identity: \(identity ?? "")"
    }
    
    func updateActiveScroll(_ isProbablyActiveInScroll: Bool) {
        activeScrollLabel.text = "isProbablyActiveInScroll: \(isProbablyActiveInScroll)"
    }
}
