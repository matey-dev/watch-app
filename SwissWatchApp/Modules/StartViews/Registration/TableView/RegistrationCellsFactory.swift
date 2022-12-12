//
//  RegistrationCellsFactory.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RegistrationCellsFactory {
    let userType: UserType
    
    private var cells: [(type: RegistrationTableViewCell.Type, model: RegistrationTableViewCellModel)]
    
    // swiftlint:disable function_body_length
    init(userType: UserType) {
        self.userType = userType
        
        let title: String
        switch userType {
        case .seller:
            title = "Seller Sign up"
        case .dealer:
            title = "Dealer Sign up"
        }
        
        var cells: [(type: RegistrationTableViewCell.Type, model: RegistrationTableViewCellModel)] = []
        
        let headerCellType = RegistrationHeaderCell.self
        let headerModel = RegistrationHeaderCellModel(cell: RegistrationModel.Header.init(title: title))
        
        let emailCellType = RegistrationTextCell.self
        let emailModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .email))
        
        let passwordCellType = RegistrationTextCell.self
        let passwordModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .password))
        
        let confirmPasswordCellType = RegistrationTextCell.self
        let confirmPasswordModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .password_confirm))
        
        let checkBoxCellType = RegistrationCheckBoxCell.self
        let checkBoxModel = RegistrationCheckBoxCellModel(cell: RegistrationModel.CheckBox(attributedText: SignUp().checkBoxText))
        
        let buttonCellType = RegistrationButtonCell.self
        let buttonModel = RegistrationButtonCellModel(cell: RegistrationModel.Button(title: SignUp.buttonTitle))
        
        switch userType {
        case .seller:
            cells.append((type: headerCellType, model: headerModel))
            cells.append((type: emailCellType, model: emailModel))
            cells.append((type: passwordCellType, model: passwordModel))
            cells.append((type: confirmPasswordCellType, model: confirmPasswordModel))
            cells.append((type: checkBoxCellType, model: checkBoxModel))
            cells.append((type: buttonCellType, model: buttonModel))
        case .dealer:
            
            let firstNameCellType = RegistrationTextCell.self
            let firstNameModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .first_name))
            
            let lastNameCellType = RegistrationTextCell.self
            let lastNameModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .last_name))
            
            let companyNameCellType = RegistrationTextCell.self
            let companyNameModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .company_name))
            
            let companyPhoneCellType = RegistrationTextCell.self
            let companyPhoneModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .company_phone))
            
            let addressCellType = RegistrationTextCell.self
            let addressModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .address))
            let cityCellType = RegistrationTextCell.self
            let cityModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .city))
            let stateCellType = RegistrationTextCell.self
            let stateModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .state))
            let zipCellType = RegistrationTextCell.self
            let zipModel = RegistrationTextCellModel(cell: RegistrationModel.Field(key: .zip))
            
            cells.append((type: headerCellType, model: headerModel))
            cells.append((type: firstNameCellType, model: firstNameModel))
            cells.append((type: lastNameCellType, model: lastNameModel))
            cells.append((type: companyNameCellType, model: companyNameModel))
            cells.append((type: companyPhoneCellType, model: companyPhoneModel))
            cells.append((type: emailCellType, model: emailModel))
            cells.append((type: passwordCellType, model: passwordModel))
            cells.append((type: confirmPasswordCellType, model: confirmPasswordModel))
            cells.append((type: addressCellType, model: addressModel))
            cells.append((type: cityCellType, model: cityModel))
            cells.append((type: stateCellType, model: stateModel))
            cells.append((type: zipCellType, model: zipModel))
            cells.append((type: checkBoxCellType, model: checkBoxModel))
            cells.append((type: buttonCellType, model: buttonModel))
        }
        
        self.cells = cells
    }
    // swiftlint:enable function_body_length
    
    var numberOfCells: Int {
        return self.cells.count
    }
    
    var cellTypes: [RegistrationTableViewCell.Type] {
        return self.cells.map { $0.type }
    }
    
    var models: [RegistrationTableViewCellModel] {
        return self.cells.map { $0.model }
    }
    
    var buttonModel: RegistrationButtonCellModel? {
        return self.models.first(where: { $0 is RegistrationButtonCellModel }) as? RegistrationButtonCellModel
    }
    
    func cellTypeFor(indexPath: IndexPath) -> RegistrationTableViewCell.Type? {
        return self.cellTypes[safe: indexPath.row]
    }
    
    func modelFor(indexPath: IndexPath) -> RegistrationTableViewCellModel? {
        return self.models[safe: indexPath.row]
    }
    
    func cellFor(_ tableView: UITableView, indexPath: IndexPath) -> RegistrationTableViewCell? {
        guard let cellType = self.cellTypes[safe: indexPath.row] else { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? RegistrationTableViewCell
        
        self.models[safe: indexPath.row].map { cell?.configure(model: $0) }
        
        return cell
    }
}
