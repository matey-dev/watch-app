//
//  RegistrationDataAdapter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RegistrationDataAdapter: NSObject {
    private var cellsFactory: RegistrationCellsFactory
    
    var actionHandler: RegistrationTableViewHandler?
    var onScrollViewDidScroll: (() -> Void)?
    
    init(userType: UserType) {
        self.cellsFactory = RegistrationCellsFactory(userType: userType)
    }
    
    // MARK: cell models
    var fillableCellModels: [RegistrationModel.Field] {
        return self.cellsFactory.models.map { $0.cells }.flatMap { $0 }
    }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        var cantFind: [String: String] = [:]
        self.fillableCellModels.forEach { $0.errorText = nil }
        dict.forEach { (key, value) in
            if !self.updateErrorOnCellModelWithKey(key, errorText: value) {
                cantFind[key] = value
            }
        }
        return cantFind
    }
    
    @discardableResult func updateErrorOnCellModelWithKey(_ key: String, errorText: String) -> Bool {
        guard let key = RegistrationModel.Field.Key(rawValue: key),
        let cellModel = self.fillableCellModels.first(where: { $0.key == key }) else { return false }
        cellModel.errorText = errorText
        return true
    }
}

extension RegistrationDataAdapter: UITableViewDataSource {
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
            case .signUp, .showPrivacyPolicy: ()
            case .checkBoxIsChanged(let isChecked):
                self?.cellsFactory.buttonModel?.cell.active = isChecked
            }
            
            self?.actionHandler?(actionType)
        }
        
        return tableViewCell
    }
}

extension RegistrationDataAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScrollViewDidScroll?()
    }
}
