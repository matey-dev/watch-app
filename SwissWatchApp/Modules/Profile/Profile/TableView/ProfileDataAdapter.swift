//
//  ProfileDataAdapter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class ProfileDataAdapter: NSObject {
    private var state: UserType
    private var cellsFactory: ProfileCellsFactory
    var isShouldShowConfirmButton: Bool {
        didSet {
            self.cellsFactory.isShouldShowConfirmButton = self.isShouldShowConfirmButton
        }
    }
    
    var numberOfCells: Int {
        return self.cellsFactory.numberOfCells
    }
    
    var actionHandler: ProfileTableViewHandler?
    
    var profile: Profile {
        let bodyModels = self.cellsFactory.models.filter { $0 is ProfileBodyCellModel }.compactMap { $0 as? ProfileBodyCellModel }
        let profile = Profile(firstName: bodyModels.first(where: { $0.cell.key == .firstName })?.cell.text,
                              lastName: bodyModels.first(where: { $0.cell.key == .lastName })?.cell.text,
                              email: bodyModels.first(where: { $0.cell.key == .email })?.cell.text,
                              city: bodyModels.first(where: { $0.cell.key == .city })?.cell.text,
                              state: bodyModels.first(where: { $0.cell.key == .state })?.cell.text,
                              address: bodyModels.first(where: { $0.cell.key == .address })?.cell.text,
                              zip: bodyModels.first(where: { $0.cell.key == .zip })?.cell.text,
                              companyName: bodyModels.first(where: { $0.cell.key == .company })?.cell.text,
                              companyPhone: bodyModels.first(where: { $0.cell.key == .phone })?.cell.text)
        return profile
    }
    
    init(state: UserType, profile: Profile?) {
        self.state = state
        self.cellsFactory = ProfileCellsFactory(state: state, profile: profile)
        self.isShouldShowConfirmButton = false
        super.init()
    }
}

extension ProfileDataAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsFactory.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cartCell = self.cellsFactory.cellFor(tableView, indexPath: indexPath),
            let tableViewCell = cartCell as? UITableViewCell else {
                return UITableViewCell()
        }
        
        (cartCell as? ProfileBodyCell)?.isUserInteractionEnabled = self.isShouldShowConfirmButton ? true : false
        
        cartCell.actionHandler = { [weak self] actionType in
            self?.actionHandler?(actionType)
        }
        
        return tableViewCell
    }
}

extension ProfileDataAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
