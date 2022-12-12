//
//  ZZReaderCollectionViewController.swift
//  ZZReaderViewController
//
//  Created by Ethan on 2022/11/8.
//  Copyright © 2022 ZZReaderViewController. All rights reserved.
//

import UIKit

open class ZZReaderCollectionViewController: UIViewController, ZZReaderViewController {

    public enum ScrollStyle {
        // 水平平移
        case translationHorizontally
        // 垂直平移
        case translationVertically
        // 水平滚动
        case scrollHorizontally
        // 垂直滚动
        case scrollVertically
    }

    public weak var dataSource: ZZReaderViewControllerDataSource?

    public weak var delegate: ZZReaderViewControllerDelegate?

    public var currentViewController: ZZReaderItemViewController? {
        return (collectionView.visibleCells.sorted {
            let size0 = $0.convert($0.bounds, to: view).intersection(view.bounds).size
            let size1 = $1.convert($1.bounds, to: view).intersection(view.bounds).size
            return  size0.width * size0.height > size1.width * size1.height
        }.first as? ItemCell)?.viewController
    }

    public var isProbablyActiveInScroll: Bool {
        return isScrollingToItem || isScrolling
    }

    public var expectedIndexPath: IndexPath?

    private(set) public var scrollStyle: ScrollStyle = .translationHorizontally

    private var isScrolling: Bool = false

    private var isScrollingToItem: Bool = false

    private var isFirstLayout: Bool = true

    private var isNeedOverRange: Bool = false

    private lazy var panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))

    private lazy var tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))

    private var scrollDirection: UICollectionView.ScrollDirection {
        return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == .horizontal ? .horizontal : .vertical
    }

    private lazy var collectionView: UICollectionView = {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.register(ItemCell.self, forCellWithReuseIdentifier: "cellIdentifier")
        $0.contentInsetAdjustmentBehavior = .never
        $0.isPagingEnabled = true
        $0.bounces = false
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: {
        $0.scrollDirection = .horizontal
        return $0
    }(UICollectionViewFlowLayout())))

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        if isFirstLayout {
            isFirstLayout = false
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        panGR.delegate = self
        view.addGestureRecognizer(panGR)
        view.addGestureRecognizer(tapGR)
        collectionView.layoutIfNeeded()
    }

    public func set(scrollStyle: ScrollStyle) {
        self.scrollStyle = scrollStyle
        switch scrollStyle {
        case .translationHorizontally:
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
            collectionView.isPagingEnabled = true
        case .translationVertically:
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
            collectionView.isPagingEnabled = true
        case .scrollHorizontally:
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
            collectionView.isPagingEnabled = false
        case .scrollVertically:
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .vertical
            collectionView.isPagingEnabled = false
        }
    }

    /// 触发已经滚动位置项代理
    private func updateDidScrollItemIfNeeded() {
        if let indexPath = currentViewController?.indexPath {
            delegate?.readerViewController(self, didScrollToItemAt: indexPath)
        }
    }
}

// MARK: - Gesture

extension ZZReaderCollectionViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGR {
            return true
        }
        return false
    }

    /// 响应点击手势
    @objc private func handleTapGesture(tap: UITapGestureRecognizer) {
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
        if scrollDirection == .horizontal {
            handlePanGestureHorizontally(pan: pan)
        } else {
            handlePanGestureVertically(pan: pan)
        }
    }

    /// 响应水平平移手势
    @objc func handlePanGestureHorizontally(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        let velocity = pan.velocity(in: view)
        if pan.state == .began {
            if collectionView.contentOffset.x <= 0 && (translation.x > 0 || velocity.x > 0) {
                isNeedOverRange = true
            } else if collectionView.contentOffset.x >= collectionView.contentSize.width - collectionView.bounds.width && (translation.x < 0 || velocity.x < 0) {
                isNeedOverRange = true
            }
        } else if pan.state == .ended || pan.state == .cancelled {
            isNeedOverRange = false
        }
        // 判断是否翻页溢出
        if abs(translation.x) > abs(translation.y) && pan.isEnabled == true {
            if translation.x < 0 || velocity.x < 0 {
                if isNeedOverRange, let currentIndexPath = currentViewController?.indexPath, indexPath(after: currentIndexPath) == nil {
                    pan.isEnabled = false
                    delegate?.readerViewController(self, didOverRangeAt: .end)
                    pan.isEnabled = true
                }
            } else {
                if isNeedOverRange, let currentIndexPath = currentViewController?.indexPath, indexPath(before: currentIndexPath) == nil {
                    pan.isEnabled = false
                    delegate?.readerViewController(self, didOverRangeAt: .front)
                    pan.isEnabled = true
                }
            }
        }
    }

    /// 响应垂直平移手势
    @objc func handlePanGestureVertically(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        let velocity = pan.velocity(in: view)
        if pan.state == .began {
            if collectionView.contentOffset.y <= 0 && (translation.y > 0 || velocity.y > 0) {
                isNeedOverRange = true
            } else if collectionView.contentOffset.y >= collectionView.contentSize.height - collectionView.bounds.height && (translation.y < 0 || velocity.y < 0) {
                isNeedOverRange = true
            }
        } else if pan.state == .ended || pan.state == .cancelled {
            isNeedOverRange = false
        }
        // 判断是否翻页溢出
        if abs(translation.y) > abs(translation.x) && pan.isEnabled == true {
            if translation.y < 0 || velocity.y < 0 {
                if isNeedOverRange, let currentIndexPath = currentViewController?.indexPath, indexPath(after: currentIndexPath) == nil {
                    pan.isEnabled = false
                    delegate?.readerViewController(self, didOverRangeAt: .end)
                    pan.isEnabled = true
                }
            } else {
                if isNeedOverRange, let currentIndexPath = currentViewController?.indexPath, indexPath(before: currentIndexPath) == nil {
                    pan.isEnabled = false
                    delegate?.readerViewController(self, didOverRangeAt: .front)
                    pan.isEnabled = true
                }
            }
        }
    }

}

