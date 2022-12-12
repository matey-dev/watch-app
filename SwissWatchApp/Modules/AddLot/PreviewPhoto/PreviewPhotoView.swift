//
//  PreviewPhotoView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/2/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import AVKit

typealias PreviewPhotoViewAction = ((PreviewPhotoViewActionType) -> Void)

enum PreviewPhotoViewActionType {
    case back
    case next(image: UIImage)
}

protocol IPreviewPhotoView: IAddLotView {
    func setPreviewImage(_ image: UIImage)
}

class PreviewPhotoView: BaseViewController, UINavigationControllerDelegate {
    private var step: AddLotStep?
    private var previewImage: UIImage? {
        didSet {
            self.previewImageView?.image = self.previewImage
        }
    }
    @IBOutlet weak var previewImageView: UIImageView?
    
    var onAction: PreviewPhotoViewAction?
    func onAction(_ callback: PreviewPhotoViewAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.onAction?(.back)
    }
    
    @IBAction func retake(_ sender: UIButton) {
        self.callPhoto(from: .camera)
    }
    
    @IBAction func next(_ sender: UIButton) {
        self.previewImage.map { self.onAction?(.next(image: $0)) }
    }
}

private extension PreviewPhotoView {
    func setup() {
        self.title = nil
        self.previewImageView?.image = self.previewImage
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

extension PreviewPhotoView: IPreviewPhotoView {
    func setStep(_ step: AddLotStep) {
        self.step = step
    }
    
    func setPreviewImage(_ image: UIImage) {
        self.previewImage = image
    }
}

extension PreviewPhotoView: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        (info[UIImagePickerController.InfoKey.originalImage] as? UIImage).map { image in
            self.setPreviewImage(image)
        }
    }
}

private extension PreviewPhotoView {
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
