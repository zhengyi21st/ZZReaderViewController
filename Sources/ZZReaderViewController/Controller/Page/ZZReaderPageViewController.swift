//
//  ZZReaderPageViewController.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/2.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

open class ZZReaderPageViewController: UIViewController, ZZReaderViewController {

    public weak var dataSource: ZZReaderViewControllerDataSource?

    public weak var delegate: ZZReaderViewControllerDelegate?

    public var expectedIndexPath: IndexPath?

    public var currentViewController: ZZReaderItemViewController? {
        return pageVC.viewControllers?.first as? ZZReaderItemViewController
    }

    public var isProbablyActiveInScroll: Bool {
        return isScrollingToItem || isTransitioning || isTracking
    }

    private var isScrollingToItem: Bool = false

    private var isTransitioning: Bool = false

    private var isTracking: Bool {
        let state = pageVC.view.gestureRecognizers?.first(where: { $0 is UIPanGestureRecognizer })?.state
        var flag = false
        pageVC.view.subviews.forEach {
            if $0.layer.name == nil && !flag {
                flag = true
            }
        }
       return flag || state == .changed
    }

    private var scrollView: UIScrollView? {
        for view in pageVC.view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }

    private var isFirstLayout: Bool = true
    
    public lazy var pageVC: UIPageViewController = {
        $0.dataSource = self
        $0.delegate = self
        $0.isDoubleSided = true
        $0.setViewControllers([UIViewController()], direction: .forward, animated: false)
        return $0
    }(UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil))

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        if let currentViewController = currentViewController {
            return currentViewController.preferredStatusBarStyle
        }
        return super.preferredStatusBarStyle
    }

    override open var prefersStatusBarHidden: Bool {
        if let currentViewController = currentViewController {
            return currentViewController.prefersStatusBarHidden
        }
        return super.prefersStatusBarHidden
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstLayout {
            isFirstLayout = false
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture)))
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
        disableDefaultTapGesture()
    }

    /// 触发已经滚动位置项代理
    private func updateDidScrollItemIfNeeded() {
        if let indexPath = currentViewController?.indexPath {
            delegate?.readerViewController(self, didScrollToItemAt: indexPath)
        }
    }
}

// MARK: - Gesture

extension ZZReaderPageViewController {

    /// 禁用默认点击手势
    private func disableDefaultTapGesture() {
        for recognizer in pageVC.gestureRecognizers {
            if recognizer is UITapGestureRecognizer {
                recognizer.isEnabled = false
            }
        }
    }

    /// 响应点击手势
    @objc private func handleTapGesture(tap: UITapGestureRecognizer) {
        guard !isTransitioning else { return }
        let location = tap.location(in: view)
        if location.x <= view.bounds.width / 3 {
            // 点击屏幕左侧
            delegate?.readerViewController(self, didTapAt: .left)
        } else if location.x >= view.bounds.width / 3 && location.x <= 2 * view.bounds.width / 3 {
            // 点击屏幕中级
            delegate?.readerViewController(self, didTapAt: .center)
        } else {
            // 点击屏幕右侧
            delegate?.readerViewController(self, didTapAt: .right)
        }
    }

    /// 响应平移手势
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        guard !isTracking else { return }
        let translation = pan.translation(in: view)
        let velocity = pan.velocity(in: view)
        // 判断是否翻页溢出
        if abs(translation.x) > abs(translation.y) && pan.isEnabled == true {
            if translation.x < 0 || velocity.x < 0 {
                if let currentIndexPath = currentViewController?.indexPath, indexPath(after: currentIndexPath) == nil {
                    pan.isEnabled = false
                    delegate?.readerViewController(self, didOverRangeAt: .end)
                    pan.isEnabled = true
                }
            } else {
                if let currentIndexPath = currentViewController?.indexPath, indexPath(before: currentIndexPath) == nil {
                    pan.isEnabled = false
                    delegate?.readerViewController(self, didOverRangeAt: .front)
                    pan.isEnabled = true
                }
            }
        }
    }
}

