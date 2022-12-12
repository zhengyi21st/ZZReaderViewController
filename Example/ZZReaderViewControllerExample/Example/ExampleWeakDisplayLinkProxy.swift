//
//  ExampleWeakDisplayLinkProxy.swift
//  ZZReaderViewControllerExample
//
//  Created by Ethan on 2022/11/8.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import Foundation
import QuartzCore

class ExampleWeakDisplayLinkProxy {

    var displaylink: CADisplayLink?
    var handle: (() -> Void)?

    init(_ handle: (() -> Void)?) {
        self.handle = handle
        displaylink = CADisplayLink(target: self, selector: #selector(updateHandle))
        displaylink?.add(to: RunLoop.current, forMode: .common)
    }

    @objc func updateHandle() {
        handle?()
    }

    func invalidate() {
        displaylink?.remove(from: RunLoop.current, forMode: .common)
        displaylink?.invalidate()
        displaylink = nil
    }
}
