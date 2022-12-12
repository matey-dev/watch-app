//
//  FillLotDropDownCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 16.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import MagazineLayout
import Combine
import LBTATools
//swiftlint:disable all

typealias FillLotDropDownCellAction = ((FillLotDropDownCellActionType) -> Void)

enum FillLotDropDownCellActionType {
    case select(index: Int)
}

class FillLotDropDownCell: MagazineLayoutCollectionViewCell {
    
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
    
    var onAction: FillLotDropDownCellAction?
    func onAction(_ callback: FillLotDropDownCellAction?) {
        self.onAction = callback
    }
    
    let dropIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "dropdown")
        iv.isUserInteractionEnabled = true
        return iv
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
        let font = UIFont(name: FontNames.SFProText.medium, size: 16)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        tf.defaultTextAttributes = [.kern: -0.08, .font: font!, .foregroundColor: Colors.blackTextColor, .paragraphStyle: paragraphStyle]
        
        tf.attributedPlaceholder = makeDropDownPlaceholder()
//        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let asteriskView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "valid_mark").withRenderingMode(.alwaysTemplate)
        iv.tintColor = Colors.grayDarkColor
        return iv
    }()
    
    var brands: [Brand] = [] {
        didSet {
            dropDown.dataSource = brands.map({$0.label})
            validateField()
        }
    }
    
    var dropDown: DropDown = DropDown()
    
    var brand: Int? {
        didSet {
            validateField()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        configDropDown()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var store: Set<AnyCancellable> = []
    
    func validateField() {
        guard let brand = brand else {
            textField.text = nil
            return
        }
        if brand < brands.count {
            textField.text = brands.first(where: {$0.id == brand})?.label
        }
    }
    
    func setupCell() {
        borderView.addSubview(textField)
        textField.fillSuperview()
        let borderHeight = borderView.heightAnchor.constraint(equalToConstant: 46)
        borderHeight.priority = UILayoutPriority(rawValue: 250)
        borderHeight.isActive = true
        contentView.addSubview(borderView)
        contentView.addSubview(titleLbl.withHeight(21))
        contentView.addSubview(asteriskView.withSize(CGSize(width: 24, height: 24)))
        titleLbl.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        borderView.anchor(top: titleLbl.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0))
        NSLayoutConstraint.activate([
            asteriskView.leadingAnchor.constraint(equalTo: borderView.trailingAnchor),
            asteriskView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        asteriskView.centerYTo(borderView.centerYAnchor)
        
        contentView.addSubview(dropIcon.withSize(CGSize(width: 24, height: 24)))
        dropIcon.centerYTo(borderView.centerYAnchor)
        dropIcon.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -12).isActive = true
    }
    
    func setupAction() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: textField)
            .map({($0.object as! UITextField).text}).sink(receiveValue: { (text) in
                let valid = (text != nil && self.brands.map({$0.label}).contains(text ?? ""))
                self.asteriskView.tintColor = valid ? Colors.cyanColor : Colors.grayLightColor
                if !valid {
                    self.textField.text = nil
                }
            })
            .store(in: &store)
        textField.delegate = self
        
        dropDown.willShowAction = { [weak self] in
            self?.dropdownShowing = true
            UIView.animate(withDuration: self?.dropDown.animationduration ?? 0.2) {
                self?.dropIcon.transform = .init(rotationAngle: .pi)
            }
        }
        
        dropDown.cancelAction = { [weak self] in
            self?.dropdownShowing = false
            UIView.animate(withDuration: self?.dropDown.animationduration ?? 0.2) {
                self?.dropIcon.transform = .identity
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleDropDown))
        dropIcon.addGestureRecognizer(tap)
    }
    
    func configDropDown() {
        dropDown.anchorView = textField
        dropDown.direction = .bottom
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.textField.text = item
            if let index = self.brands.first(where: {$0.label == item})?.id {
                self.asteriskView.tintColor = Colors.cyanColor
                self.onAction?(.select(index: index))
            } else {
                self.asteriskView.tintColor = Colors.grayTextColor
            }
            UIView.animate(withDuration: self.dropDown.animationduration) {
                self.dropIcon.transform = .identity
            }
            self.dropdownShowing = false
        }
        dropDown.dismissMode = .automatic
        DropDown.appearance().setupCornerRadius(6)
        dropDown.cellNib = UINib(nibName: DropDownItemCell.reuseIdentifier(), bundle: nil)
        
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? DropDownItemCell else { return }
        }
        DropDown.appearance().textColor = Colors.blackTextColor
        DropDown.appearance().selectedTextColor = Colors.blackTextColor
        DropDown.appearance().textFont = UIFont(name: "SFProText-Medium", size: 16)!
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor(hex: "#DAE9ED")
        DropDown.appearance().cellHeight = 51
        dropDown.shadowOpacity = 0
        dropDown.dropDownHeight = 184
    }
    
    @objc func toggleDropDown() {
        dropdownShowing ? dropDown.hide() : showBrands()
    }
    
    func showBrands() {
        dropDown.bottomOffset = CGPoint(x: 0, y:((dropDown.anchorView?.plainView.bounds.height ?? 0) + 2))
        dropDown.show()
    }
    
    var dropdownShowing = false
}

extension FillLotDropDownCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        toggleDropDown()
        return false
    }
}

fileprivate extension FillLotDropDownCell {
    func makeDropDownPlaceholder() -> NSAttributedString {
        let font = UIFont(name: FontNames.SFProText.medium, size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: Colors.grayTextColor, .font: font!, .paragraphStyle: paragraphStyle]
        return NSMutableAttributedString(string: "Please select", attributes: attribute)
    }
}

//swiftlint:disable all
