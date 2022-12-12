//
//  LotView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum SellerLotViewState {
    case none
    case new
    case sold
    case shipping
    case appraised
    
    init(state: SellerLot.Status) {
        switch state {
        case .deleted:
            self = .none
        case .new:
            self = .new
        case .appraised:
            self = .appraised
        case .sold:
            self = .sold
        case .shippedForAuthentication:
            self = .shipping
        case .verified:
            self = .none
        case .notVerified:
            self = .none
        }
    }
}

protocol ISellerLotView: AnyObject {
    func onViewDidLoad(_ lot: Catalog.Lot)
    func onViewWillAppear()
    
    func fillWithLot(_ lot: SellerLot)
    func loadIndication(displayed: Bool)
    func betSuccessfullyChosen()
    
    func setShouldReload(_ value: Bool)
}

class SellerLotView: BaseViewController {
    private var state: SellerLotViewState?
    var catalogLotViewModel: Catalog.LotViewModel?
    var lotViewModel: SellerLot?
    var presenter: ISellerLotPresenter!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var noneStateContainer: UIView!
    @IBOutlet weak var soldStateContainer: UIView!
    @IBOutlet weak var shippedStateContainer: UIView!
    @IBOutlet weak var newStateContainer: UIView!
    @IBOutlet weak var appraisedStateContainer: UIView!
    @IBOutlet weak var appraisalsTableView: UITableView!
    private var appraisalsDataAdapter: AppraisalsDataAdapter?
    
    @IBOutlet weak var descView: SellerLotDescriptionView!
    
    func bind(presenter: ISellerLotPresenter) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.presenter.onViewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.onViewWillAppear()
    }
    
    @IBAction func doneButtonOnSoldStatePressed(_ sender: UIButton) {
        self.presenter.doneButtonOnSoldState()
    }
}

extension SellerLotView: ISellerLotView {
    func setShouldReload(_ value: Bool) {
        
    }
    
    func onViewDidLoad(_ catalogLot: Catalog.Lot) {
        let model = Catalog.LotViewModel(lot: catalogLot, userType: .seller)
        self.catalogLotViewModel = model
        self.descView.configure(with: model)
        model.lot.sellerStatus.map { status in
            if status == .new {
                self.setupDotsNavBarButton()
            }
        }
        
        
    }
    
    func onViewWillAppear() {
        onMainQueue {
            super.appNavigationController?.setNavigationBar(hidden: false)
        }
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.mainContainer.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
    
    func fillWithLot(_ lot: SellerLot) {
        guard let status = lot.status else { return }
        self.catalogLotViewModel?.lot.sellerStatus = status
        self.catalogLotViewModel.map {
            self.descView.configure(with: $0)
        }
        let state = SellerLotViewState(state: status)
        self.setState(state)
        if state == .appraised {
            self.setupAppraisalsTableView(appraisals: lot.appraisals)
        }
        
    }
    
    func betSuccessfullyChosen() {
        self.setState(.sold)
    }
}

private extension SellerLotView {
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
        switch state {
        case .none:
            self.noneStateContainer.isHidden = false
            self.newStateContainer.isHidden = true
            self.soldStateContainer.isHidden = true
            self.shippedStateContainer.isHidden = true
            self.appraisedStateContainer.isHidden = true
        case .new:
            self.newStateContainer.isHidden = false
            self.noneStateContainer.isHidden = true
            self.soldStateContainer.isHidden = true
            self.shippedStateContainer.isHidden = true
            self.appraisedStateContainer.isHidden = true
        case .shipping:
            self.shippedStateContainer.isHidden = false
            self.soldStateContainer.isHidden = true
            self.newStateContainer.isHidden = true
            self.noneStateContainer.isHidden = true
            self.appraisedStateContainer.isHidden = true
        case .sold:
            self.soldStateContainer.isHidden = false
            self.newStateContainer.isHidden = true
            self.noneStateContainer.isHidden = true
            self.shippedStateContainer.isHidden = true
            self.appraisedStateContainer.isHidden = true
        case .appraised:
            self.appraisedStateContainer.isHidden = false
            self.newStateContainer.isHidden = true
            self.soldStateContainer.isHidden = true
            self.shippedStateContainer.isHidden = true
            self.noneStateContainer.isHidden = true
        }
    }
    
    func setupAppraisalsTableView(appraisals: [Appraisal]) {
        self.appraisalsTableView.rowHeight = UITableView.automaticDimension
        self.appraisalsTableView.estimatedRowHeight = 500.0
        
        self.appraisalsTableView.separatorStyle = .singleLine
        self.appraisalsTableView.allowsSelectionDuringEditing = false
        self.appraisalsTableView.allowsSelection = false
        self.appraisalsTableView.allowsMultipleSelection = false
        
        self.appraisalsDataAdapter = AppraisalsDataAdapter(appraisals: appraisals,
                                                           tableView: self.appraisalsTableView)
        self.appraisalsTableView.delegate = self.appraisalsDataAdapter
        self.appraisalsTableView.dataSource = self.appraisalsDataAdapter
        self.appraisalsDataAdapter?.onAction { [ weak self] actionType in
            guard let self = self else { return }
            switch actionType {
            case .approve(let appraisal):
                //self.appraisalsTableView.reloadData()
                guard let price = appraisal.price else { return }
                self.showConfirmBidAlert(bid: price) {
                    self.presenter.approveAppraisal(appraisal)
                }
            }
        }
    }
}

private extension SellerLotView {
    func showConfirmBidAlert(bid: String, _ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(subTitle: "Confirm bid?",
                   infoText: bid,
                   button1Title: "Approve",
                   button2Title: "Cancel",
                   button1Style: .black,
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
