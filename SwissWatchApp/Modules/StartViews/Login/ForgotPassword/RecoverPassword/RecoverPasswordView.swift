//
//  RecoverPasswordView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/4/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol IRecoverPasswordView: AnyObject {
    func fillEmail(_ email: String)
    func loadIndication(displayed: Bool)
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String]
}

class RecoverPasswordView: BaseViewController {
    var presenter: IRecoverPasswordPresenter!
    
    @IBOutlet weak var emailTextField: BaseFloatingTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var verticalConstraint2: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint3: NSLayoutConstraint!
    @IBOutlet weak var verticalConstraint4: NSLayoutConstraint!
    
    private var verticalConstraints: [NSLayoutConstraint] {
        return [verticalConstraint2,
                verticalConstraint3, verticalConstraint4]
    }
    private var verticalConstraintsConstantsOriginal: [CGFloat] = []
    
    // MARK: - vc life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.tag = 1
        self.configureTextFields()
        self.loadIndication(displayed: false)
        self.verticalConstraintsConstantsOriginal = self.verticalConstraints.map { $0.constant }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.onViewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func bind(presenter: IRecoverPasswordPresenter) {
        self.presenter = presenter
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
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

private extension RecoverPasswordView {
    func configureTextFields() {
        self.emailTextField.delegate = self
        self.emailTextField.setupAs(type: .email)
        self.emailTextField.textDidChangeAction = { [weak self] _ in
            self?.trimAndValidateEmail()
            self?.emailTextField.text.map { text in
                self?.presenter.didChange(email: text)
            }
        }
    }
    
    func setVerticalConstraintsCompressed(_ compressed: Bool) {
        guard UIDeviceHelper.isSmallScreenHeight else { return }
        onMainQueue {
            let k: CGFloat = compressed ? 0.55 : 1.0
            let constants = self.verticalConstraintsConstantsOriginal.map { $0 * k }
            for (i, constraint) in self.verticalConstraints.enumerated() {
                constants[safe: i].map { constraint.constant = $0 }
            }
        }
    }
    
    func setNextButtonDisabled(_ disabled: Bool) {
        onMainQueue {
            self.nextButton.isEnabled = !disabled
            let backColor = disabled ? Colors.black_8opacity : Colors.blackLight
            self.nextButton.backgroundColor = backColor
            let titleColor = disabled ? Colors.black_40opacity : Colors.white
            self.nextButton.setTitleColor(titleColor, for: .normal)
        }
    }
    
    func trimAndValidateEmail() {
        let trimmed = self.emailTextField.text?.trim().replacingOccurrences(of: " ", with: "")
        self.emailTextField.text = trimmed
        guard let email = self.emailTextField.text,
            EmailValidator().validate(email: email) == .valid else {
            self.setNextButtonDisabled(true)
            return
        }
        self.setNextButtonDisabled(false)
    }
}

extension RecoverPasswordView: IRecoverPasswordView {
    func fillEmail(_ email: String) {
        guard self.isViewLoaded else { return }
        onMainQueue {
            self.emailTextField.text = email
            self.trimAndValidateEmail()
        }
    }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        var cantFind = dict
        let emailKey = "email"
        let keys = [emailKey]
        keys.forEach { key in
            let message = dict.first(where: { $0.key == key })?.value
            onMainQueue {
//                self.emailTextField.error = message
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

//extension RecoverPasswordView: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        switch textField {
//        case self.emailTextField:
//            self.emailTextField.resignFirstResponder()
//            self.view.endEditing(true)
//        default:
//            break
//        }
//        return true
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        switch textField {
//        case self.emailTextField:
//            break
//        default:
//            return
//        }
//    }
//}
