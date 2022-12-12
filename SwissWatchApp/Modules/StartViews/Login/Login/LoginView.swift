//
//  LoginView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 4/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol ILoginView: AnyObject {
    var email: String { get }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String]
    
    func loadIndication(displayed: Bool)
}

class LoginView: BaseViewController {
    var presenter: ILoginPresenter!
    
    var state: UserType? {
        didSet {
            self.setup(state)
        }
    }
    var isAccountBlocked: Bool = false {
        didSet {
            self.setupBlockedMode(self.isAccountBlocked)
        }
    }
    
    var email: String {
        return self.emailTextField.text ?? ""
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lockedAccountTitle: UILabel!
    @IBOutlet weak var emailTextField: BaseFloatingTextField!
    @IBOutlet weak var passwordTextField: BaseFloatingTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var bootomStackWithDealerButton: UIStackView!
    @IBOutlet weak var goToLoginAsDealerButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var verticalConstraint2: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint3: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint4: NSLayoutConstraint!
    
    private var verticalConstraints: [NSLayoutConstraint] {
        return [verticalConstraint2,
                verticalConstraint3, verticalConstraint4]
    }
    private var verticalConstraintsConstantsOriginal: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.tag = 1
        self.passwordTextField.tag = 2
        self.setupBlockedMode(self.isAccountBlocked) { [weak self] in
            self?.generalSetup()
        }
        self.setup(self.state)
        
        self.verticalConstraintsConstantsOriginal = self.verticalConstraints.map { $0.constant
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.appNavigationController?.setNavigationBar(hidden: false)
    }
    
    func bind(presenter: ILoginPresenter) {
        self.presenter = presenter
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.presenter.loginPressed(email: self.emailTextField.text,
                                    password: self.passwordTextField.text,
                                    userType: self.state ?? .seller)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        self.presenter.forgotPasswordPressed()
    }
    
    @IBAction func goToLoginAsDealerButtonPressed(_ sender: UIButton) {
        self.presenter.dealerLoginPressed()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.presenter.backPressed()
    }
    
    override func keyboardWillBeShown() {
        super.keyboardWillBeShown()
        self.setVerticalConstraintsCompressed(true)
    }
    
    override func keyboardWillBeHidden() {
        super.keyboardWillBeHidden()
        self.setVerticalConstraintsCompressed(false)
    }
}

private extension LoginView {
    func generalSetup() {
        self.loadIndication(displayed: false)
        self.setLoginButtonDisabled(true)
        self.emailTextField.setupAs(type: .email, placeholder: "Email")
        self.passwordTextField.setupAs(type: .password, placeholder: "Password")
        self.emailTextField.textDidChangeAction = { [weak self] _ in
            let enabled = self?.isValidFields() ?? false
            self?.setLoginButtonDisabled(!enabled)
        }
        self.passwordTextField.textDidChangeAction = { [weak self] _ in
            let enabled = self?.isValidFields() ?? false
            self?.setLoginButtonDisabled(!enabled)
        }
    }
    
    func isValidFields() -> Bool {
        guard let email = self.emailTextField.text,
            let pass = self.passwordTextField.text else { return false }
        guard EmailValidator().validate(email: email) == .valid else { return false }
        guard pass.count > 7 else { return false }
        return true
    }
    
    func setVerticalConstraintsCompressed(_ compressed: Bool) {
        guard UIDeviceHelper.isSmallScreenHeight else { return }
        let k: CGFloat = compressed ? 0.39 : 1.0
        let constants = self.verticalConstraintsConstantsOriginal.map { $0 * k }
        for (i, constraint) in self.verticalConstraints.enumerated() {
            constants[safe: i].map { constraint.constant = $0 }
        }
    }
    
    func setup(_ state: UserType?) {
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
        onMainQueue {
            self.titleLabel.text = ScreenTitles.sellerLogin
            self.bootomStackWithDealerButton.isHidden = false
        }
    }
    
    func setupAsDealer() {
        guard self.isViewLoaded else { return }
        onMainQueue {
            self.titleLabel.text = ScreenTitles.dealerLogin
            self.bootomStackWithDealerButton.isHidden = true
        }
    }
    
    func setupBlockedMode(_ blocked: Bool, _ completion: (() -> Void)? = nil) {
        guard self.isViewLoaded else { return }
        onMainQueue {
            self.setLoginButtonDisabled(blocked)
            let hidden = !blocked
            self.lockedAccountTitle.isHidden = hidden
            self.forgotPasswordButton.isEnabled = hidden
            self.goToLoginAsDealerButton.isEnabled = hidden
            self.emailTextField.isEnabled = hidden
            self.passwordTextField.isEnabled = hidden
            completion?()
        }
    }
    
    func setLoginButtonDisabled(_ disabled: Bool) {
        guard self.isViewLoaded else { return }
        onMainQueue {
            self.loginButton.isEnabled = !disabled
            let backColor = disabled ? Colors.black_8opacity : Colors.blackLight
            self.loginButton.backgroundColor = backColor
            let titleColor = disabled ? Colors.black_40opacity : Colors.white
            self.loginButton.setTitleColor(titleColor, for: .normal)
        }
    }
    
    func showAccountIsBlocked() {
        self.setupBlockedMode(true)
        self.setLoginButtonDisabled(true)
    }
}

extension LoginView: ILoginView {
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        guard (dict.values.filter { $0 == "Your account is blocked" }.isEmpty) else {
            self.showAccountIsBlocked()
            return [:]
        }
        var cantFind = dict
        let emailKey = "email"
        let passwordKey = "password"
        let keys = [emailKey, passwordKey]
        keys.forEach { key in
            let message = dict.first(where: { $0.key == key })?.value
            onMainQueue {
                if key == emailKey {
//                    self.emailTextField.error = message
                } else if key == passwordKey {
//                    self.passwordTextField.error = message
                }
            }
            cantFind[key] = nil
        }
        return cantFind
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.loginButton.isUserInteractionEnabled = !displayed
            self.forgotPasswordButton.isUserInteractionEnabled = !displayed
            self.goToLoginAsDealerButton.isUserInteractionEnabled = !displayed
            self.emailTextField.isUserInteractionEnabled = !displayed
            self.passwordTextField.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}
