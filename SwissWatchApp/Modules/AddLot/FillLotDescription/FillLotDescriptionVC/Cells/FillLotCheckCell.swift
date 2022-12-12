//
//  FillLotCheckCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 16.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import MagazineLayout
import Combine
import LBTATools

class FillLotCheckCell: MagazineLayoutCollectionViewCell {
    
    let titleLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: FontNames.SFProText.semibold, size: 16)
        return l
    }()
    
    let checkBox: CheckBox = {
        let b = CheckBox(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    var isChecked = false {
        didSet {
            checkBox.isChecked = isChecked
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var onValueChange: ((Bool) -> ())?
    
    func setupCell() {
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        container.fillSuperview()
        let containerHeight = container.heightAnchor.constraint(equalToConstant: 40)
        containerHeight.priority = UILayoutPriority(rawValue: 250)
        containerHeight.isActive = true
        container.hstack(checkBox.withSize(CGSize(width: 24, height: 24)), titleLbl.withHeight(21), spacing: 12, alignment: .center, distribution: .fill).padTop(8).padBottom(8)
        checkBox.onCheckChanged { (checked) in
            self.titleLbl.textColor = checked ? UIColor(hex: "#101E29") : UIColor(hex: "#8F9599")
            self.onValueChange?(checked)
        }
    }
}
