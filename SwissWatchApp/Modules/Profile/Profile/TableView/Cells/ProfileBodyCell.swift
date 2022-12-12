//
//  ProfileBodyCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class ProfileBodyCell: UITableViewCell, ProfileTableViewCell {
    private var model: ProfileBodyCellModel?
    var actionHandler: ProfileTableViewHandler?
    
    @IBOutlet weak var textField: BaseTextField!
    @IBOutlet weak var fieldNameLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    private var oldText: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.clear()
    }
    
    private func setup() {}
    
    private func clear() {
        self.textField.text = .none
        self.separatorView.isHidden = false
    }
    
    func configure(model: ProfileTableViewCellModel?) {
        (model as? ProfileBodyCellModel).map { model in
            self.model = model
            
            onMainQueue {
                self.oldText = model.cell.text
                self.textField.text = model.cell.text
                self.fieldNameLabel.text = model.cell.label
                
                switch model.cell.key {
                case .email:
                    self.textField.isUserInteractionEnabled = false
                    self.textField.textColor = self.fieldNameLabel.textColor
                case .phone:
                    self.textField.keyboardType = .phonePad
                case .zip:
                    self.separatorView.isHidden = true
                default:
                    self.separatorView.isHidden = false
                    self.textField.isUserInteractionEnabled = true
                    self.textField.textColor = Colors.blackLight
                    self.textField.keyboardType = .default
                }
            }
            
            self.textField.tag = model.cell.priority
            
            self.textField.addTarget(self, action: #selector(textFieldEditingDidBegin(textField:)), for: .editingDidBegin)
            self.textField.addTarget(self, action: #selector(textFieldDidEndEditing(textField:)), for: .editingDidEnd)
        }
    }
    
    @objc private func textFieldEditingDidBegin(textField: UITextField) {
        guard textField == self.textField else { return }
        self.separatorView.backgroundColor = Colors.blue
        self.separatorView.isHidden = false
    }
    
    @objc private func textFieldDidEndEditing(textField: UITextField) {
        guard textField == self.textField else { return }
        self.separatorView.backgroundColor = Colors.black_5opacity
        textField.text.map {
            self.model?.cell.text = $0
            if oldText != $0 {
                self.actionHandler?(.dataDidChanged)
            }
        }
    }
}

class ProfileBodyCellModel: ProfileTableViewCellModel {
    let cell: ProfileModel.TableView.Body
    
    init(cell: ProfileModel.TableView.Body) {
        self.cell = cell
    }
}
