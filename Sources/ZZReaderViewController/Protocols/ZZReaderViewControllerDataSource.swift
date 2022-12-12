//
//  ZZReaderViewController.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import Foundation

public protocol ZZReaderViewControllerDataSource: AnyObject {
    func numberOfSections(in readerViewController: ZZReaderViewController) -> Int
    func readerViewController(_ readerViewController: ZZReaderViewController, numberOfItemsInSection section: Int) -> Int
    func readerViewController(_ readerViewController: ZZReaderViewController, cellForItemAt indexPath: IndexPath) -> ZZReaderItemViewController
}
