//
//  LotDetailVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 17.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import LBTATools
import Combine
import Hero
//swiftlint:disable all
class LotDetailVC: UITableViewController {
    
    let carouselVC = CarouselVC()
    
    var fillLotFormData: FillLotFormData?
    
    var lot: SellerLot?
    
    init(formData: FillLotFormData) {
        self.fillLotFormData = formData
        carouselVC.images = formData.images
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.setNeedsUpdateConstraints()
    }
    
    var showImageAction: ((Int) -> ())?
    
    func setupTableView() {
        tableView.register(CarouselCell.self, forCellReuseIdentifier: CarouselCell.reuseIdentifier())
        tableView.register(LotBriefCell.self, forCellReuseIdentifier: LotBriefCell.reuseIdentifier())
        tableView.register(LotDescriptionCell.self, forCellReuseIdentifier: LotDescriptionCell.reuseIdentifier())
        tableView.register(LotMoreDetailsCell.self, forCellReuseIdentifier: LotMoreDetailsCell.reuseIdentifier())
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        (fillLotFormData?.detail == nil || (fillLotFormData?.detail?.isEmpty ?? true)) ? 3 : 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CarouselCell.reuseIdentifier(), for: indexPath) as! CarouselCell
            cell.images = fillLotFormData?.images ?? []
            cell.carouselView.selectedItemAction = {[weak self] index in
                self?.showImageAction?(index)
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotBriefCell.reuseIdentifier(), for: indexPath) as! LotBriefCell
            var brandStr = ""
            if let brand = fillLotFormData?.brand, brand > 0, brand < (fillLotFormData?.brands.count ?? 0) {
                brandStr = fillLotFormData?.brands.first(where: {$0.id == brand})?.label ?? ""
            }
            cell.nameLbl.text = "\(brandStr) \(fillLotFormData?.model ?? "")"
            cell.refNoLbl.text = fillLotFormData?.referenceNo
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotDescriptionCell.reuseIdentifier(), for: indexPath) as! LotDescriptionCell
            cell.refNoView.value = fillLotFormData?.referenceNo
            cell.yearView.value = fillLotFormData?.year
            cell.refNoView.isHidden = (fillLotFormData?.referenceNo == nil || (fillLotFormData?.referenceNo?.isEmpty ?? true))
            cell.yearView.isHidden = (fillLotFormData?.year == nil || (fillLotFormData?.year?.isEmpty ?? true))
            cell.paperView.value = fillLotFormData?.document == true ? "Yes" : "No"
            cell.boxView.value = fillLotFormData?.box == true ? "Yes" : "No"
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotMoreDetailsCell.reuseIdentifier(), for: indexPath) as! LotMoreDetailsCell
            cell.detailsLbl.text = fillLotFormData?.detail
            return cell
        default:
            fatalError()
        }
    }

}

class CarouselCell: UITableViewCell {
    
    let carouselView: CarouselView = {
        let v = CarouselView(frame: .zero)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var images: [UIImage] = [] {
        didSet {
            carouselView.images = images
        }
    }
    
    var imageUrls: [URL] = [] {
        didSet {
            carouselView.imageUrls = imageUrls
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCell() {
        contentView.clipsToBounds = true
        selectionStyle = .none
        contentView.addSubview(carouselView)
        carouselView.fillSuperview(padding: .allSides(16))
        carouselView.heightAnchor.constraint(equalTo: carouselView.widthAnchor, multiplier: 245.0 / 351.0).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        carouselView.heroID = nil
    }
}


class LotBriefCell: UITableViewCell {
    
    let nameLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
        l.font = UIFont(name: "SFProText-Semibold", size: 18)
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        l.attributedText = NSMutableAttributedString(string: "ROLEX Oyster Perpetual Date Submarine 100500", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    let refNoLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.561, green: 0.584, blue: 0.6, alpha: 1)
        l.font = UIFont(name: "SFProDisplay-Regular", size: 14)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.alignment = .right
        l.attributedText = NSMutableAttributedString(string: "4E5R21C", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCell() {
        contentView
            .hstack(nameLbl,
                    refNoLbl.withWidth(61),
                    spacing: 7,
                    alignment: .firstBaseline,
                    distribution: .fill).withMargins(UIEdgeInsets(top: 4, left: 16, bottom: 16, right: 16))
        selectionStyle = .none
    }
}


class LotDescriptionCell: UITableViewCell {
    
    let descriptionLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
        l.font = UIFont(name: "SFProText-Medium", size: 16)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        l.attributedText = NSMutableAttributedString(string: "Description", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    let refNoView = KeyValueView()
    let yearView = KeyValueView()
    let boxView = KeyValueView()
    let paperView = KeyValueView()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCell() {
        contentView.stack(descriptionLbl,
              hstack(refNoView,
                     hstack(yearView,
                            boxView,
                            paperView,
                            spacing: 10,
                            alignment: .fill,
                            distribution: .fillEqually),
                     spacing: 10,
                     alignment: .fill,
                     distribution: .fillProportionally),
              spacing: 8,
              alignment: .leading,
              distribution: .fill)
            .withMargins(UIEdgeInsets(top: 16, left: 17, bottom: 14, right: 17))
        yearView.key = "Year"
        yearView.value = "2009"
        boxView.key = "Box"
        boxView.value = "Yes"
        paperView.key = "Papers"
        paperView.value = "Yes"
        selectionStyle = .none
    }
    
    
    class KeyValueView: UIView {
        
        var key: String? {
            didSet {
                keyLbl.text = key
            }
        }
        
        var value: String? {
            didSet {
                valueLbl.text = value
            }
        }
        
        let keyLbl: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textColor = UIColor(red: 0.561, green: 0.584, blue: 0.6, alpha: 1)
            l.font = UIFont(name: "SFProText-Regular", size: 14)
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.44
            l.textAlignment = .center
            l.attributedText = NSMutableAttributedString(string: "Reference No", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            return l
        }()
        
        let valueLbl: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
            l.font = UIFont(name: "SFProText-Medium", size: 14)
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.14
            l.textAlignment = .center
            l.attributedText = NSMutableAttributedString(string: "C3PO", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            return l
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupView() {
            layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            layer.cornerRadius = 6
            layer.borderWidth = 1
            layer.borderColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 0.05).cgColor
            backgroundColor = .white
            stack(keyLbl, valueLbl, spacing: 5, alignment: .center, distribution: .fill).withMargins(UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8))
        }
    }
}

class LotMoreDetailsCell: UITableViewCell {
    
    let titleLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
        l.font = UIFont(name: "SFProText-Medium", size: 16)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        l.attributedText = NSMutableAttributedString(string: "More details", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    let detailsLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.561, green: 0.584, blue: 0.6, alpha: 1)
        l.font = UIFont(name: "SFProText-Regular", size: 14)
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.44
        l.attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCell() {
        contentView.stack(titleLbl,
              detailsLbl,
              spacing: 16,
              alignment: .leading,
            distribution: .fill)
            .withMargins(UIEdgeInsets(top: 10, left: 16, bottom: 14, right: 16))
        selectionStyle = .none
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct LotDetailVCViewRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> LotDetailVC {
        return LotDetailVC(formData: FillLotFormData())
    }

    func updateUIViewController(_ uiViewController: LotDetailVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct LotDetailVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            LotDetailVCViewRepresentable().previewDevice(PreviewDevice(stringLiteral: "iPhone X"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }

    }
}
#endif
//swiftlint:disable all
