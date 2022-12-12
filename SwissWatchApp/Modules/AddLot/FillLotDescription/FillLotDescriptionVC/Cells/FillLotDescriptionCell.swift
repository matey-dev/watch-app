//
//  FillLotDescriptionCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 16.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import MagazineLayout
import Combine
import LBTATools
import KMPlaceholderTextView
//swiftlint:disable all
class FillLotDescriptionCell: MagazineLayoutCollectionViewCell {
    
    let titleLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: FontNames.SFProText.semibold, size: 16)
        l.textColor = UIColor(hex: "#8F9599")
        return l
    }()
    
    lazy var textView: KMPlaceholderTextView = {
        let tv = KMPlaceholderTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor(red: 0.976, green: 0.98, blue: 0.98, alpha: 1)
        tv.layer.cornerRadius = 6
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor(red: 0.957, green: 0.957, blue: 0.957, alpha: 1).cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        tv.typingAttributes = [.kern: -0.08, .paragraphStyle: paragraphStyle, .font: UIFont(name: FontNames.SFProText.regular, size: 16)!, .foregroundColor: Colors.blackTextColor]
        tv.isScrollEnabled = false
        tv.placeholder = ""
        tv.placeholderColor = Colors.grayTextColor
        let font = UIFont(name: FontNames.SFProText.medium, size: 16)
        tv.placeholderFont = font
        tv.automaticallyAdjustsScrollIndicatorInsets = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var onValueChange: ((String?) -> ())?
    
    var store: Set<AnyCancellable> = []
    
    func setupCell() {
        contentView.addSubview(textView)
        
        let textViewHeight = textView.heightAnchor.constraint(equalToConstant: 46)
        textViewHeight.priority = UILayoutPriority(rawValue: 250)
        textViewHeight.isActive = true
        contentView.addSubview(titleLbl.withHeight(21))
        titleLbl.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 28))
        textView.anchor(top: titleLbl.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 24))
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        ])
        
        NotificationCenter
            .default
            .publisher(for: UITextView.textDidChangeNotification, object: textView)
            .map({($0.object as! UITextView).text})
            .sink { (value) in
                self.onValueChange?(value)
            }.store(in: &store)
        
    }
}

fileprivate extension FillLotDescriptionCell {
    func makePlaceholder() -> NSAttributedString {
        let font = UIFont(name: FontNames.SFProText.medium, size: 16)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: Colors.grayTextColor, .font: font!, .paragraphStyle: paragraphStyle]
        return NSMutableAttributedString(string: "No", attributes: attribute)
    }
}
//swiftlint:disable all
