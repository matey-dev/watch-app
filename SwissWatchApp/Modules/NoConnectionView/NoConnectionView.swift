//
//  NoConnectionView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

class NoConnectionView: BaseViewController {
    private var reachabilityManager: ReachabilityManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureReachabilityManager()
    }
    
    @IBAction func didTap(_ sender: Any) {
        if (self.reachabilityManager?.isReachable ?? false) {
            self.finish()
        }
    }
    
    private func configureReachabilityManager() {
        self.reachabilityManager = ReachabilityManager()
        self.reachabilityManager?.onChange = { [weak self] connected in
            if connected {
                self?.finish()
            }
        }
    }
    
    private func finish() {
        self.dismiss(animated: true, completion: nil)
    }
}
