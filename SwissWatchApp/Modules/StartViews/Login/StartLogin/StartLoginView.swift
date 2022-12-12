//
//  StartLoginView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import JWTDecode

protocol IStartLoginView: AnyObject {
    func loadIndication(displayed: Bool)
}

class StartLoginView: BaseViewController {
    var presenter: IStartLoginPresenter!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonStack: UIStackView!
    
    var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.appNavigationController?.setNavigationBar(hidden: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.onViewDidAppear()
    }
    
    func bind(presenter: IStartLoginPresenter) {
        self.presenter = presenter
    }
    
    @IBAction func signUpWithEmailButtonPressed(_ sender: UIButton) {
        self.presenter.signUpWithEmailButtonPressed()
    }
    
    @IBAction func signUpWithAppleButtonPressed(_ sender: Any) {
        startSignInWithAppleFlow()
    }
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        self.presenter.signInButtonPressed()
    }
    
    @IBAction func signUpWithFacebookButtonPressed(_ sender: UIButton) {
        self.presenter.signUpWithFacebookButtonPressed(socialServiceUIDelegate: self)
    }
    
    @IBAction func signUpAsDealerButtonPressed(_ sender: UIButton) {
        self.presenter.signUpAsDealerButtonPressed()
    }
    
}

private extension StartLoginView {
    func setup() {
        self.loadIndication(displayed: false)
    }
}

extension StartLoginView: IStartLoginView {
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.view.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}

extension StartLoginView: SocialNetworksUIDelegate {
    
}

extension StartLoginView: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            self.presenter.appleLogin(appleIDCredential: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let error = error as? ASAuthorizationError {
            switch error.code {
            case .failed:
                self.showAlert(title: "Oops!", message: "Sign in failed")
//                self.showAlert(alert)
            case .invalidResponse, .notHandled, .unknown:
                self.showAlert(title: "Oops!", message: "Something is wrong. Please try later.")
            case .canceled:
                break
            default:
                self.showAlert(title: "Error!", message: error.localizedDescription)
                break
            }
        } else {
            self.showAlert(title: "Error!", message: error.localizedDescription)
//            AlertService.showAlert(alert)
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
