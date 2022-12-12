//
//  SellerLotDetailVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 19.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import LBTATools
import Combine
import MGSwipeTableCell
//swiftlint:disable all
class SellerLotDetailVC: UITableViewController {
    
//    let carouselVC = CarouselVC()
    
    var lot: SellerLot? {
        didSet {
//            carouselVC.imageUrls = (lot?.imageUrls ?? []).map({ URL(string: API.baseUrl + $0.absoluteString)!})
            lot?.appraisals.sort(by: { (lhs, rhs) -> Bool in
                (lhs.price?.priceValue ?? 0) > (rhs.price?.priceValue ?? 0)
            })
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
    }
    
    func setupTableView() {
        tableView.register(CarouselCell.self, forCellReuseIdentifier: CarouselCell.reuseIdentifier())
        tableView.register(LotBriefCell.self, forCellReuseIdentifier: LotBriefCell.reuseIdentifier())
        tableView.register(LotDescriptionCell.self, forCellReuseIdentifier: LotDescriptionCell.reuseIdentifier())
        tableView.register(LotMoreDetailsCell.self, forCellReuseIdentifier: LotMoreDetailsCell.reuseIdentifier())
        tableView.register(LotStatusCell.self, forCellReuseIdentifier: LotStatusCell.reuseIdentifier())
        tableView.register(EmptyBidCell.self, forCellReuseIdentifier: EmptyBidCell.reuseIdentifier())
        tableView.register(BidCell.self, forCellReuseIdentifier: BidCell.reuseIdentifier())
        tableView.register(BidHeader.self, forHeaderFooterViewReuseIdentifier: BidHeader.reuseIdentifier())
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.sectionFooterHeight = 0
        tableView.backgroundColor = .white
        
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: .zero))
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: .zero))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 3 ? max((lot?.appraisals.count ?? 0), 1) : 1
//        section == 3 ? 6:1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CarouselCell.reuseIdentifier(), for: indexPath) as! CarouselCell
            cell.imageUrls = lot?.imageUrls ?? []
            cell.carouselView.heroID = "photo\(lot?.id ?? 0)"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotBriefCell.reuseIdentifier(), for: indexPath) as! LotBriefCell
            cell.nameLbl.text = lot?.label
            cell.refNoLbl.text = lot?.reference
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotStatusCell.reuseIdentifier(), for: indexPath) as! LotStatusCell
            cell.statusLbl.attributedText = lot?.statusAttributedString
            return cell
        case 3:
            if (lot?.appraisals.count ?? 0) > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: BidCell.reuseIdentifier(), for: indexPath) as! BidCell
//                cell.sellAction = {
//                    tableView.deselectRow(at: indexPath, animated: true)
//                }
                cell.appraisal = lot?.appraisals[indexPath.row]
                cell.priceLbl.textColor = indexPath.row == 0 ? Colors.cyanColor : Colors.blackTextColor
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyBidCell.reuseIdentifier(), for: indexPath) as! EmptyBidCell
//            return cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: BidCell.reuseIdentifier(), for: indexPath) as! BidCell
//            cell.sellAction = {
//                tableView.deselectRow(at: indexPath, animated: true)
//            }
//            cell.priceLbl.textColor = indexPath.row == 0 ? Colors.cyanColor : Colors.blackTextColor
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotDescriptionCell.reuseIdentifier(), for: indexPath) as! LotDescriptionCell
            cell.refNoView.value = lot?.reference
            cell.refNoView.isHidden = (lot?.reference == nil || (lot?.reference?.isEmpty ?? true))
            cell.yearView.isHidden = (lot?.year == nil || (lot?.year?.isEmpty ?? true))
            cell.yearView.value = lot?.year
            cell.paperView.value = lot?.documents == true ? "Yes" : "No"
            cell.boxView.value = lot?.box == true ? "Yes" : "No"
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotMoreDetailsCell.reuseIdentifier(), for: indexPath) as! LotMoreDetailsCell
            return cell
        default:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: BidHeader.reuseIdentifier()) as! BidHeader
            header.div.isHidden = (lot?.appraisals.count ?? 0) == 0
            return header
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 3 ? UITableView.automaticDimension : 0
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (tableView.cellForRow(at: indexPath) as? BidCell) != nil {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else {return }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = .white
    }
    
    var showAlertConfirmBid: ((Appraisal) -> ())?
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let action =  UIContextualAction(style: .normal, title: "", handler: { (action,view,completionHandler ) in
            guard indexPath.section == 3 else { return }
            guard let appraisal = self.lot?.appraisals[indexPath.row] else { return }
            self.showAlertConfirmBid?(appraisal)
            completionHandler(true)
        })

        action.image = #imageLiteral(resourceName: "sell_btn")
        action.title = "Sell"
        action.backgroundColor = UIColor(hex: "#F4F4F4")
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(hex: "#F4F4F4")
        let confrigation = UISwipeActionsConfiguration(actions: [action])
        
        return confrigation
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 3
    }
    
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
        
            return .none
    }
}


class LotStatusCell: UITableViewCell {
    
