//
//  CatalogView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Hero

enum CatalogViewState {
    case empty, some
}

protocol ICatalogView: AnyObject {
    var catalogType: CatalogType? { get set }
    
    func append(lots: [Catalog.Lot])
    func set(lots: [Catalog.Lot])
    func insertTop(lot: Catalog.Lot)
    func onViewDidLoad()
    func onViewWillAppear()
    
    func scrollToTop()
    
    func setArchiveButton(notificated: Bool)
    
    var presenter: ICatalogPresenter! { get }
}

enum CatalogViewMode: String {
    case home = "Home"
    case archive = "Archive"
}

class CatalogView: BaseViewController {
    private var state: CatalogViewState = .empty
    var userType: UserType?
    var catalogType: CatalogType?
    var presenter: ICatalogPresenter!
    
    var viewMode: CatalogViewMode = .home
    
    @IBOutlet weak var viewModeLblContainer: UIView!
    @IBOutlet weak var viewModeLbl: UILabel!
    @IBOutlet weak var emptyPlaceholderLabel: UILabel!
    
    @IBOutlet weak var emptyPlaceHolderContainer: UIView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var topLogo: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var archiveButtonContainer: UIView!
    var archiveButtonNotificated: Bool = false
    @IBOutlet weak var filterButtonContainer: UIView!
    
    @IBOutlet weak var emptyPlaceholderContainer: UIView!
    @IBOutlet weak var tableViewContainer: CatalogTableView!
    
    @IBOutlet weak var emptyContentSecondLbl: UILabel!
    
    var profileService: ProfileAPIService?
    
    func bind(presenter: ICatalogPresenter) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.presenter.onViewDidLoad()
        viewModeLbl.text = viewMode.rawValue
        viewModeLbl.font = viewMode != .archive ? UIFont(name: "HelveticaNeue-Bold", size: 32) : UIFont(name: "SFProText-Bold", size: 32)
        
        self.navigationController?.delegate = self
        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
        archiveButtonContainer.isHidden = userType == .dealer
        viewModeLblContainer.isHidden = userType == .dealer
        if let userType = userType {
            profileService = ProfileAPIService(userType: userType)
        }
        
