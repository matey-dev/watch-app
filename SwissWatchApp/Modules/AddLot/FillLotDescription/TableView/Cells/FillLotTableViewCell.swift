//
//  FillLotTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias FillLotTableViewHandler = ((FillLotTableViewAction) -> Void)

enum FillLotTableViewAction {
    case submit
    case modelIsChanged
}

protocol FillLotTableViewCell: class, Reusable {
    func configure(model: FillLotTableViewCellModel?)
    var actionHandler: FillLotTableViewHandler? { get set }
}

protocol FillLotTableViewCellModel {
    var fields: [FillLotModel.Field] { get }
    var checks: [FillLotModel.CheckBox] { get }
}
