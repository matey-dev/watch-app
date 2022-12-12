//
//  ProfileCellsFactory.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class ProfileCellsFactory {
    private var state: UserType
    
    var isShouldShowConfirmButton: Bool = false {
        didSet {
            let buttonsCellModel = self.models.first(where: { $0 is ProfileButtonsCellModel }) as? ProfileButtonsCellModel
            buttonsCellModel?.buttons.state = self.isShouldShowConfirmButton ? .editProfile : .default
        }
    }
    private var _cells: [(type: ProfileTableViewCell.Type, model: ProfileTableViewCellModel)]
    private var cells: [(type: ProfileTableViewCell.Type, model: ProfileTableViewCellModel)] {
        if self.isShouldShowConfirmButton {
            return self._cells
        } else {
            return self._cells.filter { !($0.model is ProfileConfirmButtonCellModel) }
        }
    }
    
    init(state: UserType, profile: Profile?) {
        self.state = state
        var cells: [(type: ProfileTableViewCell.Type, model: ProfileTableViewCellModel)] = []
        
//        let headerCellType = ProfileHeaderCell.self
//        let headerModel = ProfileHeaderCellModel()
//        cells.append((type: headerCellType, model: headerModel))
        
        let firstNameCellType = ProfileBodyCell.self
        let firstNameModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .firstName,
                                                                                    text: profile?.firstName))
        cells.append((type: firstNameCellType, model: firstNameModel))
        
        let lastNameCellType = ProfileBodyCell.self
        let lastNameModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .lastName,
                                                                                   text: profile?.lastName))
        cells.append((type: lastNameCellType, model: lastNameModel))
        
        if self.state == .dealer {
            let companyNameCellType = ProfileBodyCell.self
            let companyNameModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .company,
                                                                                          text: profile?.companyName))
            cells.append((type: companyNameCellType, model: companyNameModel))
            
            let companyPhoneCellType = ProfileBodyCell.self
            let companyPhoneModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .phone,
                                                                                           text: profile?.companyPhone))
            cells.append((type: companyPhoneCellType, model: companyPhoneModel))
            
        }
        
        let emailCellType = ProfileBodyCell.self
        let emailModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .email,
                                                                                text: profile?.email))
        cells.append((type: emailCellType, model: emailModel))
        
        let addressCellType = ProfileBodyCell.self
        let addressModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .address,
                                                                                text: profile?.address))
        cells.append((type: addressCellType, model: addressModel))
        
        let cityCellType = ProfileBodyCell.self
        let cityModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .city,
                                                                            text: profile?.city))
        cells.append((type: cityCellType, model: cityModel))
        
        let stateCellType = ProfileBodyCell.self
        let stateModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .state,
                                                                                text: profile?.state))
        cells.append((type: stateCellType, model: stateModel))
        
        let zipCellType = ProfileBodyCell.self
        let zipModel = ProfileBodyCellModel(cell: ProfileModel.TableView.Body(key: .zip,
                                                                                text: profile?.zip))
        cells.append((type: zipCellType, model: zipModel))
        
        let confirmCellType = ProfileConfirmButtonCell.self
        let confirmModel = ProfileConfirmButtonCellModel()
        cells.append((type: confirmCellType, model: confirmModel))
        
        let buttonsCellType = ProfileButtonsCell.self
        let buttonsModel = ProfileButtonsCellModel(buttons: ProfileModel.TableView.Buttons())
        cells.append((type: buttonsCellType, model: buttonsModel))
        
        self._cells = cells
    }
    
    var numberOfCells: Int {
        return self.cells.count
    }
    
    var cellTypes: [ProfileTableViewCell.Type] {
        return self.cells.map { $0.type }
    }
    
    var confirmButtonCellModel: ProfileConfirmButtonCellModel? {
        return self.models.first(where: { $0 is ProfileConfirmButtonCellModel }) as? ProfileConfirmButtonCellModel
    }
    
    var models: [ProfileTableViewCellModel] {
        return self.cells.map { $0.model }
    }
    
    func cellTypeFor(indexPath: IndexPath) -> ProfileTableViewCell.Type? {
        return self.cellTypes[safe: indexPath.row]
    }
    
    func modelFor(indexPath: IndexPath) -> ProfileTableViewCellModel? {
        return self.models[safe: indexPath.row]
    }
    
    func cellFor(_ tableView: UITableView, indexPath: IndexPath) -> ProfileTableViewCell? {
        guard let cellType = self.cellTypes[safe: indexPath.row] else { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? ProfileTableViewCell
        
        self.models[safe: indexPath.row].map { cell?.configure(model: $0) }
        
        return cell
    }
}
