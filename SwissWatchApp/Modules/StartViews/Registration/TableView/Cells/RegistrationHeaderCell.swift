//
//  RegistrationHeaderCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RegistrationHeaderCell: UITableViewCell, RegistrationTableViewCell {
    private var model: RegistrationHeaderCellModel?
    var actionHandler: RegistrationTableViewHandler?
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    private func setup() {}
    
    private func clear() { self.label.text = .none }
    
    func configure(model: RegistrationTableViewCellModel?) {
        (model as? RegistrationHeaderCellModel).map { model in
            self.model = model
            
            self.label.text = model.cell.title
        }
    }
}

class RegistrationHeaderCellModel: RegistrationTableViewCellModel {
    var cells: [RegistrationModel.Field] {
        return []
    }
    
    let cell: RegistrationModel.Header
    
    init(cell: RegistrationModel.Header) {
        self.cell = cell
    }
}
