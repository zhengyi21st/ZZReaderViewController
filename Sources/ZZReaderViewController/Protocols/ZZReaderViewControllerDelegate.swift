//
//  ZZReaderViewControllerDelegate.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import Foundation

public protocol ZZReaderViewControllerDelegate: AnyObject {
    func readerViewController(_ readerViewController: ZZReaderViewController, didScrollToItemAt indexPath: IndexPath)
    func readerViewController(_ readerViewController: ZZReaderViewController, didTapAt position: ZZReaderViewTapPosition)
    func readerViewController(_ readerViewController: ZZReaderViewController, didOverRangeAt range: ZZReaderViewRangePosition)
}
