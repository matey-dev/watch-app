//
//  VerticallyCenteredTextView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/16/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}
