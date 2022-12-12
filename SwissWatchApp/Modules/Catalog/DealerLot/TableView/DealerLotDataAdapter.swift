//
//  DealerLotDataAdapter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotDataAdapter: NSObject {
    var actionHandler: DealerLotTableViewHandler?
    
    private var cellsFactory: DealerLotCellsFactory
    init(lot: DealerLot) {
        self.cellsFactory = DealerLotCellsFactory(lot: lot)
    }
}

extension DealerLotDataAdapter: UITableViewDelegate {
    
}

extension DealerLotDataAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsFactory.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.cellsFactory.cellFor(tableView, indexPath: indexPath),
            let tableViewCell = cell as? UITableViewCell else {
                return UITableViewCell()
        }
        
        cell.actionHandler = { actionType in
            switch actionType {
            default: ()
            }
            
            self.actionHandler?(actionType)
        }
        return tableViewCell
    }
}
