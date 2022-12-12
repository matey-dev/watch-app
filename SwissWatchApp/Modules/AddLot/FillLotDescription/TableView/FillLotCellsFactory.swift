//
//  FillLotCellsFactory.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class FillLotCellsFactory {
    private var cells: [(type: FillLotTableViewCell.Type, model: FillLotTableViewCellModel)]
    private var brands: [Brand]
    
    // swiftlint:disable function_body_length
    init(brands: [Brand]) {
        self.brands = brands
        
        var cells: [(type: FillLotTableViewCell.Type, model: FillLotTableViewCellModel)] = []
        
        let watchNameCellType = FillLotDropdownCell.self
        let watchNameModel = FillLotDropdownCellModel(cell: FillLotModel.Field(key: .watch_name), brands: brands)
        
        let watchModelCellType = FillLotTextCell.self
        let watchModelModel = FillLotTextCellModel(cell: FillLotModel.Field(key: .watch_model))
        
        let refNoCellType = FillLotTextCell.self
        let refNoModel = FillLotTextCellModel(cell: FillLotModel.Field(key: .reference_no))
        
        let modelYearCellType = FillLotTextCell.self
        let modelYearModel = FillLotTextCellModel(cell: FillLotModel.Field(key: .model_year))
        
        let emptyCellType = FillLotEmptyCell.self
        let emptyCellModel = FillLotEmptyCellModel()
        
        let checkBox1Text = "I have original box"
        let checkBox1CellType = FillLotCheckBoxCell.self
        let checkBox1Model = FillLotCheckBoxCellModel(cell: FillLotModel.CheckBox(text: checkBox1Text, key: .box))
        
        let checkBox2Text = "I have original documents"
        let checkBox2CellType = FillLotCheckBoxCell.self
        let checkBox2Model = FillLotCheckBoxCellModel(cell: FillLotModel.CheckBox(text: checkBox2Text, key: .documents))
        
        let buttonTitle = "Submit"
        let buttonCellType = FillLotButtonCell.self
        let buttonModel = FillLotButtonCellModel(cell: FillLotModel.Button(title: buttonTitle))
        
        cells.append((type: watchNameCellType, model: watchNameModel))
        cells.append((type: watchModelCellType, model: watchModelModel))
        cells.append((type: refNoCellType, model: refNoModel))
        cells.append((type: modelYearCellType, model: modelYearModel))
        cells.append((type: emptyCellType, model: emptyCellModel))
        cells.append((type: checkBox1CellType, model: checkBox1Model))
        cells.append((type: checkBox2CellType, model: checkBox2Model))
        cells.append((type: buttonCellType, model: buttonModel))
        
        self.cells = cells
    }
    // swiftlint:enable function_body_length
    
    var numberOfCells: Int {
        return self.cells.count
    }
    
    var cellTypes: [FillLotTableViewCell.Type] {
        return self.cells.map { $0.type }
    }
    
    var models: [FillLotTableViewCellModel] {
        return self.cells.map { $0.model }
    }
    
    var buttonModel: FillLotButtonCellModel? {
        return self.models.first(where: { $0 is FillLotButtonCellModel }) as? FillLotButtonCellModel
    }
    
    func cellTypeFor(indexPath: IndexPath) -> FillLotTableViewCell.Type? {
        return self.cellTypes[safe: indexPath.row]
    }
    
    func modelFor(indexPath: IndexPath) -> FillLotTableViewCellModel? {
        return self.models[safe: indexPath.row]
    }
    
    var isEnabledToSubmit: Bool {
        if let watchNameModel = self.models.first(where: {
            ($0 as? FillLotDropdownCellModel)
                .map { textCellModel in
                    textCellModel.cell.key == .watch_name
                } ?? {
                    return false
                }()
        }) as? FillLotDropdownCellModel {
            return !watchNameModel.cell.text.isEmpty
        } else {
            return false
        }
    }
    
    func cellFor(_ tableView: UITableView, indexPath: IndexPath) -> FillLotTableViewCell? {
        guard let cellType = self.cellTypes[safe: indexPath.row] else { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? FillLotTableViewCell
        
        self.models[safe: indexPath.row].map { cell?.configure(model: $0) }
        
        return cell
    }
}
