//
//  RegistrationView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import PostalCodeValidator
import PhoneNumberKit

protocol IRegistrationView: AnyObject {
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String]
    func loadIndication(displayed: Bool)
}

private let estimatedRowHeight: CGFloat = 500.0

class RegistrationView: BaseViewController {
    var presenter: IRegistrationPresenter!
    
    var state: UserType? {
        didSet {
            self.setState(state)
        }
    }
    let phoneNumberKit = PhoneNumberKit()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewDataAdapter: RegistrationDataAdapter?
    
    @IBOutlet weak var spacer: UIView!
    
    @IBOutlet weak var spacerHeighConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setState(self.state)
        self.scrollView = tableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.appNavigationController?.setNavigationBar(hidden: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.onViewDidAppear()
    }
    
    func bind(presenter: IRegistrationPresenter) {
        self.presenter = presenter
    }
    
    @IBAction func goToRegistrationAsDealerButtonPressed(_ sender: UIButton) {
        self.presenter.goToSignUpAsDealerButtonPressed()
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.presenter.backToSignIn()
    }
    
//    override func keyboardWillBeShown() {
//        super.keyboardWillBeShown()
//        let bottomDealerContainerHeight: CGFloat = self.areYouDealerBottomContainer.isHidden ? 0.0 : 66.0
//        let spacerHeight = self.keyboardHeight - bottomDealerContainerHeight
//        self.spacerHeighConstraint.constant = spacerHeight
//    }
//    
//    override func keyboardWillBeHidden() {
//        super.keyboardWillBeHidden()
//        self.spacerHeighConstraint.constant = 0
//    }
}

private extension RegistrationView {
    func setup() {
        self.loadIndication(displayed: false)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = estimatedRowHeight
        
        self.state.map { userType in
            self.tableViewDataAdapter = RegistrationDataAdapter(userType: userType)
        }
        
        self.tableView.dataSource = self.tableViewDataAdapter
        self.tableView.delegate = self.tableViewDataAdapter
        
        self.tableViewDataAdapter?.actionHandler = { [weak self] action in
            guard let sSelf = self, let state = self?.state else { return }
            switch action {
            case .showPrivacyPolicy:
                self?.showPrivacyPolicy()
            case .signUp:
                switch state {
                case .seller:
                    let email = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .email })?.text ?? ""
                    let password = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .password })?.text ?? ""
                    let confirmPassword = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .password_confirm })?.text ?? ""
                    
                    sSelf.presenter.signUpSellerButtonPressed(email: email,
                                                              password: password,
                                                              confirmPassword: confirmPassword)
                case .dealer:
                    let email = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .email })?.text ?? ""
                    let password = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .password })?.text ?? ""
                    let confirmPassword = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .password_confirm })?.text ?? ""
                    let firstName = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .first_name })?.text ?? ""
                    let lastName = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .last_name })?.text ?? ""
                    var companyName = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .company_name })?.text ?? ""
                    var companyPhone = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .company_phone })?.text ?? ""
                    let address = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .address })?.text ?? ""
                    let city = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .city })?.text ?? ""
                    let state = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .state })?.text ?? ""
                    let zipCode = sSelf.tableViewDataAdapter?.fillableCellModels.first(where: { $0.key == .zip })?.text ?? ""
                    
                    
                    do {
                        let phoneNumber = try sSelf.phoneNumberKit.parse(companyPhone)
                        guard !phoneNumber.numberString.isEmpty else {
                            self?.showError(title: "Invalid Company Phone", message: "Please type valid phone number!")
                            return
                        }
                        companyPhone = sSelf.phoneNumberKit.format(phoneNumber, toType: .e164)
                    } catch {
                        self?.showError(title: "Invalid Company Phone", message: "Please type valid phone number!")
                        print("Generic parser error")
                        return
                    }
                    
//                    if let validator = PostalCodeValidator(locale: .current) { // United States (US)
//                        guard validator.validate(postalCode: zipCode) == true else {
//                            self?.showError(title: "Invalid Zip Code", message: "Please type valid zip code!")
//                            return
//                        }
//                    }
                    
                    sSelf.presenter.signUpDealerButtonPressed(firstName: firstName,
                                                              lastName: lastName,
                                                              companyName: companyName,
                                                              companyPhone: companyPhone,
                                                              email: email,
                                                              password: password,
                                                              confirmPassword: confirmPassword,
                                                              address: address,
                                                              city: city,
                                                              state: state,
                                                              zipCode: zipCode)
                }
            case .checkBoxIsChanged: ()
                self?.reloadButton()
            }
        }
        
        self.tableViewDataAdapter?.onScrollViewDidScroll = { [weak self] in
            self?.updateStackOfTextFields()
        }
    }
    
    func reloadButton() {
        let lastIndex = self.tableView.numberOfRows(inSection: 0) - 1
        guard lastIndex >= 0 else { return }
        let lastIndexPath = IndexPath(row: lastIndex, section: 0)
        self.tableView.reloadRows(at: [lastIndexPath], with: .automatic)
    }
    
    func setState(_ state: UserType?) {
        state.map {
            switch $0 {
            case .seller:
                setupAsSeller()
            case .dealer:
                setupAsDealer()
            }
            } ?? {
                self.setupAsSeller()
            }()
    }
    
    func setupAsSeller() {
        guard self.isViewLoaded else { return }
    }
    
    func setupAsDealer() {
        guard self.isViewLoaded else { return }
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

extension RegistrationView: IRegistrationView {
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        let cantFind = self.tableViewDataAdapter?.updateErrorsWithKeyValues(dict) ?? [:]
        onMainQueue {
            self.tableView.reloadData()
        }
        return cantFind
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.containerView.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}
