//
//  ExampleNavigationController.swift
//  ZZReaderViewControllerExample
//
//  Created by Ethan on 2022/11/3.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

class ExampleNavigationController: UINavigationController {

    open override var childForStatusBarStyle: UIViewController? {
        topViewController
    }

    open override var childForStatusBarHidden: UIViewController? {
        topViewController
    }
    
}
