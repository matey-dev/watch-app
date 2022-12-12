//
//  FillLotFormData.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 16.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import Foundation
import UIKit
import MagazineLayout
//swiftlint:disable all
class FillLotFormData {
    var brand: Int?
    var model: String?
    var referenceNo: String?
    var year: String?
    var detail: String?
    var document: Bool = false
    var box: Bool = false
    
    var brands: [Brand] = []
    var images: [UIImage] = []
    
    var isValidBrand: Bool {
        (brand != -1) && brand != nil && brands.map({$0.id}).contains(brand)
    }
    
    var isValidModel: Bool {
        (model?.isEmpty != true) && model != nil
    }
    
    var isValidYear: Bool {
        guard let intYear = Int(year ?? "0") else { return false }
        let currentYear = Calendar.current.component(.year, from: Date())
        if intYear > currentYear || intYear < 1600 {
            return false
        } else {
            return true
        }
    }
    
    var triedToContinue: Bool = false
    
    var isValid: Bool {
        isValidBrand
    }
    
    var sections: [[FillLotFormItem]] {
        [
            [.brand(brand)],
            [.model(model)],
            [.referenceNo(referenceNo), .year(year)],
            [.detail(detail)],
            [.box(box)],
            [.document(document)]
        ]
    }
    
    func getCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> MagazineLayoutCollectionViewCell {
        let item = sections[indexPath.section][indexPath.row]
        switch item {
        case .brand(let brand):
//                        let brandName = self.brands.first(where: {$0.id == self.brand}).map({self.brands[$0]})
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillLotDropDownCell.reuseIdentifier(), for: indexPath) as! FillLotDropDownCell
            cell.titleLbl.text = item.title
            cell.brands = self.brands
            cell.brand = brand
            if !isValidBrand && triedToContinue {
                cell.asteriskView.tintColor = .red
            }
            cell.onAction {[weak self] action in
                switch action {
                case .select(let index):
                    self?.brand = index
                }
            }
            return cell
        case .model(let model):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillLotTextInfoCell.reuseIdentifier(), for: indexPath) as! FillLotTextInfoCell
            cell.textField.text = model
            cell.titleLbl.text = item.title
            cell.textField.keyboardType = .default
            cell.onValueChange = {[weak self] value in
                self?.model = value ?? ""
            }
            if !isValidModel && triedToContinue {
                cell.asteriskView.tintColor = .red
            }
            cell.asteriskView.isHidden = true
//            cell.setPlaceholder()
            return cell
        case .referenceNo(let refNo):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillLotTextInfoCell.reuseIdentifier(), for: indexPath) as! FillLotTextInfoCell
            cell.textField.text = refNo
            cell.titleLbl.text = item.title
            cell.asteriskView.isHidden = true
            cell.onValueChange = {[weak self] value in
                self?.referenceNo = value ?? ""
            }
//            cell.setPlaceholder()
            return cell
        case .year(let year):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillLotTextInfoCell.reuseIdentifier(), for: indexPath) as! FillLotTextInfoCell
            cell.textField.text = year
            cell.titleLbl.text = item.title
            cell.textField.keyboardType = .numberPad
            if !isValidYear && triedToContinue {
                cell.asteriskView.tintColor = .red
            }
            cell.asteriskView.isHidden = true
            cell.onValueChange = {[weak self] value in
                self?.year = value ?? ""
            }
            cell.setPlaceholder()
            return cell
        case .detail(let detail):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillLotDescriptionCell.reuseIdentifier(), for: indexPath) as! FillLotDescriptionCell
            cell.titleLbl.text = item.title
            cell.textView.text = detail
            cell.onValueChange = {[weak self] value in
                self?.detail = value ?? ""
                collectionView.collectionViewLayout.invalidateLayout()
            }
            return cell
        case .box(let check):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillLotCheckCell.reuseIdentifier(), for: indexPath) as! FillLotCheckCell
            cell.titleLbl.text = item.title
            cell.isChecked = check
            cell.onValueChange = {[weak self] value in
                self?.box = value
            }
            return cell
        case .document(let check):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillLotCheckCell.reuseIdentifier(), for: indexPath) as! FillLotCheckCell
            cell.titleLbl.text = item.title
            cell.isChecked = check
            cell.onValueChange = {[weak self] value in
                self?.document = value
            }
            return cell
        }
    }
}
//swiftlint:disable all
