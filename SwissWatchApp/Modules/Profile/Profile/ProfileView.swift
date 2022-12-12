//
//  ProfileView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
//swiftlint:disable all
protocol IProfileView: AnyObject {
    func onViewDidLoad()
    func onViewWillAppear()
    func updateWith(profile: Profile)
    func removeConfirmButton()
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String]
    func loadIndication(displayed: Bool)
}

private let estimatedRowHeight: CGFloat = 44

class ProfileView: BaseViewController {
    var state: UserType?
    var presenter: IProfilePresenter!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var backButtunContainer: UIView!
    var tableViewDataAdapter: ProfileDataAdapter?
    var profile: Profile? {
        didSet {
            tableView.reloadData()
        }
    }
    
    func bind(presenter: IProfilePresenter) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.onViewDidLoad()
        self.presenter.onViewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.onViewWillAppear()
    }
    
    @IBAction func didTapBackBtn(_ sender: Any) {
        self.presenter.back()
//        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ProfileView: IProfileView {
    func onViewDidLoad() {
        onMainQueue {
            self.backButtunContainer.isHidden = self.state == .dealer
            self.tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size:  CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)))
        }
    }
    
    func onViewWillAppear() {
        onMainQueue {
            self.presenter.onViewWillAppear()
        }
    }
    
    func updateWith(profile: Profile) {
//        self.setupDataAdapter(profile: profile)
        self.profile = profile
    }
    
    func removeConfirmButton() {
        self.tableViewDataAdapter.map { tvDataAdapter in
            tvDataAdapter.isShouldShowConfirmButton = false
            self.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.tableView.setContentOffset(.zero, animated: true)
            }
        }
    }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        return dict
    }
    //        var cantFind = dict
    //        let oldPasswordKey = "old_password"
    //        let passwordKey = "new_password"
    //        let passwordConfirmKey = "new_password_confirm"
    //        let keys = [oldPasswordKey, passwordKey, passwordConfirmKey]
    //        keys.forEach { key in
    //            let message = dict.first(where: { $0.key == key })?.value
    //            onMainQueue {
    //                if key == oldPasswordKey {
    //                    self.oldPasswordTextField.error = message
    //                } else if key == passwordKey {
    //                    self.passwordTextField.error = message
    //                } else if key == passwordConfirmKey {
    //                    self.passwordConfirmTextField.error = message
    //                }
    //            }
    //            cantFind[key] = nil
    //        }
    //        return cantFind
    //    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            
        }
    }
}

extension ProfileView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 5 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileHeaderCell.reuseIdentifier(), for: indexPath) as! ProfileHeaderCell
                let firstName = profile?.firstName ?? ""
                let lastName = profile?.lastName ?? ""
                
                cell.userNameLbl.text = firstName + " " + lastName
                cell.emailLbl.text = profile?.email
                if let src = profile?.avatar {
                    cell.photoView.setImage(withUrl: URL(string: API.baseUrl + src)!)
                }
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMainCell.reuseIdentifier(), for: indexPath) as! ProfileMainCell
                cell.titleLbl.text = "Edit profile"
                cell.tapAction = {
                    self.presenter.editProfile()
                }
                return cell
//            case 2:
//                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMainCell.reuseIdentifier(), for: indexPath) as! ProfileMainCell
//                cell.titleLbl.text = "Nofication"
//                cell.tapAction = {
//                    self.presenter.showNotification()
//                }
//                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMainCell.reuseIdentifier(), for: indexPath) as! ProfileMainCell
                cell.titleLbl.text = "Archive"
                cell.tapAction = {
                    self.presenter.showArchiveList()
                }
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSeperatorCell.reuseIdentifier(), for: indexPath) as! ProfileSeperatorCell
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMainCell.reuseIdentifier(), for: indexPath) as! ProfileMainCell
                cell.titleLbl.text = "Legal information"
                cell.tapAction = {
                    self.presenter.showLegalInfo()
                }
                return cell
            }
        default:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileLogoutCell.reuseIdentifier(), for: indexPath) as! ProfileLogoutCell
                cell.tapAction = {
                    self.presenter.logout()
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileDeleteAccoutCell.reuseIdentifier(), for: indexPath) as! ProfileDeleteAccoutCell
                cell.tapAction = {
                    self.showDeleteAccountAlert {
                        self.presenter.deleteAccount()
                    }
                }
                return cell
            }
        }
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch indexPath.section {
//        case 0:
//            switch indexPath.row {
//            case 0:
//                break
//            case 1:
//                break
//            case 2:
//                break
//            case 3:
//                break
//            case 4:
//                break
//            default:
//                self.presenter.showLegalInfo()
//            }
//        default:
//            switch indexPath.row {
//            case 0:
//                self.presenter.logout()
//            default:
//                self.presenter.deleteAccount()
//            }
//        }
//    }
}

private extension ProfileView {
    func setup() {
        self.title = nil
        self.loadIndication(displayed: false)
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = estimatedRowHeight
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: .leastNonzeroMagnitude)))
//        self.tableView.allowsMultipleSelection = false
//        self.tableView.isEditing = false
//        self.tableView.allowsSelectionDuringEditing = true
    }
    
    func setupDataAdapter(profile: Profile) {
        let dataAdapter = ProfileDataAdapter(state: self.state ?? .seller, profile: profile)
        self.tableViewDataAdapter = dataAdapter
//        self.tableView.dataSource = self.tableViewDataAdapter
//        self.tableView.delegate = self.tableViewDataAdapter
        dataAdapter.actionHandler = { [weak self] actionType in
            guard let self = self else { return }
            switch actionType {
            case .dataDidChanged, .editProfile:
                self.tableViewDataAdapter.map { tvDataAdapter in
                    if !tvDataAdapter.isShouldShowConfirmButton {
                        tvDataAdapter.isShouldShowConfirmButton = true
                        self.reloadData()
                    }
                }
            case .confirmButtonAction:
                self.tableViewDataAdapter.map { self.presenter.sendProfile(profile: $0.profile) }
            case .logout:
                self.showLogoutAlert {
                    self.presenter.logout()
                }
            case .contactUs:
                self.contactWatchTeamWithEmail()
            case .changePassword:
                self.presenter.changePassword()
            case .privacyPolicy:
                self.showPrivacyPolicy()
            case.deleteMyAccount:
                self.showDeleteAccountAlert {
                    self.presenter.deleteAccount()
                }
            }
        }
        self.reloadData()
    }
    
    func reloadData() {
        UIView.animate(withDuration: 0.1, animations: {
            self.tableView.alpha = 0
        }) { _ in
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.1, animations: {
                self.tableView.alpha = 1
            }) { _ in

            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.updateStackOfTextFields()
//        }
        
//        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        
//        UIView.performWithoutAnimation {
//            self.tableView.reloadData()
//            self.tableView.beginUpdates()
//            self.tableView.endUpdates()
//        }
        
//        onMainQueue {
//            self.tableView.reloadData()
//        }
    }
    
    func contactWatchTeamWithEmail() {
        let email = API.supportMail
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func showPrivacyPolicy() {
      let urlString = API.privacyPolicy
        if let url = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

private extension ProfileView {
    func showLogoutAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Are you sure you want to log out?",
                   button1Title: "Confirm",
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
    
    func showDeleteAccountAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Are you sure you want\nto delete account?",
                   subTitle: "All your lots will be deleted",
                   button1Title: "Cancel",
                   button2Title: "Yes, delete",
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
}
//swiftlint:disable all
