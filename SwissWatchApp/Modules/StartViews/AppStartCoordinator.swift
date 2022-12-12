//
//  AppStartCoordinator.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

final class AppStartCoordinator {
    let navigationController: AppNavigationController
    private let withSplashScreen: Bool
    private var catalogApiTemp: CatalogAPIService?
    
    // end of current coordinator's timeline
    var onStartSceneDidFinishAction: ((UserType) -> Void)?
    
    init(navigationController: AppNavigationController,
         withSplashScreen: Bool = true) {
        self.withSplashScreen = withSplashScreen
        self.navigationController = navigationController
        navigationController.isNavigationBarHidden = true
//        self.navigationController.setNavigationBar(hidden: true)
//        self.navigationController.configureAppearance(large: false)
    }
}

// MARK: - Coordinator -

extension AppStartCoordinator: Coordinator {
    func start() {
        self.onStart()
    }
}

private extension AppStartCoordinator {
    
    func onStart() {
        if self.withSplashScreen {
            let introSplashView = AppScenesFactory.makeIntroSplashScene { [weak self] in
                self?.showOnboardingIfNeed()
            }
            self.set(rootView: introSplashView)
        } else {
            self.showOnboardingIfNeed()
        }
    }
    
    func showOnboardingIfNeed(_ completion: (() -> Void)? = nil) {
        let shouldOnboard = !FirstStart.shared.isNotFirst
//        let shouldOnboard = true
        if shouldOnboard {
//            let view = OnboardingView.storyboardInstance()
            let view = OnboardVC()
            view.onAction = { [weak self] action in
                switch action {
                case .done:
                    self?.showLoginIfNeed()
                case .addLot:
                    self?.showAddLotStep()
                }
                
                FirstStart.shared.isNotFirst = true
            }
            self.set(rootView: view)
        } else {
            self.showLoginIfNeed()
        }
    }
    
    func showAddLotStep() {
        let view = AddLotStepVC()
        self.push(view: view)
    }
    
    func showLoginIfNeed(_ completion: (() -> Void)? = nil) {
        AppStartService().getLoggedState { loggedState in
            switch loggedState {
            case .unathorized:
                self.showStartLoginView()
            case .authorized(let userType):
                self.onStartSceneDidFinish(userType: userType)
            }
        }
    }
    
    // MARK: select login type
    
    func showStartLoginView(_ completion: (() -> Void)? = nil) {
        let view = StartLoginView.storyboardInstance()
        
        let presenter = StartLoginPresenter(view: view)
        view.bind(presenter: presenter)
        
        presenter.onAction { [weak self] action in
            switch action {
            case .signIn:
                self?.showSellerLoginView()
            case .signUp:
                self?.showSellerRegistrationView()
            case .signUpAsDealer:
                self?.showDealerRegistrationView()
            case .fbSuccess:
                self?.onStartSceneDidFinish(userType: .seller)
            case .fbFailure:
                self?.showSellerRegistrationView()
            case .userInSuspendedMode(let email):
                self?.showSendCodeView(email: email,
                                       sendCodeType: .activation,
                                       userType: .seller)
            case .appleFailure:
                break
            }
        }
        
        self.set(rootView: view, completion)
    }
    
    // MARK: login view
    