// MARK: - Operation

extension ZZReaderCollectionViewController {

    public func reloadData() {
        collectionView.reloadData()
        var targetIndexPath = expectedIndexPath ?? currentViewController?.indexPath
        if targetIndexPath == nil && indexPathExists(at: IndexPath(item: 0, section: 0)) {
            targetIndexPath = IndexPath(item: 0, section: 0)
        }
        if let targetIndexPath = targetIndexPath {
            collectionView.scrollToItem(at: targetIndexPath, at: scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically, animated: false)
            collectionView.layoutIfNeeded()
            updateDidScrollItemIfNeeded()
            setNeedsStatusBarAppearanceUpdate()
            expectedIndexPath = nil
        }
        collectionView.layoutIfNeeded()
        updateDidScrollItemIfNeeded()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    public func reloadDataWithInsert(indexPaths: [IndexPath]) {
        let currentIndexPath = currentViewController?.indexPath
        collectionView.reloadData()
        if let currentIndexPath = currentIndexPath {
            let headIndexPaths = indexPaths.filter { $0.section <= currentIndexPath.section || ($0.section == currentIndexPath.section && $0.item <= currentIndexPath.item) }
            if scrollDirection == .horizontal {
                collectionView.contentOffset.x += CGFloat(headIndexPaths.count) * collectionView.bounds.width
            } else {
                collectionView.contentOffset.y += CGFloat(headIndexPaths.count) * collectionView.bounds.height
            }
        }
        collectionView.layoutIfNeeded()
        updateDidScrollItemIfNeeded()
        setNeedsStatusBarAppearanceUpdate()
    }

    public func scrollToItem(at indexPath: IndexPath, animated: Bool) {
        guard !isScrolling else {
            // 正在滚动中
            return
        }
        guard indexPathExists(at: indexPath) else {
            // indexPath不合理
            return
        }
        isScrollingToItem = true
        expectedIndexPath = indexPath
        collectionView.isScrollEnabled = false
        collectionView.isPagingEnabled = true
        collectionView.scrollToItem(at: indexPath, at: scrollDirection == .horizontal ? .centeredHorizontally : .top, animated: true)
    }
}

// MARK: - UICollectionViewDataSource &  UICollectionViewDelegateFlowLayout

extension ZZReaderCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.readerViewController(self, numberOfItemsInSection: section) ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! ItemCell
        if let dataSource = self.dataSource {
            cell.update(viewController: dataSource.readerViewController(self, cellForItemAt: indexPath))
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UIScrollViewDelegate

extension ZZReaderCollectionViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isScrollingToItem {
            updateDidScrollItemIfNeeded()
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            isScrolling = false
            updateDidScrollItemIfNeeded()
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
        updateDidScrollItemIfNeeded()
        setNeedsStatusBarAppearanceUpdate()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if currentViewController?.indexPath == expectedIndexPath {
            expectedIndexPath = nil
            collectionView.isScrollEnabled = true
            isScrollingToItem = false
            collectionView.isPagingEnabled = scrollStyle == .translationVertically || scrollStyle == .translationHorizontally
            updateDidScrollItemIfNeeded()
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}
