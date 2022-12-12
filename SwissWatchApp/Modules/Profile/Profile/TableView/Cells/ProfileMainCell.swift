//
//  ProfileMainCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 18.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit

class ProfileMainCell: UITableViewCell {
    
    var tapAction: (() -> ())?
    
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @IBAction func didTapCell(_ sender: Any) {
        tapAction?()
    }
    
}


