//
//  AddLotItemThumbnial.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import LBTATools
import UIKit

class AddLotItemThumbnail: UIView {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.contentMode = image == nil ? .center : .scaleAspectFill
            
//            if (image == nil) {
//                imageView.image = placeholderImage
//            }
            
            if (image != nil) {
                self.isLoading = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.blurView.isHidden = false
                    self.deleteBtn.isHidden = false
                }) { (_) in
                    guard self.isLoading else { return }
                    self.addSubview(self.loadingSpinner)
                    self.loadingSpinner.centerInSuperview(size: CGSize(width: 24, height: 24))
                    self.loadingSpinner.rotate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        
                        self.loadingSpinner.stopRotation()
                        self.loadingSpinner.removeFromSuperview()
                        guard self.isLoading else { return }
                        self.cancelBtn.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            UIView.animate(withDuration: 0.2) {
                                self.cancelBtn.isHidden = true
                                self.blurView.isHidden = true
                            }
                        }
                    }
                }
            } else {
                self.isLoading = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.blurView.isHidden = true
                    self.deleteBtn.isHidden = true
                    self.cancelBtn.isHidden = true
                    self.blurView.isHidden = true
                    self.loadingSpinner.removeFromSuperview()
                }) { (_) in
                    
                }
            }
        }
    }
    
    var isLoading = false {
        didSet {
            self.imageView.isUserInteractionEnabled = !isLoading
        }
    }
    
    let blurView: UIVisualEffectView = {
        let bv = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.isUserInteractionEnabled = false
        return bv
    }()
    
    let loadingSpinner: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "loader-3-fill"), contentMode: .scaleAspectFit)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var placeholderImage = #imageLiteral(resourceName: "image_placeholder")
    
    var imageView = UIImageView(image: nil, contentMode: .center)
    
    var deleteAction: (() -> ())?
    
    let deleteBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(#imageLiteral(resourceName: "close-img"), for: .normal)
        return b
    }()
    
    let cancelBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setImage(#imageLiteral(resourceName: "close-line"), for: .normal)
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(imageView)
        addSubview(blurView)
        blurView.fillSuperview(padding: .allSides(4))
        addSubview(deleteBtn.withSize(CGSize(width: 18, height: 18)))
        imageView.fillSuperview(padding: .allSides(4))
        deleteBtn.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor)
        imageView.layer.cornerRadius = 6
        imageView.layer.borderColor = UIColor(hex: "#9FA5A9").withAlphaComponent(0.06).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(hex: "#F4F4F4")
        addSubview(cancelBtn.withSize(CGSize(width: 24, height: 24)))
        cancelBtn.centerInSuperview()
        cancelBtn.isHidden = true
        blurView.layer.cornerRadius = 6
        blurView.clipsToBounds = true
        
        deleteBtn.isHidden = true
        blurView.isHidden = true
    }
    
    private func setupAction() {
        deleteBtn.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteImage))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        cancelBtn.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
    }
    
    func clear() {
        self.image = nil
    }
    
    @objc func deleteImage() {
        clear()
        self.deleteAction?()
    }
}

extension UIView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopRotation() {
        self.layer.removeAllAnimations()
    }
}
