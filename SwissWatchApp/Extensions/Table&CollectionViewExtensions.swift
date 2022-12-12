//
//  Table&CollectionViewExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

// MARK: -
// MARK: ReusableProtocol
protocol Reusable {
    static var identifier: String { get }
}

extension Reusable {
    static var identifier: String {
        return String(describing: self)
    }
}

// MARK: -
// MARK: NibLoadProtocol
protocol NibLoad {
    static var nibName: String { get }
}

extension NibLoad {
    static var nibName: String {
        return String(describing: self)
    }
}

// MARK: -
// MARK: UICollectionView
extension UICollectionViewCell: Reusable, NibLoad {}

extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: Bundle(for: T.self))
        self.register(nib, forCellWithReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T? {
        return self.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_: T.Type,
                                                      forIndexPath indexPath: IndexPath,
                                                      identifier: String? = nil) -> T? {
        return self.dequeueReusableCell(withReuseIdentifier: identifier ?? T.identifier,
                                        for: indexPath) as? T
    }
    
    func getVisibleCells<T: UICollectionViewCell>(_: T.Type) -> [T] {
        return self.visibleCells.compactMap { $0 as? T }
    }
    
    func getIndexPathOfVisibleCell() -> IndexPath? {
        let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return self.indexPathForItem(at: visiblePoint)
    }
    
    func setTopInset(value: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.contentInset = UIEdgeInsets(top: value, left: .zero, bottom: .zero, right: .zero)
        }
    }
    
    func selectHorizontalItem(indexPath: IndexPath) {
        self.selectItem(at: indexPath,
                        animated: true,
                        scrollPosition: .centeredHorizontally)
    }
}

// MARK: -
// MARK: UITableView
extension UITableViewCell: Reusable, NibLoad {}
extension UITableViewHeaderFooterView: Reusable, NibLoad {}

private let insetAnimationDuration: TimeInterval = 0.1

extension UITableView {
    func registerCellNib<T: UITableViewCell>(_: T.Type, identifier: String? = nil) {
        let nib = UINib(nibName: T.nibName, bundle: Bundle(for: T.self))
        self.register(nib, forCellReuseIdentifier: identifier ?? T.identifier)
    }
    
    func registerReusableHeaderViewNib<T: UITableViewHeaderFooterView>(_: T.Type) {
        let nib = UINib(nibName: T.nibName, bundle: Bundle(for: T.self))
        self.register(nib, forHeaderFooterViewReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_: T.Type,
                                                 forIndexPath indexPath: IndexPath,
                                                 identifier: String? = nil) -> T? {
        return self.dequeueReusableCell(withIdentifier: identifier ?? T.identifier,
                                        for: indexPath) as? T
    }
    
    func getVisibleCellsSubviews<T>(_: T.Type) -> [T] {
        let contentViews = self.visibleCells.flatMap { $0.contentView.subviews  }
        return contentViews.compactMap { $0 as? T }
    }
    
    func setInsets(top: CGFloat, bottom: CGFloat) {
        UIView.animate(withDuration: insetAnimationDuration) {
            self.contentInset = UIEdgeInsets(top: top, left: .zero, bottom: bottom, right: .zero)
        }
    }
}

extension UITableView {
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection: (self.numberOfSections - 1)) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func scrollToTop(animated: Bool = false) {
        guard self.numberOfRows(inSection: 0) > 0 else { return }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.setContentOffset(.zero, animated: animated)
//        }
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}