    func showSellerLoginView(_ completion: (() -> Void)? = nil) {
        let view = LoginView.storyboardInstance()
        
        let presenter = LoginPresenter(view: view)
        view.bind(presenter: presenter)
        view.state = .seller
        
        presenter.onAction { [weak self] action in
            switch action {
            case .dealerLogin:
                self?.showDealerLoginView()
            case .forgotPassword(let email):
                self?.showRecoverPasswordView(email: email,
                                              userType: .seller)
            case .loginSuccess:
                self?.onStartSceneDidFinish(userType: .seller)
            case .userInSuspendedMode(let email):
                self?.showSendCodeView(email: email,
                                       sendCodeType: .activation,
                                       userType: .seller)
            case .back:
                self?.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
    
    func showDealerLoginView(_ completion: (() -> Void)? = nil) {
        let view = LoginView.storyboardInstance()
        
        let presenter = LoginPresenter(view: view)
        view.bind(presenter: presenter)
        view.state = .dealer
        
        presenter.onAction { [weak self] action in
            switch action {
            case .dealerLogin:
                break
            case .forgotPassword(let email):
                self?.showRecoverPasswordView(email: email,
                                              userType: .dealer)
            case .loginSuccess:
                self?.onStartSceneDidFinish(userType: .dealer)
            case .userInSuspendedMode(let email):
                self?.showSendCodeView(email: email,
                                       sendCodeType: .activation,
                                       userType: .dealer)
            case .back:
                self?.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
    
    // MARK: registration view
    
    func showSellerRegistrationView(_ completion: (() -> Void)? = nil) {
        let view = RegistrationView.storyboardInstance()
        
        let presenter = RegistrationPresenter(view: view)
        view.bind(presenter: presenter)
        view.state = .seller
        
        presenter.onAction { [weak self] action in
            switch action {
            case .signUpSuccess(let email):
                self?.showSendCodeView(email: email,
                                       sendCodeType: .activation,
                                       userType: .seller)
            case .dealerSignUp:
                self?.showDealerRegistrationView()
            case .back:
                self?.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
    
    func showDealerRegistrationView(_ completion: (() -> Void)? = nil) {
        let view = RegistrationView.storyboardInstance()
        
        let presenter = RegistrationPresenter(view: view)
        view.bind(presenter: presenter)
        view.state = .dealer
        
        presenter.onAction { [weak self] action in
            switch action {
            case .signUpSuccess(let email):
                self?.showSendCodeView(email: email,
                                       sendCodeType: .activation,
                                       userType: .dealer)
            case .dealerSignUp:
                break
            case .back:
                self?.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
    
    // MARK: recover password
    
    func showRecoverPasswordView(email: String,
                                 userType: UserType,
                                 _ completion: (() -> Void)? = nil) {
        let view = RecoverPasswordView.storyboardInstance()
        
        let presenter = RecoverPasswordPresenter(view: view,
                                                 predefinedEmail: email)
        view.bind(presenter: presenter)
        
        presenter.onAction { [weak self] action in
            switch action {
            case .next(let emailString):
                self?.showSendCodeView(email: emailString,
                                       sendCodeType: .reset,
                                       userType: userType)
            case .back:
                self?.popView(animated: true)
            }
        }
        self.push(view: view, completion)
    }
    
    func showSendCodeView(email: String,
                          sendCodeType: SendCodeType,
                          userType: UserType,
                          _ completion: (() -> Void)? = nil) {
        let view = SendCodeView.storyboardInstance()
        
        let presenter = SendCodePresenter(view: view,
                                          email: email,
                                          sendCodeType: sendCodeType,
                                          userType: userType)
        view.bind(presenter: presenter)
        
        presenter.onAction { [weak self] action in
            switch action {
            case .next(let email, let key):
                self?.showEnterNewPasswordView(email: email,
                                               key: key)
            case .finish(let userType):
                self?.onStartSceneDidFinish(userType: userType)
            case .back:
                self?.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
    
    func showEnterNewPasswordView(email: String,
                                  key: String,
                                  _ completion: (() -> Void)? = nil) {
        let view = EnterNewPasswordView.storyboardInstance()
        
        let presenter = EnterNewPasswordPresenter(view: view,
                                                  email: email,
                                                  key: key)
        view.bind(presenter: presenter)
        
        presenter.onAction { [weak self] action in
            switch action {
            case .next:
                self?.popToLastLoginView()
            case .back:
                self?.popView(animated: true)
            }
        }
        
        self.push(view: view, completion)
    }
    
    // MARK: on waiting list
    
    func showOnWaitingListView(_ completion: (() -> Void)? = nil) {
        let view = OnWaitingListView.storyboardInstance()
        let presenter = OnWaitingListPresenter()
        view.presenter = presenter
        presenter.onAction { actionType in
            switch actionType {
            case .onSignIn:
                self.showStartLoginView()
            }
        }
        self.push(view: view, completion)
    }
    
    // MARK: back or dismiss current flow
    
    func popToLastLoginView() {
        self.popToViewController(ofClass: LoginView.self)
    }

    // end of current coordinator's timeline
    func onStartSceneDidFinish(userType: UserType) {
        AppStateStorage.shared.userType = userType
      
        let catalogAPIType = CatalogAPIType.catalog(userType)
        self.catalogApiTemp = CatalogAPIService(type: catalogAPIType)
        self.catalogApiTemp?.getList { [weak self] listResult in
            
            onMainQueue {
                switch listResult {
                case .failure(let listFailure):
                    (listFailure as? InternalError)
                        .map { error in
                            if error == .userOnWaitingList {
                                self?.showOnWaitingListView()
                            }
                    }
                default:
                    self?.dismissView(animated: true)
                    self?.onStartSceneDidFinishAction?(userType)
                }
            }
        }
    }
}
