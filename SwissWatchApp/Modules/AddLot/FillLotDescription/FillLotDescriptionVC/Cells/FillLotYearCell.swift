//
//  FillLotYearCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 01.12.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import MagazineLayout
import Combine
import LBTATools
//swiftlint:disable all
class FillLotYearCell: MagazineLayoutCollectionViewCell {
    
    let titleLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: FontNames.SFProText.semibold, size: 16)
        l.textColor = UIColor(hex: "#8F9599")
        return l
    }()
    
    let borderView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.backgroundColor = UIColor(red: 0.976, green: 0.98, blue: 0.98, alpha: 1).cgColor
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 0.957, green: 0.957, blue: 0.957, alpha: 1).cgColor
        return v
    }()
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        let paddingLeft: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        tf.leftView = paddingLeft
        tf.leftViewMode = .always
        let paddingRight: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        tf.rightView = paddingRight
        tf.rightViewMode = .always
        let font = UIFont(name: FontNames.SFProText.regular, size: 16)
        var paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineHeightMultiple = 1.1
        
        tf.defaultTextAttributes = [.kern: -0.08, .paragraphStyle: paragraphStyle, .backgroundColor: UIColor(red: 0.976, green: 0.98, blue: 0.98, alpha: 1), .foregroundColor: Colors.blackTextColor, .font: font!]
        
        return tf
    }()
    
    let asteriskView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "valid_mark").withRenderingMode(.alwaysTemplate)
        iv.tintColor = Colors.grayDarkColor
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setPlaceholder() {
        textField.attributedPlaceholder = makePlaceholder()
    }
    
    var store: Set<AnyCancellable> = []
    
    var onValueChange: ((String?) -> ())?
    
    func setupCell() {
        borderView.addSubview(textField)
        textField.fillSuperview()
        contentView.addSubview(borderView)
        contentView.addSubview(titleLbl)
        contentView.addSubview(asteriskView)
        let borderHeight = borderView.heightAnchor.constraint(equalToConstant: 46)
        borderHeight.priority = UILayoutPriority(rawValue: 250)
        borderHeight.isActive = true
        NSLayoutConstraint.activate([
            titleLbl.heightAnchor.constraint(equalToConstant: 21),
            asteriskView.widthAnchor.constraint(equalToConstant: 24),
            asteriskView.heightAnchor.constraint(equalToConstant: 24),
            titleLbl.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            borderView.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            asteriskView.leadingAnchor.constraint(equalTo: borderView.trailingAnchor),
            asteriskView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        asteriskView.centerYTo(borderView.centerYAnchor)
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .map({($0.object as! UITextField).text}).map({((Int($0 ?? "") ?? 0) > 1600 && ((Int($0 ?? "") ?? 0) <= self.currentYear)) ? Colors.cyanColor : Colors.grayTextColor})
            .assign(to: \UIImageView.tintColor, on: asteriskView)
            .store(in: &store)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .map({($0.object as! UITextField).text}).sink { (text) in
                self.onValueChange?(text)
        }.store(in: &store)
        
    }
    
    var currentYear: Int {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        let formattedDate = format.string(from: date)
        return Int(formattedDate) ?? 0
    }
}

fileprivate extension FillLotYearCell {
    func makePlaceholder() -> NSAttributedString {
        let font = UIFont(name: FontNames.SFProText.medium, size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: Colors.grayTextColor, .font: font!, .paragraphStyle: paragraphStyle]
        return NSMutableAttributedString(string: "1600 - Current year", attributes: attribute)
    }
}
//swiftlint:disable all

