//
//  CarouselVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 17.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import iCarousel
//swiftlint:disable all
class CarouselVC: UIViewController, iCarouselDelegate, iCarouselDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    let carousel = iCarousel(frame: .zero)
    
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
    
    func setupView() {
        
        carousel.dataSource = self
        carousel.type = .rotary
        carousel.isPagingEnabled = true
//        carousel.perspective = -0.002
        carousel.clipsToBounds = false
        carousel.layer.borderColor = UIColor.red.cgColor
        carousel.layer.borderWidth = 2
        carousel.delegate = self
        carousel.clipsToBounds = false
        carousel.type = .custom
        view.addSubview(carousel)
//        carousel.translatesAutoresizingMaskIntoConstraints = false
//        carousel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 200, left: 12, bottom: 0, right: 12))
//        carousel.heightAnchor.constraint(equalTo: carousel.widthAnchor, multiplier: 245 / 351).isActive = true
        carousel.frame = CGRect(origin: CGPoint(x: 12, y: 200), size: CGSize(width: 351, height: 245))
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return rendermode == .local ? images.count : imageUrls.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let imageView: UIImageView
        
        if view != nil {
            imageView = view as! UIImageView
        } else {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 319, height: 245))
            imageView.layer.cornerRadius = 6
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
//            imageView.layer.borderColor = UIColor.random().cgColor
//            imageView.layer.borderWidth = 2
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 319, height: 245))
            label.text = String(index)
            label.textColor = .red
            label.textAlignment = .center
            imageView.addSubview(label)
            label.center = imageView.center
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
            return 0.5 * value
        case .arc:
            return CGFloat.pi * 1
        case .radius:
            return 1 * value
        case .visibleItems:
            return 5
        default:
            return value
        }
        
    }
    

//    func carousel(
//        _ carousel: iCarousel,
//        itemTransformForOffset offset: CGFloat,
//        baseTransform transform: CATransform3D
//    ) -> CATransform3D {
//        let x = CATransform3DTranslate(
//            transform, // base
//            offset * 1.1 * carousel.itemWidth, // x
//            0, // y
//            0 // z
//        )
//
//        return CATransform3DScale(x, offset * 1.0 * carousel.itemWidth, offset * 1.0 * carousel.itemWidth, offset * 1.0 * carousel.itemWidth)
//        let distance : Float = -50
//        let z = fminf(1.0, fabsf(Float(offset))) * distance
////        return CATransform3DTranslate(transform, 0.2 * offset * carousel.itemWidth, 0.0, CGFloat(z))
//        let transform = CATransform3DTranslate(transform, 0.2 * offset * carousel.itemWidth, 0.0, CGFloat(z))
        
//        let MAX_SCALE:CGFloat = 1.0 //max scale of center item
//        let MAX_SHIFT:CGFloat = -carousel.itemWidth //amount to shift items to keep spacing the same
//
//        let shift:CGFloat = CGFloat(fminf(1.0, fmaxf(-1.0, Float(offset))))
////        let scale:CGFloat = 1.0 + (1.0 - abs(shift)) * (MAX_SCALE - 1.0)
//        let scale:CGFloat = 1.0 + (1.0 - abs(shift)) * (MAX_SCALE - 1.0)
//        let distance : Float = -50
//        let z = fminf(1.0, fabsf(Float(offset))) * distance
//        let transform = CATransform3DTranslate(transform, 0.1 * offset * carousel.itemWidth, 0.0, CGFloat(z))
//        let transform = CATransform3DTranslate(transform, offset * carousel.itemWidth + shift * MAX_SHIFT, 0.0, 0)
//        return CATransform3DScale(transform, 1, scale, 1)
//    }
    
    
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
//        let count: CGFloat = 6.0
//        let spacing: CGFloat = 1.0
//        let arc: CGFloat = .pi * 0.5
//        let itemWidth: CGFloat = 319.0
//        let radius: CGFloat = max(itemWidth * spacing / 2.0, itemWidth * spacing / 2.0 / tan(arc / 2.0 / count))
//        let angle = offset / count * arc
        let shift:CGFloat = CGFloat(fminf(1.0, fmaxf(-1.0, abs(Float(offset)))))
        return CATransform3DTranslate(transform, CGFloat(abs(Float(offset)) * 8), 0.0, 0)
    }
    
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct CarouselVCViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> CarouselVC {
        return CarouselVC()
    }
    
    func updateUIViewController(_ uiViewController: CarouselVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct CarouselVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            CarouselVCViewRepresentable().previewDevice(PreviewDevice(stringLiteral: "iPhone X"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }
        
    }
}
#endif
//swiftlint:disable all
