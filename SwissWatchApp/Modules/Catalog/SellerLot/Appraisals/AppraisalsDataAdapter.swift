//
//  AppraisalsDataAdapter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/29/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias AppraisalsTableViewAction = ((AppraisalsTableViewActionType) -> Void)
enum AppraisalsTableViewActionType {
    case approve(Appraisal)
}

class AppraisalsDataAdapter: NSObject {
    private let appraisals: [Appraisal]
    private weak var tv: UITableView?
    init(appraisals: [Appraisal],
         tableView: UITableView) {
        self.appraisals = appraisals
        self.tv = tableView
    }
    
    var onAction: AppraisalsTableViewAction?
    func onAction(_ callback: AppraisalsTableViewAction?) {
        self.onAction = callback
    }
}

private extension AppraisalsDataAdapter {
    func disableAllCellsExcept(appraisal: Appraisal) {
        self.tv?.visibleCells.forEach { cell in
            guard let appr = (cell as? AppraisalsTableViewCell)?.appraisal else { return }
            if appraisal.id != appr.id {
                (cell as? AppraisalsTableViewCell)?.setToNormalState()
            }
        }
    }
}

extension AppraisalsDataAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appraisals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AppraisalsTableViewCell.self)) else { return AppraisalsTableViewCell() }
        let index = indexPath.row
        
        (cell as? AppraisalsTableViewCell).map { appraisalsTableViewCell in
            appraisalsTableViewCell.tapDelegate = self
            self.appraisals[safe: index].map { appraisal in
                appraisalsTableViewCell.configure(with: appraisal, hint: index == 0)
            }
        }
        return cell
    }
}

extension AppraisalsDataAdapter: UITableViewDelegate {}

extension AppraisalsDataAdapter: AppraisalsTableViewCellDelegate {
    func didSelect(appraisal: Appraisal) {
        self.disableAllCellsExcept(appraisal: appraisal)
        self.onAction?(.approve(appraisal))
    }
}
