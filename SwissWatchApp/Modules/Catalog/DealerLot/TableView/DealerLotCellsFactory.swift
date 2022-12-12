//
//  DealerLotCellsFactory.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotCellsFactory: NSObject {
    private var lot: DealerLot
    //swiftlint:disable cyclomatic_complexity
    init(lot: DealerLot) {
        self.lot = lot
        self.cells = []
        
        let imagesCellType = DealerLotImagesTableViewCell.self
        let descriptionCellType = DealerLotDescriptionTableViewCell.self
        let enterBidCellType = DealerLotEnterBidTableViewCell.self
        let myAppraisalCellType = DealerLotMyAppraisalTableViewCell.self
        let yourBidWinCellType = DealerLotYourBidWinTableViewCell.self
        let shippedCellType = DealerLotShippedTableViewCell.self
//        let flagOutCellType = DealerLotFlagOutTableViewCell.self
        let model = self.lot
        
        if let status = self.lot.status {
            switch status {
            case .new:
                self.cells.append((type: imagesCellType, model: model))
                self.cells.append((type: descriptionCellType, model: model))
                self.cells.append((type: enterBidCellType, model: model))
//                self.cells.append((type: flagOutCellType, model: model))
            case .deleted: ()
            case .appraised:
                self.cells.append((type: imagesCellType, model: model))
                self.cells.append((type: descriptionCellType, model: model))
                self.cells.append((type: myAppraisalCellType, model: model))
//                self.cells.append((type: flagOutCellType, model: model))
            case .won:
                self.cells.append((type: imagesCellType, model: model))
                self.cells.append((type: descriptionCellType, model: model))
                self.cells.append((type: yourBidWinCellType, model: model))
//                self.cells.append((type: flagOutCellType, model: model))
            case .shipping:
                self.cells.append((type: imagesCellType, model: model))
                self.cells.append((type: descriptionCellType, model: model))
                self.cells.append((type: shippedCellType, model: model))
            case .lost: ()
//            case .shipping:
//                self.cells.append((type: imagesCellType, model: model))
//                self.cells.append((type: descriptionCellType, model: model))
//                self.cells.append((type: shippedCellType, model: model))
//                self.cells.append((type: flagOutCellType, model: model))
            case .blocked: ()
            case .expired: ()
            case .verified: ()
            case .notVerified: ()
            }
        }
    }
    //swiftlint:enable cyclomatic_complexity
    
    private var cells: [(type: DealerLotTableViewCell.Type, model: DealerLotTableViewCellModel)]
    
    var numberOfCells: Int {
        return self.cells.count
    }
    
    var cellTypes: [DealerLotTableViewCell.Type] {
        return self.cells.map { $0.type }
    }
    
    var models: [DealerLotTableViewCellModel] {
        return self.cells.map { $0.model }
    }
    
    func cellTypeFor(indexPath: IndexPath) -> DealerLotTableViewCell.Type? {
        return self.cellTypes[safe: indexPath.row]
    }
    
    func modelFor(indexPath: IndexPath) -> DealerLotTableViewCellModel? {
        return self.models[safe: indexPath.row]
    }
    
    func cellFor(_ tableView: UITableView, indexPath: IndexPath) -> DealerLotTableViewCell? {
        guard let cellType = self.cellTypes[safe: indexPath.row] else { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? DealerLotTableViewCell
        
        self.models[safe: indexPath.row].map { cell?.configure(model: $0) }
        
        return cell
    }
}
