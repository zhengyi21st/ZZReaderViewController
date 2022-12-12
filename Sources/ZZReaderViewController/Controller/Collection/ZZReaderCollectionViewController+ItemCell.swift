//
//  ZZReaderCollectionViewController+ItemCell.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/8.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import Foundation
import UIKit

extension ZZReaderCollectionViewController {

    class ItemCell: UICollectionViewCell {

        var viewController: ZZReaderItemViewController?

        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.subviews.forEach { $0.frame = contentView.bounds }
        }

        func update(viewController: ZZReaderItemViewController) {
            if self.viewController?.view != viewController.view {
                self.viewController?.willMove(toParent: nil)
                self.viewController?.view.removeFromSuperview()
                self.viewController?.removeFromParent()
            }
            if viewController.view.superview != contentView {
                contentView.addSubview(viewController.view)
            }
            self.viewController = viewController
        }
    }
}
