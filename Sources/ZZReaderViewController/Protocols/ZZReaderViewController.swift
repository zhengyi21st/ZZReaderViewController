//
//  ZZReaderViewController.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

public protocol ZZReaderViewController: UIViewController {

    var dataSource: ZZReaderViewControllerDataSource? { get set }

    var delegate: ZZReaderViewControllerDelegate? { get set }

    var currentViewController: ZZReaderItemViewController? { get }

    var isProbablyActiveInScroll: Bool { get }

    var expectedIndexPath: IndexPath? { get set }

    func reloadData()
    
    func reloadDataWithInsert(indexPaths: [IndexPath])

    func scrollToItem(at indexPath: IndexPath, animated: Bool)
}

public extension ZZReaderViewController {

    func indexPathExists(at indexPath: IndexPath?) -> Bool {
        guard let indexPath = indexPath, let dataSource = self.dataSource else { return false }
        return indexPath.item >= 0 && indexPath.section >= 0 && indexPath.section < dataSource.numberOfSections(in: self) && dataSource.numberOfSections(in: self) > 0 && indexPath.item < dataSource.readerViewController(self, numberOfItemsInSection: indexPath.section) && dataSource.readerViewController(self, numberOfItemsInSection: indexPath.section) > 0
    }

    func indexPath(after indexPath: IndexPath?) -> IndexPath? {
        guard let indexPath = indexPath else { return nil }
        if indexPathExists(at: IndexPath(item: indexPath.item + 1, section: indexPath.section)) {
            return IndexPath(item: indexPath.item + 1, section: indexPath.section)
        } else if indexPathExists(at: IndexPath(item: 0, section: indexPath.section + 1)) {
            return IndexPath(item: 0, section: indexPath.section + 1)
        }
        return nil
    }

    func indexPath(before indexPath: IndexPath?) -> IndexPath? {
        guard let indexPath = indexPath else { return nil }
        if indexPathExists(at: IndexPath(item: indexPath.item - 1, section: indexPath.section)) {
            return IndexPath(item: indexPath.item - 1, section: indexPath.section)
        } else if let dataSource = dataSource, indexPath.section - 1 >= 0, indexPathExists(at: IndexPath(item: dataSource.readerViewController(self, numberOfItemsInSection: indexPath.section - 1) - 1, section: indexPath.section - 1)) {
            return IndexPath(item: dataSource.readerViewController(self, numberOfItemsInSection: indexPath.section - 1) - 1, section: indexPath.section - 1)
        }
        return nil
    }

    func scrollToPreviousItem(animated: Bool) {
        guard let currentIndexPath = expectedIndexPath ?? currentViewController?.indexPath else {
            return
        }
        guard let indexPath = indexPath(before: currentIndexPath) else {
            delegate?.readerViewController(self, didOverRangeAt: .front)
            return
        }
        scrollToItem(at: indexPath, animated: animated)
    }

    func scrollToNextItem(animated: Bool) {
        guard let currentIndexPath = expectedIndexPath ?? currentViewController?.indexPath else {
            return
        }
        guard let indexPath = indexPath(after: currentIndexPath) else {
            delegate?.readerViewController(self, didOverRangeAt: .end)
            return
        }
        scrollToItem(at: indexPath, animated: animated)
    }
}
