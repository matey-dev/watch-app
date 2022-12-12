//
//  DealerLotEnterBidTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/9/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class DealerLotEnterBidTableViewCell: UITableViewCell, DealerLotTableViewCell {
    var model: DealerLotTableViewCellModel?
    var actionHandler: DealerLotTableViewHandler?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        self.textContainer.layer.cornerRadius = 8
        self.textContainer.layer.masksToBounds = true
        self.textContainer.layer.borderWidth = 1
        self.textContainer.layer.borderColor = Colors.blue.cgColor
    }
    
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    private var textTrimmed: String? {
        let trimmed = self.textField.text?.currencyTrimmed()
        return trimmed
    }
    
    func configure(model: DealerLotTableViewCellModel?) {
        guard let model = model else { return }
        self.model = model
        self.textField.keyboardType = .numberPad
        self.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        self.textField.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
//        self.setButtonDisabled(true)
        self.textField.text = "0"
        validate(textField: self.textField)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let text = self.textTrimmed,
            let price = Int(text) else { return }
        self.actionHandler?(.bid(price, self.textField.text))
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        validate(textField: textField)
    }
    
    private func validate(textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
            self.setButtonDisabled(amountString.isEmpty)
        }
    }
    
    @objc func textFieldEditingDidBegin(_ textField: UITextField) {
        if textField.text == "0" {
            textField.text = ""
        }
    }
    
    private func setButtonDisabled(_ disabled: Bool) {
        onMainQueue {
            self.button.isEnabled = !disabled
            let backColor = disabled ? Colors.grayMiddle : Colors.blackLight
            self.button.backgroundColor = backColor
            let titleColor = disabled ? Colors.black_40opacity : Colors.white
            self.button.setTitleColor(titleColor, for: .normal)
        }
    }
}

extension String {
    func trimmedWith(characters: String...) -> String {
        var trimmed = self
        characters.forEach {
            trimmed = trimmed.replacingOccurrences(of: $0, with: "")
        }
        return trimmed
    }
    
    func currencyTrimmed() -> String {
        let trimmed = self.replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
        return trimmed
    }
    
    func currencyInputFormatting() -> String? {
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.generatesDecimalNumbers = false
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        guard let regex = (try? NSRegularExpression(pattern: "[^0-9]",
                                                    options: .caseInsensitive)) else { return nil }
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: double)
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)
    }
}
