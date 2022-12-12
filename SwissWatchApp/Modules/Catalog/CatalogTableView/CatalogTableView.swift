//
//  CatalogTableView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/7/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import SnapKit

private let estimatedRowHeight: CGFloat = 800.0

typealias CatalogTableViewAction = ((CatalogTableViewActionType) -> Void)
typealias CatalogTableViewLoadNextAction = (() -> Void)

enum CatalogTableViewType {
    case general, archive
}

enum CatalogTableViewActionType {
    case refreshData
    case emptyDataSource
    case deleteLot(id: Int)
    case selectedLot(_ lot: Catalog.Lot)
}

enum CatalogTableViewCellSwipeActionType {
    case delete
}

enum CatalogTableViewCellType {
    case general, big
}

class CatalogTableView: UIView {
    var cellType: CatalogTableViewCellType = .general {
        didSet {
            self.dataAdapter.cellType = self.cellType
        }
    }
    private let refreshControl = LoadRefreshControl()
    var cellSwipeActions: [CatalogTableViewCellSwipeActionType] = []
    var allowsSelection: Bool = false
    var userType: UserType? {
        didSet {
            self.dataAdapter.userType = self.userType
        }
    }
    var type: CatalogTableViewType? {
        didSet {
            self.dataAdapter.type = self.type
        }
    }
    let tableView: UITableView = UITableView()
    let dataAdapter = CatalogTableViewDataAdapter()
    var countOfItems: Int {
        return self.dataAdapter.countOfItems
    }
    
    var onAction: CatalogTableViewAction?
    func onAction(_ callback: CatalogTableViewAction?) {
        self.onAction = callback
    }
    
    var preloadAction: CatalogTableViewLoadNextAction?
    func preloadAction(_ callback: CatalogTableViewLoadNextAction?) {
        self.preloadAction = callback
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func reloadData() {
        if self.dataAdapter.isEmpty {
            self.onAction?(.emptyDataSource)
        }
        self.tableView.reloadData()
//        self.tableView.updateWithDiff(oldArray: self.dataAdapter.oldListOfLots(),
//                                      newArray: self.dataAdapter.currentListOfLots(),
//                                      updateData: {
//                                        self.dataAdapter.markUpdateIsSuccessfull()
//        })
    }
    
    func endRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    func deleteLot(id: Int) {
        if let index = self.dataAdapter.deleteLotWith(id: id) {
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                      with: .bottom)
        } else {
            self.reloadData()
        }
    }
}

private extension CatalogTableView {
    func setup() {
        self.dataAdapter.catalogTableView = self
        
        self.addSubview(self.tableView)
        self.tableView.backgroundColor = .clear
        self.tableView.clipsToBounds = false
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = estimatedRowHeight
        
        self.tableView.dataSource = self.dataAdapter
        
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelectionDuringEditing = false
        self.tableView.allowsSelection = false
        self.tableView.allowsMultipleSelection = false
        
        self.tableView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.tableView.register(CatalogTableViewCell.self,
                                forCellReuseIdentifier: String(describing: CatalogTableViewCell.self))
        self.tableView.register(CatalogTableViewBigCell.self,
                                forCellReuseIdentifier: String(describing: CatalogTableViewBigCell.self))
    }
    
    @objc func refreshData() {
        self.onAction?(.refreshData)
    }
}
