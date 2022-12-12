//
//  DealerLotFlagOutTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/9/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotFlagOutTableViewCell: UITableViewCell, DealerLotTableViewCell {
    var model: DealerLotTableViewCellModel?
    var actionHandler: DealerLotTableViewHandler?
    
    @IBOutlet weak var button: UIButton!
    
    func configure(model: DealerLotTableViewCellModel?) {
        guard let model = model else { return }
        self.model = model
        
        self.setFlaggedState(model.flagged)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.actionHandler?(.flagOut)
    }
}

private extension DealerLotFlagOutTableViewCell {
    func setFlaggedState(_ flagged: Bool) {
        let title = flagged ? "Flagged" : "Flag Out"
        let interaction = !flagged
        self.button.isUserInteractionEnabled = interaction
        self.button.setTitle(title, for: .normal)
    }
}
