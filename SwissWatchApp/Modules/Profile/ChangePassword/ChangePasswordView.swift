//
//  ChangePasswordView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/21/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Combine
//swiftlint:disable all
protocol IChangePasswordView: AnyObject {
    func onViewDidLoad(email: String)
    func onViewWillAppear()
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String]
    func setLoginButtonDisabled(_ disabled: Bool)
    func loadIndication(displayed: Bool)
}

class ChangePasswordView: BaseViewController {
    var presenter: IChangePasswordPresenter!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var store: Set<AnyCancellable> = []
    
    func bind(presenter: IChangePasswordPresenter) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.oldPasswordTextField.tag = 1
        self.passwordTextField.tag = 2
        self.passwordConfirmTextField.tag = 3
        self.setup()
        self.presenter.onViewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.onViewWillAppear()
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        self.presenter.confirmPressed()
    }
    
    func setupUI() {
        let tfbackColor = UIColor(hex: "#F9FAFA")
        let tfborderColor = UIColor(hex: "#F4F4F4").cgColor
        
        
        [oldPasswordTextField, passwordTextField, passwordConfirmTextField].forEach { (textfield) in
            let leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 12, height: 20)))
            textfield?.leftView = leftView
            textfield?.leftViewMode = .always
            let rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 12, height: 20)))
            textfield?.rightView = rightView
            textfield?.rightViewMode = .always
            textfield?.backgroundColor = tfbackColor
            textfield?.layer.borderColor = tfborderColor
        }
    }
}

extension ChangePasswordView: IChangePasswordView {
    func onViewDidLoad(email: String) {
        onMainQueue {
            
        }
    }
    
    func onViewWillAppear() {
        onMainQueue {
            super.appNavigationController?.setNavigationBar(hidden: false)
        }
    }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        var cantFind = dict
        let oldPasswordKey = "old_password"
        let passwordKey = "new_password"
        let passwordConfirmKey = "new_password_confirm"
        let keys = [oldPasswordKey, passwordKey, passwordConfirmKey]
        keys.forEach { key in
            let message = dict.first(where: { $0.key == key })?.value
            onMainQueue {
//                if key == oldPasswordKey {
//                    self.oldPasswordTextField.error = message
//                } else if key == passwordKey {
//                    self.passwordTextField.error = message
//                } else if key == passwordConfirmKey {
//                    self.passwordConfirmTextField.error = message
//                }
            }
            cantFind[key] = nil
        }
        return cantFind
    }
    
    func setLoginButtonDisabled(_ disabled: Bool) {
        guard self.isViewLoaded else { return }
        onMainQueue {
            self.confirmButton.isEnabled = !disabled
            let backColor = disabled ? Colors.grayMiddle : Colors.blackLight
            self.confirmButton.backgroundColor = backColor
            let titleColor = disabled ? Colors.black_40opacity : Colors.white
            self.confirmButton.setTitleColor(titleColor, for: .normal)
        }
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.confirmButton.isUserInteractionEnabled = !displayed
            self.passwordTextField.isUserInteractionEnabled = !displayed
            self.passwordConfirmTextField.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}

private extension ChangePasswordView {
    func setup() {
        self.title = "Changing Password"
        self.loadIndication(displayed: false)
        self.setLoginButtonDisabled(true)
        
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self.oldPasswordTextField)
            .map({($0.object as! UITextField).text})
            .sink { (text) in
                self.presenter.didChange(oldPassword: text ?? "")
        }.store(in: &store)
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self.passwordTextField)
            .map({($0.object as! UITextField).text})
            .sink { (text) in
                self.presenter.didChange(newPassword: text ?? "")
        }.store(in: &store)
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self.passwordConfirmTextField)
            .map({($0.object as! UITextField).text})
            .sink { (text) in
                self.presenter.didChange(newPasswordConfirm: text ?? "")
        }.store(in: &store)
        
        
        
//        self.oldPasswordTextField.setupAs(type: .password, placeholder: "Old Password (if exists)")
//        self.passwordTextField.setupAs(type: .password, placeholder: "New Password")
//        self.passwordConfirmTextField.setupAs(type: .confirmPassword, placeholder: "Confirm Password")
//
//        self.oldPasswordTextField.textDidChangeAction = { [weak self] text in
//            self?.presenter.didChange(oldPassword: text)
//        }
//        self.passwordTextField.textDidChangeAction = { [weak self] text in
//            self?.presenter.didChange(newPassword: text)
//        }
//        self.passwordConfirmTextField.textDidChangeAction = { [weak self] text in
//            self?.presenter.didChange(newPasswordConfirm: text)
//        }
    }
}
