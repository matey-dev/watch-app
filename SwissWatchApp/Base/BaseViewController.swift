//
//  BaseViewController.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol IBaseViewController {
    func showError(title: String,
                   message: String)
    func back()
}

class BaseViewController: UIViewController {
    private var _keyboardHeight: CGFloat = 0.0
    var keyboardHeight: CGFloat { return self._keyboardHeight }
    
    var scrollView: UIScrollView?
    var visibleTextField: UITextField?
    var sequenceOfTextFields: [UITextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDismissKeyboardOnTap()
        self.setupNavItem()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateStackOfTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    func keyboardWillBeShown() {}
    func keyboardWillBeHidden() {}
}

extension BaseViewController: UITextFieldDelegate {
    func updateStackOfTextFields() {
        self.sequenceOfTextFields = Array(self.view.get(all: UITextField.self).filter { $0.isUserInteractionEnabled == true }.reversed())
        self.sequenceOfTextFields.sort(by: { $0.tag < $1.tag })
        self.sequenceOfTextFields.forEach { $0.delegate = self }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = self.sequenceOfTextFields.firstIndex(of: textField) else { return false }
        guard let next = self.sequenceOfTextFields[safe: index + 1] else { textField.resignFirstResponder(); return false }
        next.becomeFirstResponder(); return false
    }
}

extension BaseViewController: IBaseViewController {
    func back() {
        
    }
    
    func showError(title: String,
                   message: String) {
        onMainQueue {
            self.showAlert(title: title,
                           message: message)
        }
    }
}

private extension BaseViewController {
    func subscribeToKeyboardNotifications() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeShown(note: Notification) {
        let userInfo = note.userInfo
        let keyboardFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let height = keyboardFrame?.height ?? 0.0
        let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
        
        if let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self._keyboardHeight = keyboardSize.height
        }
        
        self.scrollView.map { sv in
            sv.contentInset = contentInset
            sv.scrollIndicatorInsets = contentInset
            self.visibleTextField.map { tf in
                sv.scrollRectToVisible(tf.frame, animated: true)
            }
        }
        
        self.keyboardWillBeShown()
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        self._keyboardHeight = 0.0
        
        self.scrollView.map { sv in
            let contentInset = UIEdgeInsets.zero
            sv.contentInset = contentInset
            sv.scrollIndicatorInsets = contentInset
        }
        
        self.keyboardWillBeHidden()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupDismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func setupNavItem() {
        let watchQuoteLogo = UIImage(named: "watchQuote-halfSize")
        let imageView = UIImageView(image: watchQuoteLogo)
        imageView.frame = CGRect(x: 0, y: 0, width: 123, height: 16)
        imageView.contentMode = .scaleToFill
        self.navigationItem.titleView = imageView
    }
}

// MARK: - alert

extension BaseViewController: DefaultAlert {
    enum AlertAction {
        case defaultPressed
        case cancelPressed
    }
}

protocol DefaultAlert {
    func showAlert(text: String,
                   defaultButtonTitle: String,
                   cancelButtonTitle: String?,
                   completion: ((BaseViewController.AlertAction) -> Void)?)
}

extension DefaultAlert where Self: UIViewController {
    func showAlert(text: String,
                   defaultButtonTitle: String,
                   cancelButtonTitle: String?,
                   completion: ((BaseViewController.AlertAction) -> Void)?) {
        
        self.showAlert(message: text,
                       title: .empty,
                       defaultButtonTitle: defaultButtonTitle,
                       cancelButtonTitle: cancelButtonTitle) { defaultPressed in
                        
                        let action: BaseViewController.AlertAction = defaultPressed
                            ? .defaultPressed
                            : .cancelPressed
                        completion?(action)
        }
    }
}
