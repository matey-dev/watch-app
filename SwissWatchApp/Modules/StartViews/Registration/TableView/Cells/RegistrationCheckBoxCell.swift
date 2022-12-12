//
//  RegistrationCheckBoxCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/11/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class RegistrationCheckBoxCell: UITableViewCell, RegistrationTableViewCell {
    private var model: RegistrationCheckBoxCellModel?
    var actionHandler: RegistrationTableViewHandler?
    
    @IBOutlet weak var checkBoxButton: CheckBox!
    @IBOutlet weak var label: UILabel!
    private func setup() {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.0
        let linkFont = UIFont(name: FontNames.SFProText.medium, size: 16)
        let linkColor = Colors.blackTextColor
        let linkAttributes: [NSAttributedString.Key: Any] = [.font: linkFont!,
                                                             .foregroundColor: linkColor,
                                                             .paragraphStyle: style, .underlineStyle: 0, .attachment: URL(string: "https://www.google.com")!]
//        self.label.linkTextAttributes = linkAttributes
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func clear() {}

    
    private func adjustContentSize(tv: UITextView) {
//        let deadSpace = tv.bounds.size.height - tv.contentSize.height
//        let inset = max(0, deadSpace/2.0)
//        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
        tv.contentInset = .zero
        tv.textContainerInset = .zero
    }
    
    func configure(model: RegistrationTableViewCellModel?) {
        (model as? RegistrationCheckBoxCellModel).map { model in
            self.model = model
            
            onMainQueue {
                let isChecked = self.checkBoxButton.isChecked
                self.label.attributedText = model.cell.attributedText
                model.cell.checked = isChecked
                //self.textView.centerVertically()
            }
            
            self.checkBoxButton.onCheckChanged { [weak self] isChecked in
                self?.actionHandler?(.checkBoxIsChanged(isChecked: isChecked))
            }
        }
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        self.checkBoxButton.invertState()
    }
    
    @IBAction func privacyPolicyButtonAction(_ sender: Any) {
        self.actionHandler?(.showPrivacyPolicy)
    }
}

class RegistrationCheckBoxCellModel: RegistrationTableViewCellModel {
    var cells: [RegistrationModel.Field] {
        return []
    }
    
    let cell: RegistrationModel.CheckBox
    
    init(cell: RegistrationModel.CheckBox) {
        self.cell = cell
    }
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(0, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
