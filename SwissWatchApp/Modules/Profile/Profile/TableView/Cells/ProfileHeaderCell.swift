//
//  ProfileHeaderCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell, ProfileTableViewCell {
    private var model: ProfileHeaderCellModel?
    var actionHandler: ProfileTableViewHandler?
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
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
}

class ProfileHeaderCellModel: ProfileTableViewCellModel {}
