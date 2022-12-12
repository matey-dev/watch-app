//
//  AddLotProgressView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class AddLotProgressView: UIView {
    private var progress: Float = 0.0
    private var progressView: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addProgressView()
        self.addDotOnProgressView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addProgressView()
        self.addDotOnProgressView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateWithProgress(_ progress: Float) {
        self.updateUI(with: progress)
    }
}

private extension AddLotProgressView {
    func addProgressView() {
        let progressView = UIView()
        self.progressView = progressView
        self.addSubview(progressView)
    }
    
    func addDotOnProgressView() {
        let dotView = UIView()
        self.progressView?.addSubview(dotView)
    }
    
    func updateUI(with progress: Float) {
        self.backgroundColor = UIColor(hex: "#F2F2F2")
        self.layer.masksToBounds = true
        let cornerRadius = self.frame.size.height / 2
        self.rounded(cornerRadius: cornerRadius)
        
        self.progressView.map { pv in
            pv.frame = self.bounds
            pv.layer.masksToBounds = true
            let cr = pv.frame.size.height / 2
            pv.backgroundColor = UIColor(hex: "#101E29")
            pv.contentMode = .scaleAspectFill
            
            self.setProgress(progress)
            pv.rounded(cornerRadius: cr)
        }
    }
    
    func setProgress(_ progress: Float) {
        guard progress >= 0, progress <= 1.0 else { return }
        self.progress = progress
        guard let frame = self.progressView?.frame else { return }
        let width = self.frame.width
        let newFrame = CGRect(x: frame.origin.x,
                              y: frame.origin.y,
                              width: width * CGFloat(progress),
                              height: frame.size.height)
        self.progressView?.frame = newFrame
    }
}
