//
//  ArchiveListVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 20.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
//swiftlint:disable all

enum ArchiveListVCActionType {
    case back
}

typealias ArchiveListVCAction = ((ArchiveListVCActionType) -> ())

class ArchiveListVC: UIViewController {
    
    var archiveAPIService: CatalogAPIService!
    var reactivateLotAPIService: ReactivateLotAPIService!
    var userType: UserType!
    
    var filters: [Catalog.Filter] = [] {
        didSet {
            if Set(oldValue.map({$0.id})) != Set(filters.map{$0.id}) {
                getList()
            }
        }
    }
    
    var onAction: ArchiveListVCAction?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getList()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        onAction?(.back)
    }
    
    @IBAction func didTapFilter(_ sender: Any) {
        showArchiveFilter()
    }
    
    func showArchiveFilter() {
        let view = SelectArchiveTypeView.storyboardInstance()
        view.userType = userType
        view.filters = self.filters
        view.modalPresentationStyle = .overFullScreen
        view.onAction { [weak self] actionType in
            switch actionType {
            case .didSelect(let filters):
                self?.filters = filters
            }
        }
        
        self.present(view, animated: true, completion: nil)
    }
    
    var lots: [Catalog.Lot] = [] {
        didSet {
            onMainQueue {
                self.tableView.reloadData()
            }
        }
    }
    
    func getList() {
        var lots = [Catalog.Lot]()
        let group = DispatchGroup()
        self.filters.forEach { (filter) in
            group.enter()
            self.archiveAPIService?.getList(filterId: filter.id) { [weak self] result in
                                                switch result {
                                                case .success(let success):
                                                    lots.append(contentsOf: success.lots)
                                                case .failure(let failure):
                                                    self?.showError(title: "Error", message: failure.localizedDescription)
                                                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.lots = lots
        }
    }
    
    func showError(title: String,
                   message: String) {
        onMainQueue {
            self.showAlert(title: title,
                           message: message)
        }
    }
}

extension ArchiveListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.lots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveBriefCell.reuseIdentifier(), for: indexPath) as! ArchiveBriefCell
        cell.lot = self.lots[indexPath.row]
        return cell
    }
}

//swiftlint:disable all
