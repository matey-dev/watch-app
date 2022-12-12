//
//  CatalogTableViewDataAdapter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/27/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class CatalogTableViewDataAdapter: NSObject {
    var cellType: CatalogTableViewCellType = .general
    
    var userType: UserType?
    var type: CatalogTableViewType?
    weak var catalogTableView: CatalogTableView?
    private var lots: [Catalog.Lot] = []
    var isEmpty: Bool { return self.lots.isEmpty }
    var countOfItems: Int {
        return self.lots.count
    }
    
    func append(lots: [Catalog.Lot]) {
        lots.forEach { lot in
            if !self.lots.contains(where: { $0 == lot }) {
                self.lots.append(lot)
            }
        }
    }
    
    func insertTop(lot: Catalog.Lot) {
        if !self.lots.contains(where: { $0 == lot }) {
            self.lots.insert(lot, at: 0)
        }
    }
    
    func clear() {
        self.lots = []
    }
    
    func deleteLotWith(id: Int) -> Int? {
        let index = self.lots.map { $0.id }.firstIndex(of: id)
        self.lots.removeAll(where: { $0.id == id })
        return index
    }
}

extension CatalogTableViewDataAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        switch self.cellType {
        case .general:
            identifier = String(describing: CatalogTableViewCell.self)
        case .big:
            identifier = String(describing: CatalogTableViewBigCell.self)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier),
            let userType = self.userType else { return CatalogTableViewCell() }
        let index = indexPath.row
        if index == (self.lots.count - 30) {
            self.catalogTableView?.preloadAction?()
        }
        cell.selectionStyle = .none
        (cell as? MGSwipeTableCell)?.delegate = self
        (cell as? CatalogTableViewCell).map { catalogTableViewCell in
            catalogTableViewCell.tapDelegate = self
            self.lots[safe: index]
                .map { lot in
                    catalogTableViewCell.configure(with: Catalog.LotViewModel(lot: lot,
                                                                              userType: userType,
                                                                              tableType: self.type ?? .general))
            }
        }
        (cell as? CatalogTableViewBigCell).map { catalogTableViewCell in
            catalogTableViewCell.tapDelegate = self
            self.lots[safe: index]
                .map { lot in
                    catalogTableViewCell.configure(with: Catalog.LotViewModel(lot: lot,
                                                                              userType: userType,
                                                                              tableType: self.type ?? .general))
            }
        }
        return cell
    }
}

extension CatalogTableViewDataAdapter: MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        switch direction {
        case .rightToLeft:
            var newLot: Bool = false
            if (cell as? CatalogTableViewCell)?.viewModel?.isNewStatus ?? false {
                newLot = true
            }
            let canDelete = self.catalogTableView?.cellSwipeActions.contains(.delete) ?? false
            return newLot && canDelete
        case .leftToRight:
            return false
        @unknown default:
            return false
        }
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        (cell as? CatalogTableViewCell)?.viewModel.map { viewModel in
            self.catalogTableView?.onAction?(.deleteLot(id: viewModel.lot.id))
        }
        return true
    }
}

extension CatalogTableViewDataAdapter: CatalogTableViewCellDelegate {
    func didTapLot(_ lot: Catalog.Lot) {
        guard self.catalogTableView?.allowsSelection ?? false else { return }
        
        if let index = self.lots.firstIndex(of: lot),
        let cell = self.catalogTableView?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CatalogTableViewBigCell,
        let imageView = cell.customImageView {
            let rectOfCellInWindow = cell.convert(cell.frame, to: cell.window)
            let rectOfImageInWindow = imageView.convert(imageView.frame, to: imageView.window)
            
            AnimationStorage.shared.firstImage = rectOfImageInWindow
            AnimationStorage.shared.firstCell = rectOfCellInWindow
            AnimationStorage.shared.image = imageView.image
            AnimationStorage.shared.imageAlpha = imageView.alpha
        }
        
        self.catalogTableView?.onAction?(.selectedLot(lot))
    }
}
