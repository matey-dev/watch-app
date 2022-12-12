//
//  ReuserIdentifer.swift
//  Chatterli
//
//  Created by FreeBird on 8/9/20.
//  Copyright © 2020 FreeBird. All rights reserved.
//

import Foundation
import UIKit

protocol ReuseIdentifiable {
    static func reuseIdentifier() -> String
}

extension ReuseIdentifiable {
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }
}

extension UICollectionViewCell:ReuseIdentifiable{}
extension UITableViewCell:ReuseIdentifiable{}
extension UITableViewHeaderFooterView: ReuseIdentifiable {}
extension UICollectionReusableView: ReuseIdentifiable {}

