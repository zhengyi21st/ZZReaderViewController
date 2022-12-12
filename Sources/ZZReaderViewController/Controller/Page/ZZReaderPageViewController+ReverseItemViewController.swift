//
//  ZZReaderPageReverseItemViewController.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

extension ZZReaderPageViewController {

    /// 仿真页面背面视图
    class ReverseItemViewController: UIViewController {

        let viewController: ZZReaderItemViewController

        let backgroundView = UIView()

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            viewController.view.frame = view.bounds
            backgroundView.frame = view.bounds
        }

        init(viewController: ZZReaderItemViewController) {
            self.viewController = viewController
            super.init(nibName: nil, bundle: nil)
            addChild(viewController)
            view.addSubview(viewController.view)
            view.addSubview(backgroundView)
            backgroundView.backgroundColor = viewController.view.backgroundColor?.withAlphaComponent(0.8)
            viewController.view.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
            viewController.didMove(toParent: self)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
