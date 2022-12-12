//
//  CarouselView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 23.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import iCarousel

//swiftlint:disable all
class CarouselView: UIView, iCarouselDelegate, iCarouselDataSource {
    
    let carousel = iCarousel(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var images: [UIImage] = [#imageLiteral(resourceName: "Прямо"), #imageLiteral(resourceName: "Прямо"), #imageLiteral(resourceName: "Прямо"), #imageLiteral(resourceName: "Прямо"), #imageLiteral(resourceName: "Прямо"), #imageLiteral(resourceName: "Прямо")] {
        didSet {
            rendermode = .local
        }
    }
    
    enum RenderMode {
        case local
        case remote
    }
    
    var rendermode: RenderMode = .local {
        didSet {
            carousel.reloadData()
        }
    }
    
    var imageUrls: [URL] = [] {
        didSet {
            rendermode = .remote
        }
    }
    
    var selectImageAction: ((UIImage) -> ())?
    var selectImageUrlAction: ((URL) -> ())?
    var selectedItemAction: ((Int) -> ())?
    
    func setupView() {
        carousel.dataSource = self
        carousel.type = .rotary
//        carousel.isPagingEnabled = true
        carousel.delegate = self
        carousel.decelerationRate = 0.5
        carousel.clipsToBounds = true
        carousel.isScrollEnabled = false
        addSubview(carousel)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        carousel.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        carousel.addGestureRecognizer(swipeLeft)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCarousel))
        carousel.addGestureRecognizer(tap)
    }
    
    @objc func didTapCarousel() {
        if rendermode == .local {
            let image = images[carousel.currentItemIndex]
            selectImageAction?(image)
        } else {
            let url = imageUrls[carousel.currentItemIndex]
            selectImageUrlAction?(url)
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case .right:
                var prevIndex = carousel.currentItemIndex - 1
                if prevIndex < 0 { prevIndex = carousel.numberOfItems - 1}
                carousel.scrollToItem(at: prevIndex, animated: true)
            case .down:
                print("Swiped down")
            case .left:
                var nextIndex = carousel.currentItemIndex + 1
                if nextIndex >= carousel.numberOfItems { nextIndex = 0}
                carousel.scrollToItem(at: nextIndex, animated: true)
                
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        carousel.frame = bounds
        carousel.reloadData()
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return rendermode == .local ? images.count : imageUrls.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let imageView: UIImageView
        
        if view != nil {
            imageView = view as! UIImageView
        } else {
            let width = bounds.width - 32
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width * 245 / 351))
            imageView.layer.cornerRadius = 6
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = .black
        }
        if rendermode == .local {
            imageView.image = images[index]
        } else {
            imageView.setImage(withUrl: imageUrls[index])
        }
        return imageView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .spacing:
            //            return 0.3 * value
            return 1 * value
        case .arc:
            return CGFloat.pi * 2
        case .radius:
            return 1 * value
        case .visibleItems:
            return 5
        default:
            return value
        }
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
//        if rendermode == .local {
//            let image = images[index]
//            selectImageAction?(image)
//        } else {
//            let url = imageUrls[index]
//            selectImageUrlAction?(url)
//        }
        selectedItemAction?(index)
    }
}

