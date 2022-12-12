//
//  EditProfileVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 20.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import Combine
import AVFoundation
import SemiModalViewController
//swiftlint:disable all
class EditProfileVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoImgView: UIImageView!
    
    @IBOutlet weak var firstNameTF: UITextField!
    
    @IBOutlet weak var lastNameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var emailVerifyBtn: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var state: UserType?
    var presenter: IProfilePresenter!
    
    var profile: Profile?
    
    func bind(presenter: IProfilePresenter) {
        self.presenter = presenter
    }
    
    var store: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.onViewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.onViewWillAppear()
    }
    
    func setupUI() {
        let tfbackColor = UIColor(hex: "#F9FAFA")
        let tfborderColor = UIColor(hex: "#F4F4F4").cgColor
        
        
        [firstNameTF, lastNameTF, emailTF].forEach { (textfield) in
            let leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 12, height: 20)))
            textfield?.leftView = leftView
            textfield?.leftViewMode = .always
            let rightView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 12, height: 20)))
            textfield?.rightView = rightView
            textfield?.rightViewMode = .always
            textfield?.backgroundColor = tfbackColor
            textfield?.layer.borderColor = tfborderColor
        }
        
        photoImgView.layer.cornerRadius = 48
        photoImgView.clipsToBounds = true
    }
    
    var enableSaveBtn: Bool {
        get {
            saveBtn?.isEnabled ?? false
        }
        set {
            saveBtn?.isEnabled = newValue
            saveBtn?.backgroundColor = newValue ? Colors.blackTextColor : Colors.grayLight
        }
    }
    
    @IBAction func onTapVerifyNewEmail(_ sender: Any) {
    }
    
    @IBAction func didTapChangePassword(_ sender: Any) {
        self.presenter.changePassword()
    }
    
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        guard var profile = self.profile else { return }
        profile.firstName = firstNameTF.text
        profile.lastName = lastNameTF.text
        profile.email = emailTF.text
        self.presenter.sendProfile(profile: profile, image: photoImgView.image) { [weak self] in
            self?.presenter.back()
        }
//        self.presenter.sendProfile(profile: profile)
    }
    
    @IBAction func changeAvatarButtonPressed(_ sender: UIButton) {
        let view = PhotoImportVC.storyboardInstance()
        let options = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.disableCancel: true,
            SemiModalOption.parentAlpha: 0.3,
            SemiModalOption.animationDuration: 0.25
            ] as [SemiModalOption:Any]
        view.view.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 190))
        view.view.backgroundColor = UIColor(hex: "#101E29")
        presentSemiViewController(view, options: options, completion: {
            print("Completed!")
        }, dismissBlock: {
            print("Dismissed!")
        })
        view.onAction { actionType in
            switch actionType {
            case .camera:
                self.callPhoto(from: .camera)
            case .library:
                self.callPhoto(from: .photoLibrary)
            default: ()
            }
        }
    }
    
    @IBAction func removeAvatarButtonPressed(_ sender: UIButton) {
        self.photoImgView.image = #imageLiteral(resourceName: "userpic")
    }
}

extension EditProfileVC: IProfileView {
    func onViewDidLoad() {
        self.loadIndication(displayed: false)
        self.presenter.onViewDidLoad()
    }
    
    func onViewWillAppear() {
        onMainQueue {
            self.presenter.onViewWillAppear()
        }
    }
    
    func updateWith(profile: Profile) {
        self.profile = profile
        firstNameTF.text = profile.firstName
        lastNameTF.text = profile.lastName
        emailTF.text = profile.email
        if let src = profile.avatar {
            photoImgView.setImage(withUrl: URL(string: API.baseUrl + src)!)
        }
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailTF)
            .map({($0.object as! UITextField).text})
            .map({self.profile != nil && self.profile?.email != $0})
            .map({!$0})
            .assign(to: \UIView.isHidden, on: emailVerifyBtn)
            .store(in: &store)
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: firstNameTF)
            .map({($0.object as! UITextField).text})
            .map({self.profile != nil && self.profile?.firstName != $0})
            .sink { (value) in
                self.enableSaveBtn = value
            }.store(in: &store)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: lastNameTF)
            .map({($0.object as! UITextField).text})
            .map({self.profile != nil && self.profile?.lastName != $0})
            .sink { (value) in
                self.enableSaveBtn = value
        }.store(in: &store)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailTF)
            .map({($0.object as! UITextField).text})
            .map({self.profile != nil && self.profile?.email != $0})
            .sink { (value) in
                self.enableSaveBtn = value
        }.store(in: &store)
        
    }
    
    func removeConfirmButton() {
    }
    
    func updateErrorsWithKeyValues(_ dict: [String : String]) -> [String : String] {
        return dict
    }
    
    func loadIndication(displayed: Bool) {
        self.view.isUserInteractionEnabled = !displayed
        self.activityIndicator.isHidden = !displayed
        displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
    }
}

private extension EditProfileVC {
    
    func callPhoto(from source: UIImagePickerController.SourceType) {
        if source == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                if UIImagePickerController.isSourceTypeAvailable(source) {
                    onMainQueue {
                        let ip = UIImagePickerController()
                        ip.delegate = self
                        ip.sourceType = source
                        ip.allowsEditing = false
                        self.present(ip, animated: true, completion: nil)
                    }
                }
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        if UIImagePickerController.isSourceTypeAvailable(source) {
                            onMainQueue {
                                let ip = UIImagePickerController()
                                ip.delegate = self
                                ip.sourceType = source
                                ip.allowsEditing = false
                                self.present(ip, animated: true, completion: nil)
                            }
                        }
                    }
                }
            case .denied: self.showCameraRestrictedAccessAlert() // The user has previously denied access.
            case .restricted: self.showCameraRestrictedAccessAlert() // The user can't grant access due to restrictions.
            @unknown default: ()
            }
        } else {
            if UIImagePickerController.isSourceTypeAvailable(source) {
                onMainQueue {
                    let ip = UIImagePickerController()
                    ip.delegate = self
                    ip.sourceType = source
                    ip.allowsEditing = false
                    self.present(ip, animated: true, completion: nil)
                }
            }
        }
    }
}


extension EditProfileVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        (info[UIImagePickerController.InfoKey.originalImage] as? UIImage).map { image in
            self.photoImgView.image = image
        }
    }
}

private extension EditProfileVC {
    func showCameraRestrictedAccessAlert() {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Please allow camera access in settings",
                   button1Title: "OK",
                   dismissButtonIsHidden: true)
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
}




//swiftlint:disable all
#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct EditProfileVCViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> EditProfileVC {
        return EditProfileVC.storyboardInstance()
    }
    
    func updateUIViewController(_ uiViewController: EditProfileVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct EditProfileVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            EditProfileVCViewRepresentable().previewDevice(PreviewDevice(stringLiteral: "iPhone 8"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }
        
    }
}
#endif
