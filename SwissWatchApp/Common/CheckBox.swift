//
//  CheckBox.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    // Images
    private let checkedImage = #imageLiteral(resourceName: "group-3")
    //let uncheckedImage = UIImage(named: "check")
    
    private var checkIsChanged: ((Bool) -> Void)?
    func onCheckChanged(_ handler: ((Bool) -> Void)?) {
        self.checkIsChanged = handler
    }
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            self.setUIChecked(self.isChecked)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    fileprivate func setupUI() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
        
        self.tintColor = Colors.white
        self.layer.masksToBounds = true
        self.setUIChecked(false)
    }
    
    override func awakeFromNib() {
        setupUI()
    }
    
    private func setUIChecked(_ checked: Bool) {
        onMainQueue {
            let borderWidth: CGFloat = 1.0
            let borderColor: CGColor = checked ? UIColor(hex: "#29C7A9").cgColor : UIColor(hex: "#F4F4F4").cgColor
            let backColor: UIColor = checked ? UIColor(hex: "#29C7A9") : UIColor(hex: "#F9FAFA")
            
            self.layer.masksToBounds = true
            self.layer.cornerRadius = 6.0
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor
            self.backgroundColor = backColor
            
            let image: UIImage? = self.isChecked ? self.checkedImage : .none
            self.setImage(image, for: UIControl.State.normal)
        }
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            self.isChecked = !isChecked
            self.checkIsChanged?(self.isChecked)
        }
    }
    
    @discardableResult func invertState() -> Bool {
        self.buttonClicked(sender: self)
        return self.isChecked
    }
}
