//
//  SellerLotInfoVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 18.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import LBTATools
import MagazineLayout
import Combine
import SwipeCellKit
import ImageViewer
import Kingfisher
//swiftlint:disable all

typealias SellerLotInfoVCAction = ((SellerLotInfoVCActionType) -> Void)

enum SellerLotInfoVCActionType {
    case back
    case backAndReload
}

class SellerLotInfoVC: UIViewController {
    
    let detailVC = SellerLotDetailVC(style: .grouped)
    
    private var state: SellerLotViewState?
    var catalogLotViewModel: Catalog.LotViewModel?
    var lotViewModel: SellerLot?
    var presenter: ISellerLotPresenter!
    var catalogLot: Catalog.Lot
    
    private let lotAPIService = SellerLotAPIService()
    private let deleteLotAPIService = DeleteLotAPIService()
    
    var imageView1 = UIImageView()
    var imageView2 = UIImageView()
    var imageView3 = UIImageView()
    var imageView4 = UIImageView()
    var imageView5 = UIImageView()
    
    
    var imageViews: [UIImageView] {
        [imageView1, imageView2, imageView3, imageView4, imageView5]
    }
    
    var lot: SellerLot? {
        didSet {
            lot?.appraisals.sort(by: { (lhs, rhs) -> Bool in
                (lhs.price?.priceValue ?? 0) > (rhs.price?.priceValue ?? 0)
            })
            guard let lot = lot else { return }
            self.items = []
            if lot.imageUrls.count == 0 {
                for index in 0..<lot.tempImages.count {
                    guard index < self.imageViews.count else {
                        return
                    }
                    let galleryItem = GalleryItem.image { (imageCompletion) in
                        
                        self.imageViews[index].image = lot.tempImages[index]
                        imageCompletion(lot.tempImages[index])
                    }
                    self.items.append(DataItem(imageView: self.imageViews[index], galleryItem: galleryItem))
                }
            } else {
                for index in 0..<lot.imageUrls.count {
                    guard index < self.imageViews.count else {
                        return
                    }
                    let galleryItem = GalleryItem.image { imageCompletion in
                        
                        self.imageViews[index].kf.setImage(with: URL(string: API.baseUrl + lot.imageUrls[index].absoluteString)!, placeholder: nil, options: nil) { (result) in
                            switch result{
                            case .success(let imgResult):
                                imageCompletion(imgResult.image)
                            case .failure(let error):
                                print(error.localizedDescription)
                                
                            }
                        }
                    }
                    self.items.append(DataItem(imageView: self.imageViews[index], galleryItem: galleryItem))
                }
            }
            
            
            tableView.reloadData()
        }
    }
    
    func bind(presenter: ISellerLotPresenter) {
        self.presenter = presenter
    }
    
    init(catalogLot: Catalog.Lot) {
        self.catalogLot = catalogLot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.allowsSelection = true
        tv.sectionFooterHeight = 0
        tv.backgroundColor = .white
        tv.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: .leastNormalMagnitude)))
        tv.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: .leastNormalMagnitude)))
        tv.sectionHeaderHeight = UITableView.automaticDimension
        return tv
    }()
    
    let backBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        //        b.tintColor = UIColor(hex: "#8F9599")
        b.setImage(#imageLiteral(resourceName: "arrow-back"), for: .normal)
        return b
    }()
    
    let navBar: UIView = {
        let v = UIView(backgroundColor: .white)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    let activityIndicator: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.color = .darkGray
        return s
    }()
    
    var items: [DataItem] = []
    
    var onAction: SellerLotInfoVCAction?
    func onAction(_ callback: SellerLotInfoVCAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavBar()
        setupTableView()
        setupAction()
        detailVC.showAlertConfirmBid = { appraisal in
            self.showConfirmBidAlert(bid: appraisal.price ?? "") {
                self.presenter.approveAppraisal(appraisal)
            }
        }
        self.presenter.onViewDidLoad()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(navBar)
        navBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 48))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.onViewWillAppear()
