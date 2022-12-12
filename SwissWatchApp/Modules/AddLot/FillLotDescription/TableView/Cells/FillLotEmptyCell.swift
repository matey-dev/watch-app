//
//  FillLotEmptyCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class FillLotEmptyCell: UITableViewCell, FillLotTableViewCell {
    func configure(model: FillLotTableViewCellModel?) {}
    var actionHandler: FillLotTableViewHandler?
}

class FillLotEmptyCellModel: FillLotTableViewCellModel {
    var fields: [FillLotModel.Field] = []
    var checks: [FillLotModel.CheckBox] = []
}
