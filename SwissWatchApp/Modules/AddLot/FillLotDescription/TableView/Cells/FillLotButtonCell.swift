//
//  FillLotButtonCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class FillLotButtonCell: UITableViewCell, FillLotTableViewCell {
    private var model: FillLotButtonCellModel?
    var actionHandler: FillLotTableViewHandler?
    
    @IBOutlet weak var button: UIButton!
    
    private func setup() {}
    
    private func clear() {}
    
    func configure(model: FillLotTableViewCellModel?) {
        (model as? FillLotButtonCellModel).map { model in
            self.model = model
            
            self.button.titleLabel?.text = model.cell.title
            self.setButton(active: model.cell.active)
        }
    }
    
    private func setButton(active: Bool) {
        self.button.isEnabled = active
        
        let backColor = active ? Colors.black_90opacity : Colors.black_8opacity
        self.button.backgroundColor = backColor
        let titleColor = active ? Colors.white : Colors.black_40opacity
        self.button.setTitleColor(titleColor, for: .normal)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        self.actionHandler?(.submit)
    }
}

class FillLotButtonCellModel: FillLotTableViewCellModel {
    var fields: [FillLotModel.Field] {
        return []
    }
    
    var checks: [FillLotModel.CheckBox] {
        return []
    }
    
    let cell: FillLotModel.Button
    
    init(cell: FillLotModel.Button) {
        self.cell = cell
    }
}