//        tableView.reloadData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0))
        view.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
        
        tableView.register(CarouselCell.self, forCellReuseIdentifier: CarouselCell.reuseIdentifier())
        tableView.register(LotBriefCell.self, forCellReuseIdentifier: LotBriefCell.reuseIdentifier())
        tableView.register(LotDescriptionCell.self, forCellReuseIdentifier: LotDescriptionCell.reuseIdentifier())
        tableView.register(LotMoreDetailsCell.self, forCellReuseIdentifier: LotMoreDetailsCell.reuseIdentifier())
        tableView.register(LotStatusCell.self, forCellReuseIdentifier: LotStatusCell.reuseIdentifier())
        tableView.register(EmptyBidCell.self, forCellReuseIdentifier: EmptyBidCell.reuseIdentifier())
        tableView.register(BidCell.self, forCellReuseIdentifier: BidCell.reuseIdentifier())
        tableView.register(BidHeader.self, forHeaderFooterViewReuseIdentifier: BidHeader.reuseIdentifier())
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupNavBar() {
        let titleLbl = UILabel(text: "Lot details", font: UIFont(name: FontNames.Raleway.semibold, size: 18), textColor: UIColor(hex: "#8F9599"), textAlignment: .center, numberOfLines: 1)
        navBar.addSubview(backBtn)
        backBtn.anchor(top: navBar.topAnchor, leading: navBar.leadingAnchor, bottom: navBar.bottomAnchor, trailing: nil, size: CGSize(width: 56, height: 48))
        navBar.addSubview(titleLbl)
        titleLbl.centerInSuperview()
    }
    
    private func setupAction() {
        self.backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    
    var shouldReload = false
    @objc func back() {
        if shouldReload {
            self.onAction?(.backAndReload)
        } else {
            self.onAction?(.back)
        }
    }
    
    var showAlertConfirmBid: ((Appraisal) -> ())?
    
    
    func showError(title: String,
                   message: String) {
        onMainQueue {
            self.showAlert(title: title,
                           message: message)
        }
    }
    
    private func imageTapped(index: Int) {
        let galleryVC = GalleryViewController(startIndex: index, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: nil, configuration: galleryConfiguration())
        presentImageGallery(galleryVC)
    }
    
    private func imageTapped(imageUrl: URL){
        let imgView = UIImageView()
        let galleryItem = GalleryItem.image { imageCompletion in
            imgView.kf.setImage(with: imageUrl, placeholder: nil, options: nil,
                                progressBlock: nil, completionHandler: { result in
                                    switch result {
                                    case .success(let imgResult):
                                        imageCompletion(imgResult.image)
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
            })

        }
        self.items = [DataItem(imageView: imgView, galleryItem: galleryItem)]
        let galleryVC = GalleryViewController(startIndex: 0, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: nil, configuration: galleryConfiguration())
        presentImageGallery(galleryVC)
    }
    
    private func galleryConfiguration() -> GalleryConfiguration {
        return [.swipeToDismissMode(.never),  .thumbnailsButtonMode(.none), .deleteButtonMode(.none)]
    }
    
}

extension SellerLotInfoVC: GalleryItemsDataSource {
    func itemCount() -> Int {
        return items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return items[index].galleryItem
    }
}

extension SellerLotInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
//        (lot?.status == .sold ? 3 : 4) + ((lot?.description == nil || lot?.description == "") ? 0 : 1)
        
        if lot?.status == .sold {
            if (lot?.description == nil || lot?.description == "") {
                return 4
            } else {
                return 5
            }
        } else {
            if (lot?.description == nil || lot?.description == "") {
                return 5
            } else {
                return 6
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 3 ? (max((lot?.appraisals.count ?? 0), 1)) : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: CarouselCell.reuseIdentifier(), for: indexPath) as! CarouselCell
            cell.carouselView.heroID = "photo\(lot?.id ?? 0)"
            if lot?.imageUrls.count == 0 {
                cell.images = lot?.tempImages ?? []
            } else {
                cell.imageUrls = (lot?.imageUrls ?? []).map({ URL(string: API.baseUrl + $0.absoluteString)!})
            }
            
            cell.carouselView.selectedItemAction = { [weak self] index in
                self?.imageTapped(index: index)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotBriefCell.reuseIdentifier(), for: indexPath) as! LotBriefCell
            cell.nameLbl.text = lot?.label
            cell.refNoLbl.text = lot?.reference
            cell.nameLbl.heroID = "name\(lot?.id ?? 0)"
            cell.refNoLbl.heroID = "ref\(lot?.id ?? 0)"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: LotStatusCell.reuseIdentifier(), for: indexPath) as! LotStatusCell
            
            cell.statusLbl.attributedText = catalogLotViewModel?.statusAttributedString
            cell.soldLbl.isHidden = lot?.status != .sold
            cell.statusLbl.heroID = "status\(lot?.id ?? 0)"
            return cell
        case 3:
            if lot?.status == .sold {
                let cell = tableView.dequeueReusableCell(withIdentifier: LotDescriptionCell.reuseIdentifier(), for: indexPath) as! LotDescriptionCell
                cell.refNoView.value = lot?.reference
                cell.refNoView.isHidden = (lot?.reference == nil || (lot?.reference?.isEmpty ?? true))
                cell.yearView.isHidden = (lot?.year == nil || (lot?.year?.isEmpty ?? true))
                cell.yearView.value = lot?.year
                cell.paperView.value = lot?.documents == true ? "Yes" : "No"
                cell.boxView.value = lot?.box == true ? "Yes" : "No"
                return cell
            }
            if (lot?.appraisals.count ?? 0) > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: BidCell.reuseIdentifier(), for: indexPath) as! BidCell
                cell.appraisal = lot?.appraisals[indexPath.row]
                cell.priceLbl.textColor = indexPath.row == 0 ? Colors.cyanColor : Colors.blackTextColor
                cell.delegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyBidCell.reuseIdentifier(), for: indexPath) as! EmptyBidCell
            return cell
        case 4:
            if lot?.status == .sold {
                let cell = tableView.dequeueReusableCell(withIdentifier: LotMoreDetailsCell.reuseIdentifier(), for: indexPath) as! LotMoreDetailsCell
                cell.detailsLbl.text = lot?.description
                return cell
            }
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
            cell.detailsLbl.text = lot?.description
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3 && lot?.status != .sold {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: BidHeader.reuseIdentifier()) as! BidHeader
            header.div.isHidden = (lot?.appraisals.count ?? 0) == 0
            return header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 3 ? UITableView.automaticDimension : 0
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (tableView.cellForRow(at: indexPath) as? BidCell) != nil {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else {return }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = .white
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? BidCell {
            cell.showSwipe(orientation: .right)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action =  UIContextualAction(style: .normal, title: "", handler: { (action,view,completionHandler ) in
            guard indexPath.section == 3, self.lot?.status != .sold else { return }
            guard let appraisal = self.lot?.appraisals[indexPath.row] else { return }
            guard let price = appraisal.price else { return }
            self.showConfirmBidAlert(bid: price) {
                self.presenter.approveAppraisal(appraisal)
            }
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 3 && (lot?.appraisals.count ?? 0) > 0 && self.lot?.status != .sold
    }
    
    func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
            return .none
    }
}

extension SellerLotInfoVC: SwipeTableViewCellDelegate, SwipeActionTransitioning {
    func didTransition(with context: SwipeActionTransitioningContext) {
        context.setBackgroundColor(.white)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let cell = tableView.cellForRow(at: indexPath) as? BidCell else { return nil }
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            guard indexPath.section == 3, self.lot?.status != .sold else { return }
            guard let appraisal = self.lot?.appraisals[indexPath.row] else { return }
            guard let price = appraisal.price else { return }
            self.showConfirmBidAlert(bid: price) {
                self.presenter.approveAppraisal(appraisal)
            }
        }
        
        cell.contentView.backgroundColor = UIColor(hex: "#F4F4F4")
        deleteAction.image = #imageLiteral(resourceName: "sell_btn")
        deleteAction.backgroundColor = UIColor(hex: "#F4F4F4")
        deleteAction.transitionDelegate = self
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        guard let indexPath = indexPath else { return }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = .white
    }
}

