//
//  ArchiveView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/7/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum ArchiveViewState {
    case empty, some
}

protocol IArchiveView: AnyObject {
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewWillDisappear()
    func append(lots: [Catalog.Lot])
    func set(lots: [Catalog.Lot])
}

class ArchiveView: BaseViewController {
    var userType: UserType?
    var filter: Catalog.Filter = Catalog.Filter(id: 5, label: "Expired")
    
    var state: ArchiveViewState = .empty
    var presenter: IArchivePresenter!
    
    @IBOutlet weak var filterName: UILabel!
    @IBOutlet weak var emptyPlaceholderContainer: UIView!
    @IBOutlet weak var tableViewContainer: CatalogTableView!
    
    func bind(presenter: IArchivePresenter) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.onViewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.onViewWillDisappear()
    }
}

private extension ArchiveView {
    func setup() {
        self.title = "Archive"
        self.setState(.some)
        
        self.filterName.text = self.filter.label
        
        let tableType: CatalogTableViewType = .archive
        self.tableViewContainer.userType = self.userType
        self.tableViewContainer.type = tableType
        self.tableViewContainer.cellSwipeActions = []
        self.tableViewContainer.allowsSelection = true
        self.tableViewContainer.onAction { [weak self] actionType in
            guard let self = self,
                let userType = self.userType else { return }
            switch actionType {
            case .selectedLot(let lot):
                let lotViewModel = Catalog.LotViewModel(lot: lot,
                                                        userType: userType,
                                                        tableType: tableType)
                if lotViewModel.canReactivate {
                    self.showReactivateLotAlert {
                        self.presenter.reactivateLot(id: lot.id) {
                            self.tableViewContainer.deleteLot(id: lot.id)
                            if self.tableViewContainer.countOfItems == .zero {
                                self.set(lots: []) //presenter.refreshData()
                            }
                        }
                    }
                }
            case .refreshData:
                self.presenter.refreshData()
            case .emptyDataSource: ()
            case .deleteLot: ()
            }
        }
        self.tableViewContainer.preloadAction { [weak self] in
            guard let self = self else { return }
            let countOfItems = self.tableViewContainer.countOfItems
            self.presenter.preload(after: countOfItems)
        }
    }
    
    func setState(_ state: ArchiveViewState) {
        self.state = state
        switch state {
        case .some:
            self.tableViewContainer.isHidden = false
            self.emptyPlaceholderContainer.isHidden = true
        case .empty:
            self.tableViewContainer.isHidden = true
            self.emptyPlaceholderContainer.isHidden = false
        }
        
    }
}

extension ArchiveView: IArchiveView {
    func onViewDidLoad() {
        onMainQueue {
            self.setup()
        }
    }
    
    func onViewWillAppear() {
        onMainQueue {
            super.appNavigationController?.setNavigationBar(hidden: false, animated: false)
            if self.state == .empty {
                self.presenter.refreshData()
            }
        }
    }
    
    func onViewWillDisappear() {
        onMainQueue {
            super.appNavigationController?.setNavigationBar(hidden: true)
        }
    }
    
    func append(lots: [Catalog.Lot]) {
        self.tableViewContainer.dataAdapter.append(lots: lots)
        onMainQueue {
            self.setState(self.tableViewContainer.dataAdapter.isEmpty ? .empty : .some)
            self.tableViewContainer.reloadData()
        }
    }
    
    func set(lots: [Catalog.Lot]) {
        self.tableViewContainer.dataAdapter.clear()
        self.tableViewContainer.dataAdapter.append(lots: lots)
        onMainQueue {
            self.setState(self.tableViewContainer.dataAdapter.isEmpty ? .empty : .some)
            self.tableViewContainer.reloadData()
            self.tableViewContainer.endRefreshing()
        }
    }
}

private extension ArchiveView {
    func showReactivateLotAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Reactivate post",
                   button1Title: "Confirm",
                   button2Title: "Cancel",
                   button1Style: .black,
                   button2Style: .white,
                   dismissButtonIsHidden: true)
        view.onAction { actionType in
            switch actionType {
            case .one:
                confirm?()
            case .two: ()
            case .dismiss: ()
            }
        }
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
}
