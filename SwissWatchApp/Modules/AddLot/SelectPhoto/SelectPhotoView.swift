//
//  SelectPhotoView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/2/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import AVKit

typealias SelectPhotoViewAction = ((SelectPhotoViewActionType) -> Void)

enum SelectPhotoViewActionType {
    case back
    case next(image: UIImage, step: AddLotStep)
}

protocol ISelectPhotoView {
    func setStep(_ step: AddLotStep)
}

class SelectPhotoView: BaseViewController, UINavigationControllerDelegate {
    private var step: AddLotStep?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: AddLotProgressView!
    
    private var apnsNetw = ApnsTestAPIService()
    
    var onAction: SelectPhotoViewAction?
    func onAction(_ callback: SelectPhotoViewAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.onViewWillAppear()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.onViewWillLayoutSubviews()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.onAction?(.back)
    }
    
    @IBAction func takeYourPhoto(_ sender: UIButton) {
      self.callPhoto(from: .camera)
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
      self.callPhoto(from: .photoLibrary)
    }
    
    @IBAction func testButton(_ sender: UIButton) {
        #warning("TODO: <temp> REMOVE ME")
      //self.apnsNetw.test(nil)
    }
}

private extension SelectPhotoView {
    func onViewWillAppear() {
        guard let step = self.step else { return }
        self.progressLabel.text = step.progressDescription
        step.imageName.map { self.imageView.image = UIImage(named: $0) }
    }
    
    func onViewWillLayoutSubviews() {
        self.step.map { self.progressBar.updateWithProgress($0.progress) }
    }
    
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

extension SelectPhotoView: ISelectPhotoView {
    func setStep(_ step: AddLotStep) {
        self.step = step
    }
}

extension SelectPhotoView: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        (info[UIImagePickerController.InfoKey.originalImage] as? UIImage).map { image in
            self.step.map { step in
                self.onAction?(.next(image: image, step: step))
            }
        }
    }
}

private extension SelectPhotoView {
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
