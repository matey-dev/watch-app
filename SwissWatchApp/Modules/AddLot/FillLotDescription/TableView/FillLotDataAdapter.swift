//
//  FillLotDataAdapter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/6/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class FillLotDataAdapter: NSObject {
    private var cellsFactory: FillLotCellsFactory
    private var brands: [Brand]
    
    var actionHandler: FillLotTableViewHandler?
    
    init(brands: [Brand]) {
        self.brands = brands
        self.cellsFactory = FillLotCellsFactory(brands: self.brands)
        super.init()
    }
    
    // MARK: cell models
    var fieldModels: [FillLotModel.Field] {
        return self.cellsFactory.models.map { $0.fields }.flatMap { $0 }
    }
    
    var checkModels: [FillLotModel.CheckBox] {
        return self.cellsFactory.models.map { $0.checks }.flatMap { $0 }
    }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        var cantFind: [String: String] = [:]
        self.fieldModels.forEach { $0.errorText = nil }
        dict.forEach { (key, value) in
            if !self.updateErrorOnCellModelWithKey(key, errorText: value) {
                cantFind[key] = value
            }
        }
        return cantFind
    }
    
    @discardableResult func updateErrorOnCellModelWithKey(_ key: String, errorText: String) -> Bool {
        if let key = FillLotModel.Field.Key(rawValue: key),
            let cellModel = self.fieldModels.first(where: { $0.key == key }) {
            cellModel.errorText = errorText
            return true
        } else if let key = FillLotModel.CheckBox.Key(rawValue: key),
            let cellModel = self.checkModels.first(where: { $0.key == key }) {
            cellModel.errorText = errorText
            return true
        } else {
            return false
        }
    }
}

extension FillLotDataAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsFactory.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cartCell = self.cellsFactory.cellFor(tableView, indexPath: indexPath),
            let tableViewCell = cartCell as? UITableViewCell else {
                return UITableViewCell()
        }
        
        cartCell.actionHandler = { [weak self] actionType in
            switch actionType {
            case .submit:
                break
            case .modelIsChanged:
                self?.cellsFactory.buttonModel?.cell.active = self?.cellsFactory.isEnabledToSubmit ?? false
                tableView.visibleCells.first(where: { $0 is FillLotButtonCell }).map { cell in
                    tableView.indexPath(for: cell).map { indexPath in
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            
            self?.actionHandler?(actionType)
        }
        
        return tableViewCell
    }
}

extension FillLotDataAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
