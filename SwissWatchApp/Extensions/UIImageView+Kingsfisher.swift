//
//  UIImageView+Kingsfisher.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/14/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import Kingfisher

private let transitionFade: TimeInterval = 0.4

extension UIImageView {
    enum NameInAssets: String {
        case none = ""
        case product = "no_image"
    }
    
    func setImage(withUrl url: URL?, placeholderName: NameInAssets = .none) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url,
                         placeholder: url.isNil ? UIImage(named: placeholderName.rawValue) : nil,
                         options: [
//                            .transition(.fade(0.2)),
                            .progressiveJPEG(.default)])
    }
    
//    func setImage(withUrl url: URL?, placeholderName: NameInAssets = .none) {
//        self.kf.setImage(with: url,
//                         placeholder: url.isNil ? UIImage(named: placeholderName.rawValue) : nil,
//                         options: [.transition(.fade(transitionFade))
//                            ,.processor(DownsamplingImageProcessor(size: self.bounds.size))
//                            ,.scaleFactor(UIScreen.main.scale)
//                            ,.backgroundDecode
//            ])
//    }
}
