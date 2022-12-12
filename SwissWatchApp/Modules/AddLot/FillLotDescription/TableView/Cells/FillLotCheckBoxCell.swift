//
//  FillLotCheckBoxCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class FillLotCheckBoxCell: UITableViewCell, FillLotTableViewCell {
    private var model: FillLotCheckBoxCellModel?
    var actionHandler: FillLotTableViewHandler?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkBoxButton: CheckBox!
    
    private func setup() {}
    
    private func clear() {}
    
    func configure(model: FillLotTableViewCellModel?) {
        (model as? FillLotCheckBoxCellModel).map { model in
            self.model = model
            
            onMainQueue {
                self.label.text = model.cell.text
            }
            
            self.checkBoxButton.onCheckChanged { [weak self, weak model] _ in
                guard let sSelf = self else { return }
                model?.cell.checked = sSelf.checkBoxButton.isChecked
                sSelf.actionHandler?(.modelIsChanged)
                
                onMainQueue {
                    let color = sSelf.checkBoxButton.isChecked ? Colors.blackLight : Colors.black_45opacity
                    sSelf.label.textColor = color
                }
                
            }
        }
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        self.checkBoxButton.invertState()
    }
}

class FillLotCheckBoxCellModel: FillLotTableViewCellModel {
    var checks: [FillLotModel.CheckBox] {
        return [cell]
    }
    
    var fields: [FillLotModel.Field] {
        return []
    }
    
    let cell: FillLotModel.CheckBox
    
    init(cell: FillLotModel.CheckBox) {
        self.cell = cell
    }
}
