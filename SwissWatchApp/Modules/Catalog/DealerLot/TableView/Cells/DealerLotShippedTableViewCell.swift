//
//  DealerLotShippedTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/19/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotShippedTableViewCell: UITableViewCell, DealerLotTableViewCell {
  var model: DealerLotTableViewCellModel?
  var actionHandler: DealerLotTableViewHandler?
  
  func configure(model: DealerLotTableViewCellModel?) {
    guard let model = model else { return }
    self.model = model
  }
}
