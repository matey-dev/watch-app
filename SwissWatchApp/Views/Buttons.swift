//
//  Buttons.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/18/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class GeneralButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.setup()
    }
    
    private func setup() {
        self.tintColor = .clear
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4.0
        self.titleLabel?.font = Fonts.System.semibold(size: 17.0)
        
        self.set(active: true)
    }
    
    func set(active: Bool) {
        self.backgroundColor = active ? Colors.black_90opacity : Colors.black_8opacity
        let titleColor = active ? Colors.white : Colors.black_40opacity
        self.setTitleColor(titleColor, for: .normal)
    }
}
