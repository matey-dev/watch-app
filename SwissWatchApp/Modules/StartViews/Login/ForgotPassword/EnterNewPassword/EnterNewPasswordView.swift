//
//  EnterNewPasswordView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/4/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol IEnterNewPasswordView: AnyObject {
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String]
    func loadIndication(displayed: Bool)
}

class EnterNewPasswordView: BaseViewController {
    var presenter: IEnterNewPasswordPresenter!
    
    @IBOutlet weak var passwordTextField: BaseFloatingTextField!
    @IBOutlet weak var confirmPasswordTextField: BaseFloatingTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var verticalConstraint2: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint3: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint4: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint5: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint6: NSLayoutConstraint!
    
    private var verticalConstraints: [NSLayoutConstraint] {
        return [verticalConstraint2,
                verticalConstraint3, verticalConstraint4,
                verticalConstraint5, verticalConstraint6]
    }
    private var verticalConstraintsConstantsOriginal: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.tag = 1
        self.confirmPasswordTextField.tag = 1
        self.verticalConstraintsConstantsOriginal = self.verticalConstraints.map { $0.constant }
        self.configureTextFields()
        self.loadIndication(displayed: false)
    }
    
    func bind(presenter: IEnterNewPasswordPresenter) {
        self.presenter = presenter
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.presenter.nextPressed()
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

private extension EnterNewPasswordView {
    func configureTextFields() {
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.passwordTextField.setupAs(type: .password)
        self.confirmPasswordTextField.setupAs(type: .confirmPassword)
        self.passwordTextField.textDidChangeAction = { [weak self] text in
            self?.presenter.didChange(password: text)
        }
        self.confirmPasswordTextField.textDidChangeAction = { [weak self] text in
            self?.presenter.didChange(confirmPassword: text)
        }
    }
    
    func setVerticalConstraintsCompressed(_ compressed: Bool) {
        guard UIDeviceHelper.isSmallScreenHeight else { return }
        let k: CGFloat = compressed ? 0.4 : 1.0
        let constants = self.verticalConstraintsConstantsOriginal.map { $0 * k }
        for (i, constraint) in self.verticalConstraints.enumerated() {
            constants[safe: i].map { constraint.constant = $0 }
        }
    }
    
    func setNextButtonDisabled(_ disabled: Bool) {
        self.nextButton.isEnabled = !disabled
        let backColor = disabled ? Colors.black_8opacity : Colors.blackLight
        self.nextButton.backgroundColor = backColor
        let titleColor = disabled ? Colors.black_40opacity : Colors.white
        self.nextButton.setTitleColor(titleColor, for: .normal)
    }
}

//extension EnterNewPasswordView: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        switch textField {
//        case self.passwordTextField:
//            self.passwordTextField.becomeFirstResponder()
//        case self.confirmPasswordTextField:
//            self.confirmPasswordTextField.resignFirstResponder()
//        default:
//            break
//        }
//        return true
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        switch textField {
//        case self.passwordTextField:
//            //self.presenter.didEndPasswordEditing()
//            break
//        case self.confirmPasswordTextField:
//            //self.presenter.didEndConfirmPasswordEditing()
//            break
//        default:
//            return
//        }
//    }
//}

extension EnterNewPasswordView: IEnterNewPasswordView {
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        var cantFind = dict
        let passwordKey = "password"
        let confirmPasswordKey = "password_confirm"
        let keys = [passwordKey, confirmPasswordKey]
        keys.forEach { key in
            let message = dict.first(where: { $0.key == key })?.value
            onMainQueue {
                if key == passwordKey {
//                    self.passwordTextField.error = message
                } else if key == confirmPasswordKey {
//                    self.confirmPasswordTextField.error = message
                }
            }
            cantFind[key] = nil
        }
        return cantFind
    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.view.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}
