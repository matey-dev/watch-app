//
//  DealerLotDescriptionTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/9/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotDescriptionTableViewCell: UITableViewCell, DealerLotTableViewCell {
    var model: DealerLotTableViewCellModel?
    var actionHandler: DealerLotTableViewHandler?
    
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var expiresLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var boxLabel: UILabel!
    @IBOutlet weak var papersLabel: UILabel!
    
    @IBOutlet weak var moreDetailsLbl: UILabel!
    
    
    func configure(model: DealerLotTableViewCellModel?) {
        guard let model = model else { return }
        self.model = model
        
        self.updateLabel(self.brandLabel,
                         with: model.brandAttributedString())
        self.updateLabel(self.referenceLabel,
                         with: model.referenceAttributedString())
        self.updateLabel(self.statusLabel,
                         with: model.statusAttributedString())
        self.updateLabel(self.expiresLabel,
                         with: model.expiresAttributedString())
        self.updateLabel(self.yearLabel,
                         with: model.yearAttributedString())
        self.updateLabel(self.boxLabel,
                         with: model.boxAttributedString())
        self.updateLabel(self.papersLabel,
                         with: model.papersAttributedString())
        
        self.updateLabel(self.moreDetailsLbl, with: model.detailsAttributedString())
        self.moreDetailsLbl.isHidden = (self.model?.description == nil || self.model?.description?.isEmpty == true)
    }
    
    private func updateLabel(_ label: UILabel, with attrString: NSAttributedString?) {
        attrString
            .map {
                label.attributedText = $0
                label.isHidden = false
            } ?? {
                label.isHidden = true
        }()
    }
}
