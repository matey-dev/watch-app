//
//  ArchiveBriefCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 20.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit

class ArchiveBriefCell: UITableViewCell {
    
    @IBOutlet weak var lotImageView: UIImageView!
    
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var referenceNoLbl: UILabel!
    
    @IBOutlet weak var statusLbl: UILabel!
    
    
    var lot: Catalog.Lot! {
        didSet {
            lotImageView.setImage(withUrl: lot.previewURL)
            nameLbl.text = lot.label
            referenceNoLbl.text = lot.reference
            statusLbl.attributedText = lot.statusAttributedString
        }
    }
}

