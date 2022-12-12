//
//  ExampleItemViewController.swift
//  ZZReaderViewControllerExample
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit
import ZZReaderViewController

class ExampleItemViewController: UIViewController, ZZReaderItemViewController {

    var indexPath: IndexPath

    init(indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        label.text = "Page \(indexPath.description)"
        label.font = .systemFont(ofSize: 20.0, weight: .medium)
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.label
        } else {
            label.textColor = UIColor.black
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return indexPath.item % 2 == 0 ? .lightContent : .default
    }
}
