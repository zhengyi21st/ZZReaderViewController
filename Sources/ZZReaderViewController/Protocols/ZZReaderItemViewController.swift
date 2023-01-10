//
//  ZZReaderItemViewController.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

public protocol ZZReaderItemViewController: UIViewController {
    var indexPath: IndexPath { get }
}

public extension ZZReaderItemViewController {
    var isReverse: Bool {
        return self.parent is ZZReaderPageViewController.ReverseItemViewController
    }
}
