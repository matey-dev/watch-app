//
//  CameraButton.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 24.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import LBTATools

class CameraButton: UIButton {
    let outImageView = UIImageView(image: #imageLiteral(resourceName: "camera_outline"), contentMode: .scaleAspectFit)
    let innerImageView = UIImageView(image: #imageLiteral(resourceName: "camera_inner"), contentMode: .scaleAspectFit)
    
    var action: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        insertSubview(outImageView, at: 0)
        insertSubview(innerImageView, aboveSubview: outImageView)
        outImageView.fillSuperview()
        innerImageView.fillSuperview(padding: .allSides(5))
        innerImageView.clipsToBounds = true
        self.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        self.innerImageView.transform = .init(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.layoutSubviews()
        }) { (_) in
            self.action?()
            self.innerImageView.transform = .identity
            UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut, animations: {

                self.layoutSubviews()
            }) { (_) in

            }
        }
    }
}
