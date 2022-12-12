//
//  NotificationVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 20.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit

class NotificationVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        
    }
    
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
