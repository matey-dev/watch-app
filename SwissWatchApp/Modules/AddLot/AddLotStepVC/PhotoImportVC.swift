//
//  PhotoImportVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 17.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit

typealias PhotoImportVCAction = ((PhotoImportVCActionType) -> Void)

enum PhotoImportVCActionType {
    case cancel
    case library
    case camera
}


class PhotoImportVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var cameraBtn: UIButton!
    
    @IBOutlet weak var libraryBtn: UIButton!
    
    @IBAction func didTapBtn(sender: UIButton) {
        if sender == cameraBtn {
            self.onAction?(.camera)
        } else if sender == libraryBtn {
            self.onAction?(.library)
        } else {
            self.onAction?(.cancel)
        }
        dismissSemiModalView()
    }
    
    
    var onAction: PhotoImportVCAction?
    func onAction(_ callback: PhotoImportVCAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.cornerRadius = 12
    }
}