        //        navigationController?.hero.navigationAnimationType = .selectBy(presenting: .zoomSlide(direction: .right), dismissing:.zoomSlide(direction: .left))
//        if (viewMode != .archive) {
//            UNUserNotificationCenter.current().getNotificationSettings { settings in
//                print("APNS Notification settings: \(settings)")
//
//                guard settings.authorizationStatus == .authorized else { return }
//                let alert = UIAlertController(title: "Let Us Send You Push Notifications?", message: "Get notified about activities with your watches and bids.", preferredStyle: .alert)
//                let cancel = UIAlertAction(title: "No, Thanks", style: .cancel, handler: nil)
//                let ok = UIAlertAction(title: "Yes, please", style: .default) { (_) in
//                    PushService.shared.registerForPushNotifications()
//                }
//                alert.addAction(cancel)
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            PushService.shared.sendCurrentTokenToBack()
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: NSNotification.Name("newLot"), object: nil)
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        if let formdata = notification.object as? FillLotFormData {
            let sellerLot = SellerLot(tempData: formdata)
            tempLot = sellerLot
            let lot = Catalog.Lot(sellerLot: sellerLot)
            self.insertTop(lot: lot)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.onViewWillAppear()
        hero.isEnabled = true
        navigationController?.hero.isEnabled = true
        self.tableViewContainer.endRefreshing()
        profileService?.getProfile(completion: {[weak self] (result) in
            switch result {
            case .success(let profileResponse):
                if let src = profileResponse.avatar.first?.src, let url = URL(string: API.baseUrl + src) {
                    self?.avatarImageView.setImage(withUrl: url)
                }
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
    fileprivate let heroTransition = HeroTransition()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hero.isEnabled = false
        navigationController?.hero.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func archiveButtonAction(_ sender: Any) {
        self.presenter.archiveButtonPressed()
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {
        self.presenter.filterButtonPressed()
    }
}

extension CatalogView: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            return heroTransition.navigationController(navigationController, interactionControllerFor: animationController)
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return heroTransition.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}

private extension CatalogView {
    func setup() {
//        super.appNavigationController?.setNavigationBar(hidden: true, animated: false)
        
        self.title = nil
//        self.setupTopContainer()
        self.avatarImageView.layer.cornerRadius = 19
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.contentMode = .scaleAspectFill
        self.catalogType.map { catalogType in
            if catalogType == .newSubmissions {
                self.emptyPlaceholderLabel.text = "Congrats!"
                self.emptyContentSecondLbl.text = "There’s nothing left to appraise."
            }
        }
        
        self.catalogType.map {
            switch $0 {
            case .newSubmissions: // dealer
                self.filterButtonContainer.isHidden = false
//                self.archiveButtonContainer.isHidden = false
                self.tableViewContainer.cellType = .big
            case .appraisals: // dealer
                self.filterButtonContainer.isHidden = true
//                self.archiveButtonContainer.isHidden = false
                self.tableViewContainer.cellType = .general
            case .yourCatalogue: // seller
                self.filterButtonContainer.isHidden = true
                self.archiveButtonContainer.isHidden = false
                self.tableViewContainer.cellType = .big
            }
        }
        
        self.setState(.some)
        
        self.tableViewContainer.userType = self.userType
        self.tableViewContainer.type = viewMode == .home ? .general : .archive
        self.tableViewContainer.cellSwipeActions = [.delete]
        self.tableViewContainer.allowsSelection = true
        self.tableViewContainer.onAction { [weak self] actionType in
            switch actionType {
            case .selectedLot(let lot):
                self?.saveTopLogoPosition()
                self?.presenter.selectedLot(lot)
            case .refreshData:
                self?.presenter.refreshData(andShowFirst: false)
            case .emptyDataSource:
                self?.setState(.empty)
            case .deleteLot(let id):
                self?.showDeleteLotAlert {
                    self?.presenter.deleteLot(id: id, completion: {
                        self?.tableViewContainer.deleteLot(id: id)
                    })
                }
            }
        }
        self.tableViewContainer.preloadAction { [weak self] in
            guard let self = self else { return }
            let countOfItems = self.tableViewContainer.countOfItems
            self.presenter.preload(after: countOfItems)
        }
        
        emptyPlaceHolderContainer.layer.borderColor = UIColor(hex: "#202020").withAlphaComponent(0.05).cgColor
        emptyPlaceHolderContainer.layer.borderWidth = 1
    }
    
    func setState(_ state: CatalogViewState) {
        self.state = state
        switch state {
        case .some:
            self.tableViewContainer.isHidden = false
            self.emptyPlaceholderContainer.isHidden = true
            //self.archiveButton.isEnabled = true
        case .empty:
            self.tableViewContainer.isHidden = true
            self.emptyPlaceholderContainer.isHidden = false
            //self.archiveButton.isEnabled = false
        }
    }
    
    func setupTopContainer() {
        self.topContainer.backgroundColor = Colors.white_65opacity
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
//        blurView.alpha = 0.5
        self.topContainer.insertSubview(blurView, at: 0)
        blurView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-50)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
    
    func saveTopLogoPosition() {
        let rectOfLogoInWindow = self.topLogo.convert(self.topLogo.bounds, to: self.topLogo.window)
        AnimationStorage.shared.logoImage = rectOfLogoInWindow
    }
    
    /*func setupTopContainer() {
        let containers = [self.topContainer,
                          self.underSafeAreaContainer]
        
        containers.forEach {
            $0?.backgroundColor = .clear
            
            let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blur)
            $0?.insertSubview(blurView, at: 0)
            blurView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
        }
    }*/
}

extension CatalogView: ICatalogView {
    func onViewDidLoad() {
        onMainQueue {
            self.setup()
        }
    }
    
    func onViewWillAppear() {
        self.setArchiveButton(notificated: self.archiveButtonNotificated)
        onMainQueue {
            super.appNavigationController?.setNavigationBar(hidden: true, animated: false)
            if self.state == .empty {
                self.presenter.refreshData(andShowFirst: false)
            }
        }
    }
    
    func append(lots: [Catalog.Lot]) {
        self.tableViewContainer.dataAdapter.append(lots: lots)
        onMainQueue {
            self.setState(self.tableViewContainer.dataAdapter.isEmpty ? .empty : .some)
            self.tableViewContainer.reloadData()
        }
    }
    
    func insertTop(lot: Catalog.Lot) {
        self.tableViewContainer.dataAdapter.insertTop(lot: lot)
        onMainQueue {
            self.setState(self.tableViewContainer.dataAdapter.isEmpty ? .empty : .some)
            self.tableViewContainer.reloadData()
        }
    }
    
    func set(lots: [Catalog.Lot]) {
        self.tableViewContainer.dataAdapter.clear()
        self.tableViewContainer.dataAdapter.append(lots: lots)
        onMainQueue {
            self.setState(self.tableViewContainer.dataAdapter.isEmpty ? .empty : .some)
            self.tableViewContainer.reloadData()
            self.tableViewContainer.endRefreshing()
        }
    }
    
    func setArchiveButton(notificated: Bool) {
        self.archiveButtonNotificated = notificated
        onMainQueue {
            guard self.isViewLoaded else { return }
            //TODO: - Avatar
            
//            self.archiveButtonImage.image = notificated ? UIImage(named: "bar-icon-menu-dot") : UIImage(named: "bar-icon-menu")
        }
    }
    
    func scrollToTop() {
        self.tableViewContainer.tableView.scrollToTop()
    }
}

private extension CatalogView {
    func showDeleteLotAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Are you sure you want to delete this post?",
                   subTitle: "This post will be permanently removed",
                   button1Title: "Confirm")
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
