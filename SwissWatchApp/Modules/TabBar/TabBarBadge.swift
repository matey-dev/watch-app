//
//  TabBarBadge.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class TabBarBadge: UILabel {
    var identifier: String = String(describing: TabBarBadge.self)
    
    private func identifier(for index: Int) -> String {
        return "\(String(describing: TabBarBadge.self))-\(index)"
    }
    
    convenience init(for index: Int) {
        self.init()
        identifier = identifier(for: index)
    }
    
    func hasIdentifier(for index: Int) -> Bool {
        return identifier == identifier(for: index)
    }
}

struct TabBarBadgeStyle {
    var backgroundColor: UIColor = UIColor.blue
    var textColor: UIColor = .white
    
    var size: CGSize = .init(width: 25, height: 25)
    var centerOffset: CGPoint = .init(x: -12.5, y: -8)
    
    var font: UIFont = UIFont.systemFont(ofSize: 14.0)
    
    var borderWidth: CGFloat = 6.0
    var borderColor: UIColor = .white
}
