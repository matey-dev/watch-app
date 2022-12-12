//
//  AddLotStepVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import LBTATools
import CHIPageControl
import Combine
import SemiModalViewController
import AVKit
import JXPageControl
//swiftlint:disable all
typealias AddLotStepViewAction = ((AddLotStepViewActionType) -> Void)

enum AddLotStepViewActionType {
    case back
    case next(images: [AddLotStepItem: UIImage])
}

class AddLotStepVC: SwiftyCamViewController, UINavigationControllerDelegate {
    
    private var images: [AddLotStepItem: UIImage] = [:]
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.contentInsetAdjustmentBehavior = .never
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.layer.cornerRadius = 6
        cv.layer.borderColor = UIColor(hex: "#202020").withAlphaComponent(0.05).cgColor
        cv.layer.borderWidth = 1
        cv.isScrollEnabled = true
        cv.clipsToBounds = true
        return cv
    }()
    
    let nextBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Next", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.setTitleColor(UIColor(hex: "#F9FAFA"), for: .disabled)
        b.titleLabel?.font = UIFont(name: FontNames.Raleway.semibold, size: 18)
        b.layer.cornerRadius = 6
        b.backgroundColor = .black
        return b
    }()
    
    let backBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
//        b.tintColor = UIColor(hex: "#8F9599")
        b.setImage(#imageLiteral(resourceName: "arrow-back"), for: .normal)
        return b
    }()
    
    let skipBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Skip", for: .normal)
        b.setTitleColor(Colors.grayDarkColor, for: .normal)
        b.titleLabel?.font = UIFont(name: FontNames.Raleway.semibold, size: 18)
        b.layer.cornerRadius = 6
        b.backgroundColor = Colors.grayLightColor
        b.isHidden = true
        return b
    }()
    
    let navBar: UIView = {
        let v = UIView(backgroundColor: .white)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let shutterBtn: CameraButton = {
        let b = CameraButton(frame: .zero)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let flashBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 23
        b.clipsToBounds = true
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.setImage(#imageLiteral(resourceName: "flashlight-line"), for: .normal)
        b.setImage(#imageLiteral(resourceName: "fi_zap-off"), for: .selected)
//        let imageView = UIImageView(image: #imageLiteral(resourceName: "flashlight-line"), contentMode: .scaleAspectFit)
//        b.addSubview(imageView.withSize(CGSize(width: 24, height: 24)))
//        imageView.centerInSuperview()
//        imageView.isUserInteractionEnabled = false
        return b
    }()
    
    let progressBar: AddLotProgressView = {
        let p = AddLotProgressView(frame: .zero)
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    let pageControl: JXPageControlExchange = {
        let pc = JXPageControlExchange()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.activeSize = CGSize(width: 16, height: 4)
        pc.inactiveSize = CGSize(width: 16, height: 4)
        pc.activeColor = UIColor(hex: "#8F9599")
        pc.inactiveColor = UIColor(hex: "#F4F4F4")
        pc.numberOfPages = 5
        pc.currentPage = 0
        pc.columnSpacing = 4
        pc.contentAlignment = JXPageControlAlignment(.center,
                                                     .center)
        pc.contentMode = .center
        return pc
    }()
    
    let frontImgView = AddLotItemThumbnail()
    let sideLeftImgView = AddLotItemThumbnail()
    let sideRightImgView = AddLotItemThumbnail()
    let backImgView = AddLotItemThumbnail()
    let boxImgView = AddLotItemThumbnail()
    
    let titleLbl = UILabel(text: nil, font: UIFont(name: FontNames.Raleway.bold, size: 18), textColor: Colors.blackTextColor, textAlignment: .center, numberOfLines: 1)
    let coverView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    var onAction: AddLotStepViewAction?
    func onAction(_ callback: AddLotStepViewAction?) {
        self.onAction = callback
    }
    
    var store: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        setupNavBar()
        setupAction()
        setupCamera()
        initializeImages()
    }
    
    func initializeImages() {
        self.images = [:]
        self.step = .front
        
        frontImgView.clear()
        sideLeftImgView.clear()
        sideRightImgView.clear()
        backImgView.clear()
        boxImgView.clear()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(coverView)
        coverView.fillSuperview()
        view.addSubview(collectionView)
        view.addSubview(nextBtn.withHeight(45))
        view.addSubview(navBar)
        view.addSubview(progressBar)
        view.addSubview(skipBtn.withHeight(45))
        navBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 48))
        progressBar.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16), size: CGSize(width: 0, height: 8))
        
        collectionView.anchor(top: progressBar.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16))
        
        view.addSubview(shutterBtn.withSize(CGSize(width: 65, height: 65)))
        shutterBtn.centerXToSuperview()
        view.addSubview(flashBtn.withSize(CGSize(width: 46, height: 46)))
        flashBtn.anchor(top: nil, leading: nil, bottom: collectionView.bottomAnchor, trailing: collectionView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 16))
        view.addSubview(pageControl.withHeight(4))
        pageControl.anchor(top: collectionView.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        pageControl.centerXToSuperview()
        let stack = UIStackView(arrangedSubviews: [frontImgView, sideLeftImgView, sideRightImgView, backImgView, boxImgView])
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: pageControl.bottomAnchor, leading: view.leadingAnchor, bottom: nextBtn.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 16, bottom: 28.5, right: 16))
        
        NSLayoutConstraint.activate([
            nextBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextBtn.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8.5),
            skipBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            skipBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            skipBtn.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8.5),
            frontImgView.heightAnchor.constraint(equalTo: frontImgView.widthAnchor),
            shutterBtn.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -13)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLbl.text = step.title
        flashBtn.isSelected = flashMode == .on
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateProgressBar()
        validatePhotos()
    }
    
    private func setupCollectionView() {
        collectionView.register(AddLotStepCell.self, forCellWithReuseIdentifier: AddLotStepCell.reuseIdentifier())
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupNavBar() {
        
        
        navBar.addSubview(backBtn)
        backBtn.anchor(top: navBar.topAnchor, leading: navBar.leadingAnchor, bottom: navBar.bottomAnchor, trailing: nil, size: CGSize(width: 56, height: 48))
        navBar.addSubview(titleLbl)
        titleLbl.centerInSuperview()
    }
    
    private func setupCamera() {
        defaultCamera = .rear
        cameraDelegate = self
        flashMode = .off
        videoQuality = .resolution3840x2160
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = collectionView.frame
//        let height = frame.size.height - 79
//        let y = frame.origin.y + 79
//        frame.origin = CGPoint(x: frame.origin.x, y: y)
//        frame.size = CGSize(width: frame.size.width, height: height)
        setMask(with: frame, in: coverView)
        
    }
    
    private func setupAction() {
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        shutterBtn.action = { [weak self] in
            self?.takePhoto()
        }
        skipBtn.addTarget(self, action: #selector(skip), for: .touchUpInside)
        flashBtn.addTarget(self, action: #selector(flashButtonPressed), for: .touchUpInside)
        frontImgView.deleteAction = { [weak self] in
            self?.images[.front] = nil
            self?.scrollToStepItem(item: .front)
            self?.validatePhotos()
        }
        
        backImgView.deleteAction = { [weak self] in
            self?.images[.back] = nil
            self?.scrollToStepItem(item: .back)
            self?.validatePhotos()
        }
        
        sideLeftImgView.deleteAction = { [weak self] in
            self?.images[.sideLeft] = nil
            self?.scrollToStepItem(item: .sideLeft)
            self?.validatePhotos()
        }
        
        sideRightImgView.deleteAction = { [weak self] in
            self?.images[.sideRight] = nil
            self?.scrollToStepItem(item: .sideRight)
            self?.validatePhotos()
        }
        
        boxImgView.deleteAction = { [weak self] in
            self?.images[.box] = nil
            self?.scrollToStepItem(item: .box)
            self?.validatePhotos()
        }
    }
    
    @objc func back() {
        self.onAction?(.back)
    }
    
    @objc func skip() {
        self.onAction?(.next(images: images))
    }
    
    var dataSrc: [AddLotStepItem] = AddLotStepItem.allCases
    
    func setMask(with hole: CGRect, in view: UIView) {
        
        // Create a mutable path and add a rectangle that will be h
        let mutablePath = CGMutablePath()
        mutablePath.addRect(view.bounds)
//        mutablePath.addRect(hole)
        mutablePath.addRoundedRect(in: hole, cornerWidth: 6, cornerHeight: 6)
        // Create a shape layer and cut out the intersection
        let mask = CAShapeLayer()
        mask.path = mutablePath
        mask.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Add the mask to the view
        view.layer.mask = mask
        
    }
    
    var canScrollToNext: Bool {
        !(images[step] == nil)
    }
    
    @objc func flashButtonPressed() {
        flashBtn.isSelected = !flashBtn.isSelected
        self.flashMode = flashBtn.isEnabled ? .on : .off
    }
    
    @objc func nextItem() {
        guard canScrollToNext else {
            return
        }
        
        guard let nextStep = step.nextStep else {
            if step == .back {
                self.validatePhotos()
                self.nextBtn.sendActions(for: .touchUpInside)
            }
            return
        }
        let nextIndex = nextStep.rawValue - 1
        collectionView.scrollToItem(at: IndexPath(row: nextIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func didTapNext() {
//        guard step != .box else {
//
//            return
//        }
        self.onAction?(.next(images: images))
    }
    
    func scrollToStepItem(item: AddLotStepItem) {
        let index = item.rawValue - 1
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func validatePhotos() {
        let valid = AddLotStepItem.allCases.allSatisfy { (item) -> Bool in
            images[item] != nil
        }
        
        nextBtn.isEnabled = valid
        nextBtn.backgroundColor = valid ? UIColor.black : Colors.grayDarkColor
    }
    
    var step: AddLotStepItem = .front {
        didSet {
            titleLbl.text = step.title
        }
    }
    
    func updateProgressBar() {
        self.progressBar.updateWithProgress(Float(step.rawValue) / 7.0)
        self.pageControl.currentPage = step.rawValue - 1
    }
    
    @objc func showImportSheet() {
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
}

extension AddLotStepVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSrc.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(AddLotStepCell.self, forIndexPath: indexPath, identifier: AddLotStepCell.reuseIdentifier()) else {
            fatalError()
        }
        cell.item = dataSrc[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        step = AddLotStepItem(rawValue: Int(round(value)) + 1)!
        updateProgressBar()
    }
}

extension AddLotStepVC: SwiftyCamViewControllerDelegate {
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        switch step {
        case .front:
            frontImgView.image = photo
            frontImgView.contentMode = .scaleAspectFill
        case .sideLeft:
            sideLeftImgView.image = photo
            sideLeftImgView.contentMode = .scaleAspectFill
        case .sideRight:
            sideRightImgView.image = photo
            sideRightImgView.contentMode = .scaleAspectFill
        case .back:
            backImgView.image = photo
            backImgView.contentMode = .scaleAspectFill
        case .box:
            boxImgView.image = photo
            boxImgView.contentMode = .scaleAspectFill
        }
        images[step] = photo
        validatePhotos()
        nextItem()
    }
    
}

private extension AddLotStepVC {
    
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


extension AddLotStepVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        (info[UIImagePickerController.InfoKey.originalImage] as? UIImage).map { image in
            switch step {
            case .front:
                frontImgView.image = image
                frontImgView.contentMode = .scaleAspectFill
            case .sideLeft:
                sideLeftImgView.image = image
                sideLeftImgView.contentMode = .scaleAspectFill
            case .sideRight:
                sideRightImgView.image = image
                sideRightImgView.contentMode = .scaleAspectFill
            case .back:
                backImgView.image = image
                backImgView.contentMode = .scaleAspectFill
            case .box:
                boxImgView.image = image
                boxImgView.contentMode = .scaleAspectFill
            }
            images[step] = image
            nextItem()
        }
    }
}

private extension AddLotStepVC {
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

class AddLotStepCell: UICollectionViewCell {
    
    let overlayView = UIImageView(image: nil, contentMode: .scaleAspectFit)

    var item: AddLotStepItem! {
        didSet {
            overlayView.image = item.overlayImage
            topConstraint?.constant = item.top
            bottomConstraint?.constant = -item.bottom
            layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("OnboardCell!!!")
    }
    
    var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    
    private func setupCell() {
        contentView.addSubview(overlayView)
        topConstraint = overlayView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        topConstraint.isActive = true
        bottomConstraint = overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -94)
        bottomConstraint.isActive = true
        overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        overlayView.translatesAutoresizingMaskIntoConstraints = false
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        guard let item = item else { return }
//        let width = self.bounds.width - item.overlayPosSize.start.x - item.overlayPosSize.end.x
//        let starty = item.overlayPosSize.start.y
//        let height = self.bounds.height - starty - item.overlayPosSize.end.y
//
//        let frame = CGRect(origin: CGPoint(x: item.overlayPosSize.start.x, y: starty), size: CGSize(width: width, height: height))
//        overlayView.frame = frame
//    }
}

enum AddLotStepItem: Int {
    case front = 1
    case sideLeft = 2
    case sideRight = 3
    case back = 4
    case box = 5
    
    static var allCases: [AddLotStepItem] {
        return [.front,
                .sideLeft,
                .sideRight,
                .back,
                .box]
    }
    
    static var numberOfAllCases: Int {
        return AddLotStep.allCases.count
    }
    
    static var firstStep = AddLotStep.allCases.first
    static var lastStep = AddLotStep.allCases.last
    
    var nextStep: AddLotStepItem? {
        guard self != .box else { return nil }
        return AddLotStepItem(rawValue: self.rawValue + 1)
    }
    
    var prevStep: AddLotStepItem? {
        guard self != .front else { return nil }
        return AddLotStepItem(rawValue: self.rawValue - 1)
    }
    
    var progressDescription: String {
        let raw = self.rawValue
        let total = AddLotStepItem.numberOfAllCases
        return "Step \(String(raw)) out of \(String(total))"
    }
    
    var progressDescriptionAttributedString: NSAttributedString {
        let raw = self.rawValue
        let total = AddLotStepItem.numberOfAllCases
        let string = "Step \(String(raw)) out of \(String(total))"
        
        let font = Fonts.Avenir.medium(size: 14.0)
        let generalColor = Colors.black_50opacity
        let highlightedColor = Colors.black
        let range = NSRange(location: 6, length: 1)
        
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [.font: font,
                                                                      .foregroundColor: generalColor])
        attributedString.addAttribute(.foregroundColor,
                                      value: highlightedColor,
                                      range: range)
        return attributedString
    }
    
    var progress: Float {
        let raw = self.rawValue
        let total = AddLotStepItem.numberOfAllCases
        return Float(raw)/Float(total)
    }
    
    var title: String {
        switch self {
        case .front:
            return "Front side"
        case .sideLeft:
            return "Crown side"
        case .sideRight:
            return "Other side"
        case .back:
            return "Case back"
        case .box:
            return "Box and papers"
        }
    }
        
    var overlayImage: UIImage {
        switch self {
        case .front:
            return #imageLiteral(resourceName: "add_lot_front")
        case .sideLeft:
            return #imageLiteral(resourceName: "add_lot_side")
        case .sideRight:
            return #imageLiteral(resourceName: "add_lot_otherside")
        case .back:
            return #imageLiteral(resourceName: "add_lot_back")
        case .box:
            return #imageLiteral(resourceName: "add_lot_box")
        }
    }
    
    typealias OverlayPosSize = (start: CGPoint, end: CGPoint, factor: CGFloat)
    
    var top: CGFloat {
        switch self {
        case .box:
            return 65.64
        default:
            return 24
        }
    }
    
    var bottom: CGFloat {
        switch self {
        case .box:
            return 128.82
        default:
            return 94
        }
    }
    
    var overlayPosSize: OverlayPosSize {
        switch self {
        case .front:
            return OverlayPosSize(CGPoint(x: 73, y: 97.36), CGPoint(x: 55, y: 23), 215.0 / 263.64)
        case .sideLeft:
            return OverlayPosSize(CGPoint(x: 76, y: 94), CGPoint(x: 85, y: 19.95), 182.0 / 270.05)
        case .sideRight:
            return OverlayPosSize(CGPoint(x: 83, y: 92), CGPoint(x: 83, y: 19.18), 177.0 / 217.82)
        case .back:
            return OverlayPosSize(CGPoint(x: 55, y: 94.16), CGPoint(x: 73, y: 17.07), 215.0 / 272.77)
        case .box:
            return OverlayPosSize(CGPoint(x: 6, y: 65), CGPoint(x: 3, y: 11), 333.91 / 308)
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct AddLotStepVCViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> AddLotStepVC {
        return AddLotStepVC()
    }
    
    func updateUIViewController(_ uiViewController: AddLotStepVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct AddLotStepVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            AddLotStepVCViewRepresentable()
//                .previewDevice(PreviewDevice(stringLiteral: "iPhone 8"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }
        
    }
}
#endif


