//
//  BaseTextField.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class BaseTextField: UITextField {
    var textDidChangeAction: ((String) -> Void)?
    
    private var inFocus = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentVerticalAlignment = .center
        //self.tintColor =
        self.addTarget(self, action: #selector(self.editDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(self.editDidBegin), for: .editingDidBegin)
        self.addTarget(self, action: #selector(self.editDidEnd), for: .editingDidEnd)
    }
    
    @objc func editDidChange() {
        self.text.map {
            self.textDidChangeAction?($0)
        }
    }
    
    @objc func editDidBegin() {
        self.inFocus = true
    }
    
    @objc func editDidEnd() {
        self.inFocus = false
    }
}
