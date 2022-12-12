//
//  ProfileBottomCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 18.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit

class ProfileLogoutCell: UITableViewCell {
    var tapAction: (() -> ())?
    @IBAction func didTapCell(_ sender: Any) {
        tapAction?()
    }
}

class ProfileDeleteAccoutCell: UITableViewCell {
    var tapAction: (() -> ())?
    @IBAction func didTapCell(_ sender: Any) {
        tapAction?()
    }
}