extension SellerLotInfoVC: ISellerLotView {
    
    func setShouldReload(_ value: Bool) {
        self.shouldReload = value
    }
    
    func onViewDidLoad(_ catalogLot: Catalog.Lot) {
        let model = Catalog.LotViewModel(lot: catalogLot, userType: .seller)
        self.catalogLotViewModel = model
//        self.descView.configure(with: model)
        model.lot.sellerStatus.map { status in
            if status == .new {
                self.setupDotsNavBarButton()
            }
        }
    }
    
    func onViewWillAppear() {
        onMainQueue {
//            super.appNavigationController?.setNavigationBar(hidden: false)
        }
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.view.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    func fillWithLot(_ lot: SellerLot) {
        guard let status = lot.status else { return }
        self.catalogLotViewModel?.lot.sellerStatus = status
        self.lot = lot
        let state = SellerLotViewState(state: status)
        self.setState(state)
        
    }
    
    func betSuccessfullyChosen() {
        self.setState(.sold)
    }
}

private extension SellerLotInfoVC {
    func setup() {
        self.title = nil
        self.setState(.none)
        self.loadIndication(displayed: false)
    }
    
    func setupDotsNavBarButton() {
        let rightButton = UIBarButtonItem(image: UIImage(named: "buttonThreeDots"),
                                          style: .done,
                                          target: self,
                                          action: #selector(handleThreeDotsButton))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func handleThreeDotsButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = Colors.blackLight
        
        alert.addAction(UIAlertAction(title: "Delete post", style: .destructive, handler: { [weak self] _ in
            self?.showConfirmDeleteLotAlert {
                self?.presenter.deleteCurrentLot()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setState(_ state: SellerLotViewState) {
        self.state = state
        
    }
    
}

private extension SellerLotInfoVC {
    func showConfirmBidAlert(bid: String, _ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Are you sure you want\nto sell your watch?",
                   subTitle: "This action can’t be undone",
                   infoText: nil,
                   button1Title: "Cancel",
                   button2Title: "Yes, sell",
                   button1Style: .white,
                   button2Style: .black,
                   dismissButtonIsHidden: true)
        view.onAction { actionType in
            switch actionType {
            case .two:
                confirm?()
            default: ()
            }
        }
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
    
    func showConfirmDeleteLotAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Are you shure you want to delete this post?",
                   subTitle: "The post will be removed from the market",
                   button1Title: "Delete post",
                   button2Title: "Cancel",
                   button1Style: .red,
                   button2Style: .white,
                   dismissButtonIsHidden: true)
        view.onAction { actionType in
            switch actionType {
            case .one:
                confirm?()
            default: ()
            }
        }
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
}
