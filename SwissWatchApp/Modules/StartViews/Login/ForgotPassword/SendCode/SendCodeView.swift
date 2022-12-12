//
//  SendCodeView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/4/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol ISendCodeView: AnyObject {
    func setTopMessage(_ message: String)
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String]
    func loadIndication(displayed: Bool)
    func setNextButtonDisabled(_ disabled: Bool)
    func setResendButton(active: Bool)
}

class SendCodeView: BaseViewController {
    var presenter: ISendCodePresenter!
    
    @IBOutlet weak var topMessageLabel: UILabel!
    @IBOutlet weak var codeTextField: BaseFloatingTextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var contactAccounRecoveryTeamLabel: UITextView!
    
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
        self.codeTextField.tag = 1
        self.verticalConstraintsConstantsOriginal = self.verticalConstraints.map { $0.constant }
        self.setup()
        
        self.presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.appNavigationController?.setNavigationBar(hidden: false)
    }
    
    func bind(presenter: ISendCodePresenter) {
        self.presenter = presenter
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.codeTextField.text.map { self.presenter.nextPressed(key: $0) }
    }
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        self.presenter.resendPressed()
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

extension SendCodeView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

private extension SendCodeView {
    func setup() {
        self.loadIndication(displayed: false)
        self.setHyperlinkToContactAccounRecoveryTeamLabel()
        self.setupTapRecognizerToContactAccounRecoveryTeamLabel()
        self.codeTextField.keyboardType = .numberPad
        self.codeTextField.setupAs(type: .confirmCode)
        self.setNextButtonDisabled(true)
        self.codeTextField.textDidChangeAction = { [weak self] text in
            guard text.count == 5 else {
                self?.setNextButtonDisabled(true)
                return
            }
            self?.setNextButtonDisabled(false)
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
    
    @objc func handleTapToContactAccounRecoveryTeamLabel(sender: UITapGestureRecognizer) {
        let email = API.supportMail
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func setupTapRecognizerToContactAccounRecoveryTeamLabel() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapToContactAccounRecoveryTeamLabel))
        self.contactAccounRecoveryTeamLabel.addGestureRecognizer(tapGesture)
    }
    
    func setHyperlinkToContactAccounRecoveryTeamLabel() {
        guard let text = self.contactAccounRecoveryTeamLabel.text else { return }
        
        onMainQueue {
            let font = Fonts.System.regular(size: 15.0)
            let color = Colors.grayDark
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.center
            let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                             .foregroundColor: color,
                                                             .paragraphStyle: style]
            let attributedText = NSMutableAttributedString(string: text,
                                                           attributes: attributes)
            
            let textWithLink = "Account recovery"
            let textLink = "mailto:" + API.supportMail
            
            let linkFont = Fonts.System.regular(size: 15.0)
            let linkColor = Colors.darkBlue
            let linkAttributes: [NSAttributedString.Key: Any] = [.font: linkFont,
                                                                 .foregroundColor: linkColor,
                                                                 .paragraphStyle: style]
            let linkRange = attributedText.mutableString.range(of: textWithLink)
            attributedText.setAttributes(linkAttributes,
                                         range: linkRange)
            
            if attributedText.setAsLink(textToFind: textWithLink, linkURL: textLink) {
                self.contactAccounRecoveryTeamLabel.attributedText = attributedText
                self.contactAccounRecoveryTeamLabel.linkTextAttributes = linkAttributes
            }
        }
    }
}

extension SendCodeView: ISendCodeView {
    func setTopMessage(_ message: String) {
        onMainQueue {
            self.topMessageLabel.text = message
        }
    }
    
    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
        var cantFind = dict
        let codeKey = "key"
        let keys = [codeKey]
        keys.forEach { key in
            let message = dict.first(where: { $0.key == key })?.value
            onMainQueue {
//                self.codeTextField.error = message
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
    
    func setNextButtonDisabled(_ disabled: Bool) {
        onMainQueue {
            self.nextButton.isEnabled = !disabled
            let backColor = disabled ? Colors.black_8opacity : Colors.blackLight
            self.nextButton.backgroundColor = backColor
            let titleColor = disabled ? Colors.black_40opacity : Colors.white
            self.nextButton.setTitleColor(titleColor, for: .normal)
        }
    }
    
    func setResendButton(active: Bool) {
        self.resendCodeButton.isEnabled = active
    }
}
