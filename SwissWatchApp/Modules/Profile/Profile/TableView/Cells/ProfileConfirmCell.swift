//
//  ProfileConfirmCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class ProfileConfirmButtonCell: UITableViewCell, ProfileTableViewCell {
    private var model: ProfileConfirmButtonCellModel?
    var actionHandler: ProfileTableViewHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    private func setup() {}
    
    private func clear() {}
    
    func configure(model: ProfileTableViewCellModel?) {}
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        self.actionHandler?(.confirmButtonAction)
    }
}

class ProfileConfirmButtonCellModel: ProfileTableViewCellModel {}
