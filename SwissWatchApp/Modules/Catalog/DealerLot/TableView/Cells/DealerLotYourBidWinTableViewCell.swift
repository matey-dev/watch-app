//
//  DealerLotYourBidWinTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/9/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotYourBidWinTableViewCell: UITableViewCell, DealerLotTableViewCell {
    var model: DealerLotTableViewCellModel?
    var actionHandler: DealerLotTableViewHandler?
    
    @IBOutlet weak var label: UILabel!
    
    func configure(model: DealerLotTableViewCellModel?) {
        guard let model = model else { return }
        self.model = model
        
        model.myAppraisalAttributedString().map {
            self.label.attributedText = $0
            } ?? {
                self.label.text = nil
                self.label.attributedText = nil
            }()
    }
}
