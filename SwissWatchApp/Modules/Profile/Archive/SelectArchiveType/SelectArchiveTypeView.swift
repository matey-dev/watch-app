//
//  SelectArchiveTypeView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias SelectArchiveTypeViewAction = (SelectArchiveTypeViewActionType) -> Void
enum SelectArchiveTypeViewActionType {
    case didSelect([Catalog.Filter])
}

class SelectArchiveTypeView: BaseViewController {
    
    var filters: [Catalog.Filter] = []
    
    private var onAction: SelectArchiveTypeViewAction?
    func onAction(_ callback: SelectArchiveTypeViewAction?) {
        self.onAction = callback
    }
    
    var userType: UserType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        super.appNavigationController?.setNavigationBar(hidden: true)
        expiredCheck.isChecked = self.filters.contains(where: {$0.id == 5})
        verifiedCheck.isChecked = self.filters.contains(where: {$0.id == 3})
        notVerifiedCheck.isChecked = self.filters.contains(where: {$0.id == 2})
//        authenticatedCheck.isChecked = self.filters.contains(where: {$0.id == 3})
//        shippedBackCheck.isChecked = self.filters.contains(where: {$0.id == 2})
        lostCheck.isChecked = self.filters.contains(where: {$0.id == 1})
        blockedCheck.isChecked = self.filters.contains(where: {$0.id == 4})
        
    }
    
    @IBOutlet weak var expiredCheck: CheckBox!
    @IBOutlet weak var verifiedCheck: CheckBox!
    @IBOutlet weak var notVerifiedCheck: CheckBox!
    @IBOutlet weak var authenticatedCheck: CheckBox!
    @IBOutlet weak var shippedBackCheck: CheckBox!
    @IBOutlet weak var lostCheck: CheckBox!
    @IBOutlet weak var blockedCheck: CheckBox!
}

// MARK: - actions
private extension SelectArchiveTypeView {
    
    func action(_ actionType: SelectArchiveTypeViewActionType) {
        self.onAction?(actionType)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.onAction?(.didSelect(self.filters))
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func expired(_ sender: CheckBox) {
        if sender.isChecked {
            if let index = self.filters.firstIndex(where: {$0.id == 5}) {
                self.filters.remove(at: index)
            } else {
                self.filters.append(Catalog.Filter(id: 5, label: "Expired"))
            }
        }
    }

    @IBAction func verified(_ sender: CheckBox) {
        if sender.isChecked {
            if let index = self.filters.firstIndex(where: {$0.id == 3}) {
                self.filters.remove(at: index)
            } else {
                self.filters.append(Catalog.Filter(id: 3, label: "Verified"))
            }
        }
    }

    @IBAction func notVerified(_ sender: CheckBox) {
        if sender.isChecked {
            if let index = self.filters.firstIndex(where: {$0.id == 2}) {
                self.filters.remove(at: index)
            } else {
                self.filters.append(Catalog.Filter(id: 2, label: "Not verified"))
            }
        }
    }

    @IBAction func authenticated(_ sender: CheckBox) {
        if sender.isChecked {
            if let index = self.filters.firstIndex(where: {$0.id == 3}) {
                self.filters.remove(at: index)
            } else {
                self.filters.append(Catalog.Filter(id: 3, label: "Authenticated"))
            }
        }
    }

    @IBAction func shippedBack(_ sender: CheckBox) {
        if sender.isChecked {
            if let index = self.filters.firstIndex(where: {$0.id == 2}) {
                self.filters.remove(at: index)
            } else {
                self.filters.append(Catalog.Filter(id: 2, label: "Shipped back to seller"))
            }
        }
    }

    @IBAction func lost(_ sender: CheckBox) {
        if sender.isChecked {
            if let index = self.filters.firstIndex(where: {$0.id == 1}) {
                self.filters.remove(at: index)
            } else {
                self.filters.append(Catalog.Filter(id: 1, label: "Lost"))
            }
        }
    }

    @IBAction func blocked(_ sender: CheckBox) {
        if sender.isChecked {
            if let index = self.filters.firstIndex(where: {$0.id == 4}) {
                self.filters.remove(at: index)
            } else {
                self.filters.append(Catalog.Filter(id: 4, label: "Blocked"))
            }
        }
    }
}

// MARK: - private
private extension SelectArchiveTypeView {
    func setup() {
        self.title = nil
        guard let userType = self.userType else { return }
    }
}