    let statusLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = Colors.grayDarkColor
        l.font = UIFont(name: FontNames.SFProText.regular, size: 14)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        l.attributedText = NSMutableAttributedString(string: "Status", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    let soldLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
        l.numberOfLines = 0
        l.font = UIFont(name: FontNames.SFProText.semibold, size: 14)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1
        l.attributedText = NSMutableAttributedString(string: "Please refer to the transaction confirmation email for information regarding the next steps", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
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
        
//        contentView.addSubview(statusLbl)
        contentView.stack(statusLbl,
              soldLbl,
              spacing: 8,
              alignment: .leading,
              distribution: .fill)
            .withMargins(UIEdgeInsets(top: 6, left: 16, bottom: 0, right: 16))
        
        statusLbl.setContentHuggingPriority(.defaultLow, for: .vertical)
        soldLbl.isHidden = true
//        statusLbl.fillSuperview(padding: UIEdgeInsets(top: 6, left: 16, bottom: 0, right: 16))
        selectionStyle = .none
    }
    
    
}

import SwipeCellKit

class BidCell: SwipeTableViewCell {
    let priceLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
        l.font = UIFont(name: "SFProDisplay-Bold", size: 24)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.05
        paragraphStyle.alignment = .center
        l.attributedText = NSMutableAttributedString(string: "$ 55,000", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    var appraisal: Appraisal! {
        didSet {
            priceLbl.text = appraisal.price
        }
    }
    
    var sellAction: (() -> ())?
    
    let div: UIView = {
        let v = UIView(backgroundColor: UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 0.05))
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupCell() {
        contentView.addSubview(priceLbl)
//        priceLbl.fillSuperview(padding: UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
//        NSLayoutConstraint.activate([
//            priceLbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            priceLbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
//            priceLbl.heightAnchor.constraint(equalToConstant: 30),
//            priceLbl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
//        ])
        priceLbl.centerInSuperview()
        contentView.addSubview(div.withHeight(1))
        div.anchor(top: nil, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyEditingModeBackgroundViewPositionCorrections()
    }
    
    func applyEditingModeBackgroundViewPositionCorrections() {
        if !self.isEditing { return }
        if ((self.backgroundView) != nil) {
            var backFrame = self.backgroundView?.frame
            backFrame?.origin.x = 0
            self.backgroundView?.frame = backFrame ?? .zero
            
        }
        if ((self.selectedBackgroundView) != nil) {
            var backFrame = self.selectedBackgroundView?.frame
            backFrame?.origin.x = 0
            self.selectedBackgroundView?.frame = backFrame ?? .zero
        }
    }
    
}

class BidHeader: UITableViewHeaderFooterView {
    
    let titleLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
        l.font = UIFont(name: "SFProText-Medium", size: 16)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        l.attributedText = NSMutableAttributedString(string: "Bids", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        return l
    }()
    
    let div: UIView = {
        let v = UIView(backgroundColor: UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 0.05))
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLbl.withHeight(21))
        titleLbl.fillSuperview(padding: UIEdgeInsets(top: 24, left: 16, bottom: 26, right: 16))
        contentView.addSubview(div.withHeight(1))
        div.anchor(top: nil, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class EmptyBidCell: UITableViewCell {
    
    let borderView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 6
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 0.05).cgColor
        return v
    }()
    
    let placeholderImgView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "no_bid")
        return iv
    }()
    
    let explainLbl: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(red: 0.624, green: 0.647, blue: 0.663, alpha: 1)
        l.font = UIFont(name: FontNames.SFProDisplay.regular, size: 16)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.1
        l.textAlignment = .center
        l.attributedText = NSMutableAttributedString(string: "You don't have bids yet", attributes: [NSAttributedString.Key.kern: -0.17, NSAttributedString.Key.paragraphStyle: paragraphStyle])
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
        contentView.addSubview(borderView)
        borderView.fillSuperview(padding: UIEdgeInsets(top: 5, left: 16, bottom: 34.22, right: 16))
        borderView.addSubview(placeholderImgView)
        placeholderImgView.anchor(top: borderView.topAnchor, leading: borderView.leadingAnchor, bottom: nil, trailing: borderView.trailingAnchor, padding: UIEdgeInsets(top: 11.95, left: 26.68, bottom: 0, right: 10.76))
        borderView.addSubview(explainLbl)
        explainLbl.centerXToSuperview()
        NSLayoutConstraint.activate([
            placeholderImgView.heightAnchor.constraint(equalTo: placeholderImgView.widthAnchor, multiplier: 181 / 305.56),
            explainLbl.topAnchor.constraint(equalTo: placeholderImgView.bottomAnchor, constant: 8),
            explainLbl.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -25.78)
        ])
        selectionStyle = .none
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct SellerLotDetailVCViewRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> SellerLotDetailVC {
        return SellerLotDetailVC()
    }

    func updateUIViewController(_ uiViewController: SellerLotDetailVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct SellerLotDetailVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            SellerLotDetailVCViewRepresentable().previewDevice(PreviewDevice(stringLiteral: "iPhone X"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }

    }
}
#endif


//swiftlint:disable all