// MARK: - Operation

extension ZZReaderPageViewController {

    public func reloadData() {
        if let dataSource = self.dataSource {
            var targetIndexPath = expectedIndexPath ?? currentViewController?.indexPath
            if targetIndexPath == nil && indexPathExists(at: IndexPath(item: 0, section: 0)) {
                targetIndexPath = IndexPath(item: 0, section: 0)
            }
            if let targetIndexPath = targetIndexPath {
                let viewController = dataSource.readerViewController(self, cellForItemAt: targetIndexPath)
                pageVC.setViewControllers([viewController], direction: .forward, animated: false) { _ in
                    self.updateDidScrollItemIfNeeded()
                    self.expectedIndexPath = nil
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            } else {
                pageVC.setViewControllers([UIViewController()], direction: .forward, animated: false) { _ in
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.expectedIndexPath = nil
                }
            }
        } else {
            pageVC.setViewControllers([UIViewController()], direction: .forward, animated: false) { _ in
                self.setNeedsStatusBarAppearanceUpdate()
                self.expectedIndexPath = nil
            }
        }
    }
    
    public func reloadDataWithInsert(indexPaths: [IndexPath]) {
        reloadData()
    }

    public func scrollToItem(at indexPath: IndexPath, animated: Bool) {
        guard indexPathExists(at: indexPath), let dataSource = self.dataSource else {
            // indexPath不合理或数据源不存在，跳转失败
            return
        }
        if let currentIndexPath = currentViewController?.indexPath, currentIndexPath != indexPath {
            // 当前预期方向
            let viewController = dataSource.readerViewController(self, cellForItemAt: indexPath)
            let reverseViewController = ReverseItemViewController(viewController: dataSource.readerViewController(self, cellForItemAt: indexPath))
            let direction: UIPageViewController.NavigationDirection = currentIndexPath < indexPath ? .forward : .reverse
            isScrollingToItem = true
            self.pageVC.setViewControllers([viewController, reverseViewController], direction: direction, animated: animated) { _ in
                self.isScrollingToItem = false
                self.updateDidScrollItemIfNeeded()
                self.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            // 无需要执行动画
            let viewController = dataSource.readerViewController(self, cellForItemAt: indexPath)
            let reverseViewController =  ReverseItemViewController(viewController: dataSource.readerViewController(self, cellForItemAt: indexPath))
            pageVC.setViewControllers([viewController, reverseViewController], direction: .forward, animated: false) { _ in
                self.setNeedsStatusBarAppearanceUpdate()
                self.updateDidScrollItemIfNeeded()
            }
        }
    }
}

// MARK: - UIPageViewControllerDelegate && UIPageViewControllerDataSource

extension ZZReaderPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let dataSource = self.dataSource else { return nil }
        if let indexPath = indexPath(before: (viewController as? ZZReaderItemViewController)?.indexPath) {
            return ReverseItemViewController(viewController: dataSource.readerViewController(self, cellForItemAt: indexPath))
        } else if let indexPath = (viewController as? ReverseItemViewController)?.viewController.indexPath {
            return dataSource.readerViewController(self, cellForItemAt: indexPath)
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let dataSource = self.dataSource else { return nil }
        if let indexPath = (viewController as? ZZReaderItemViewController)?.indexPath {
            return ReverseItemViewController(viewController: dataSource.readerViewController(self, cellForItemAt: indexPath))
        } else if let indexPath = indexPath(after: (viewController as? ReverseItemViewController)?.viewController.indexPath) {
            return dataSource.readerViewController(self, cellForItemAt: indexPath)
        }
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        isTransitioning = true
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.isTransitioning = false
        self.setNeedsStatusBarAppearanceUpdate()
        self.updateDidScrollItemIfNeeded()
    }
}
