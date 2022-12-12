//
//  DealerLotView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/5/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol IDealerLotView: AnyObject {
    func onViewDidLoad(_ lot: Catalog.Lot)
    func onViewWillAppear()
    func onViewDidAppear()
    func onViewWillDisappear()
    
    func fillWithLot(_ lot: DealerLot)
    func loadIndication(displayed: Bool)
}

private let estimatedRowHeight: CGFloat = 500.0

class DealerLotView: BaseViewController {
    var catalogLotViewModel: Catalog.LotViewModel?
    var lotViewModel: DealerLot?
    var presenter: IDealerLotPresenter!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    private var tableViewDataAdapter: DealerLotDataAdapter?
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    func bind(presenter: IDealerLotPresenter) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.onViewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.presenter.onViewWillDisappear()
        super.viewWillDisappear(animated)
    }
    
    override func keyboardWillBeShown() {
        super.keyboardWillBeShown()
        self.setBottomConstraintOnKeyboardShown(true)
    }
    
    override func keyboardWillBeHidden() {
        super.keyboardWillBeHidden()
        self.setBottomConstraintOnKeyboardShown(false)
    }
    
    @IBAction func backButtonPressed() {
        self.presenter.back()
    }
}

extension DealerLotView: IDealerLotView {
    func onViewDidLoad(_ catalogLot: Catalog.Lot) {
        self.catalogLotViewModel = Catalog.LotViewModel(lot: catalogLot, userType: .dealer)
        onMainQueue {
            
        }
    }
    
    func onViewWillAppear() {
        onMainQueue {
            super.appNavigationController?.setNavigationBar(hidden: false)
        }
    }
    
    func onViewDidAppear() {
        onMainQueue {
            
        }
    }
    
    func onViewWillDisappear() {
        onMainQueue {
            self.tableView.scrollToTop()
        }
    }
    
    func fillWithLot(_ lot: DealerLot) {
        self.configureTableViewWith(lot: lot)
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.mainContainer.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}

private extension DealerLotView {
    func setup() {
        self.title = nil
        self.loadIndication(displayed: false)
        self.setupDotsNavBarButton()
        self.setupTableView()
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
        
        alert.addAction(UIAlertAction(title: "Flag out", style: .destructive, handler: { [weak self] _ in
            self?.showConformFlagOut {
                self?.presenter.flagLot()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupTableView() {
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = estimatedRowHeight
        self.tableView.contentInsetAdjustmentBehavior = .never
    }
    
    func configureTableViewWith(lot: DealerLot) {
        self.tableViewDataAdapter = DealerLotDataAdapter(lot: lot)
        self.tableView.delegate = self.tableViewDataAdapter
        self.tableView.dataSource = self.tableViewDataAdapter
        self.tableViewDataAdapter?.actionHandler = { [weak self] actionType in
            switch actionType {
            case .flagOut:
                self?.presenter.flagLot()
            case .bid(let price, _):
                self?.showConformBidAlert(bid: price) {
                    self?.presenter.bid(price: price)
                }
            case .back:
                self?.presenter.back()
            }
        }
        self.tableView.reloadData()
    }
    
    func setBottomConstraintOnKeyboardShown(_ shown: Bool) {
        onMainQueue {
            UIView.animate(withDuration: 0.1) {
                self.tableViewBottomConstraint.constant = shown ? 230.0 : 20.0
                self.view.layoutIfNeeded()
                self.tableView.scrollToBottom()
            }
        }
    }
    
    private func showConformBidAlert(bid: Int, _ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        let totalPrice = Int((Float(bid) * 1.03).rounded(.up))
        let totalPriceString = String(totalPrice).currencyInputFormatting() ?? String(totalPrice)
        let bidString = String(bid).currencyInputFormatting() ?? String(bid)
        view.setup(subTitle: "Comfirm your bid?",
                   infoText: "$\(bidString)",
                   subMessage: "Total with WatchValue commission: $\(totalPriceString)",
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
    
    private func showConformFlagOut(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Please confirm that you want to flag this post",
                   subTitle: "We will review the post and seller.",
                   button1Title: "Flag out",
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
