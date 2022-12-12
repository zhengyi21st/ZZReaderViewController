//
//  ExampleViewController.swift
//  ZZReaderViewControllerExample
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit
import ZZReaderViewController
import ZZComponents

class ExampleViewController<T: ZZReaderViewController>: UIViewController, ZZReaderViewControllerDelegate, ZZReaderViewControllerDataSource {
    
    let readerVC = T.init()

    let statusView = ExampleStatusView()

    var list = [[UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString]]
    
    var displayLinkProxy: ExampleWeakDisplayLinkProxy?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        readerVC.view.frame = view.bounds
    }
    
    deinit {
        removeDisplayLink()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let currentViewController = readerVC.currentViewController {
            return currentViewController.preferredStatusBarStyle
        }
        return super.preferredStatusBarStyle
    }

    override var prefersStatusBarHidden: Bool {
        if let currentViewController = readerVC.currentViewController {
            return currentViewController.prefersStatusBarHidden
        }
        return super.prefersStatusBarHidden
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        readerVC.delegate = self
        readerVC.dataSource = self
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Action", style: .plain, target: self, action: #selector(handleAction))
        addChild(readerVC)
        view.addSubview(readerVC.view)
        view.addSubview(statusView)
        readerVC.didMove(toParent: self)
        statusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16.0),
            statusView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0),
        ])
        addDisplayLink()
        readerVC.reloadData()
    }
    
    private func addDisplayLink() {
        displayLinkProxy = .init({ [weak self] in
            guard let self = self else { return }
            self.statusView.updateActiveScroll(self.readerVC.isProbablyActiveInScroll)
        })
    }
    
    private func removeDisplayLink() {
        displayLinkProxy?.invalidate()
        displayLinkProxy = nil
    }

    @objc func handleAction() {
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        alert.popoverPresentationController?.permittedArrowDirections = .any
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Previous", style: .default, handler: { _ in
            self.readerVC.scrollToPreviousItem(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Next", style: .default, handler: { _ in
            self.readerVC.scrollToNextItem(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Insert 10 page", style: .default, handler: { _ in
            let items = [UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString, UUID().uuidString]
            self.list.insert(items, at: 0)
            let indexPaths = items.enumerated().map { IndexPath(item: $0.offset, section: 0) }
            self.readerVC.reloadDataWithInsert(indexPaths: indexPaths)
        }))
        present(alert, animated: true)
    }

    // MARK: - ZZReaderViewControllerDelegate && ZZReaderViewControllerDataSource

    func numberOfSections(in readerViewController: ZZReaderViewController) -> Int {
        return list.count
    }

    func readerViewController(_ readerViewController: ZZReaderViewController, numberOfItemsInSection section: Int) -> Int {
        return list[section].count
    }

    func readerViewController(_ readerViewController: ZZReaderViewController, cellForItemAt indexPath: IndexPath) -> ZZReaderItemViewController {
        return ExampleItemViewController(indexPath: indexPath)
    }

    func readerViewController(_ readerViewController: ZZReaderViewController, didScrollToItemAt indexPath: IndexPath) {
        statusView.updateIndexPath(indexPath)
        statusView.updateIdentity(list[indexPath.section][indexPath.item])
    }

    func readerViewController(_ readerViewController: ZZReaderViewController, didTapAt position: ZZReaderViewTapPosition) {
        guard readerVC is ZZReaderPageViewController || (readerVC as? ZZReaderCollectionViewController)?.scrollStyle == .translationHorizontally else { return }
        if position == .left {
            readerVC.scrollToPreviousItem(animated: true)
        } else if position == .right {
            readerVC.scrollToNextItem(animated: true)
        }
    }
    func readerViewController(_ readerViewController: ZZReaderViewController, didOverRangeAt range: ZZReaderViewRangePosition) {
        if range == .front {
            ZZToast.show("已到第一页")
        } else {
            ZZToast.show("已到最后一页")
        }
    }
}
