//
//  AddLotSummaryVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 16.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import LBTATools
import MagazineLayout
import Combine
import ImageViewer
//swiftlint:disable all

typealias LotSummaryVCAction = ((LotSummaryVCActionType) -> Void)

enum LotSummaryVCActionType {
    case back
    case submitSuccess
    case cancel
}

class LotSummaryVC: UIViewController {
    
    let detailVC: LotDetailVC
    
    let addLotService = AddLotAPIService()
    
    let nextBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Next", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.setTitleColor(UIColor(hex: "#F9FAFA"), for: .disabled)
        b.titleLabel?.font = UIFont(name: FontNames.Raleway.semibold, size: 18)
        b.layer.cornerRadius = 6
        //        b.backgroundColor = UIColor(hex: "#8F9599")
        b.backgroundColor = .black
        return b
    }()
    
    let cancelBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Cancel", for: .normal)
        b.setTitleColor(Colors.grayDarkColor, for: .normal)
        b.titleLabel?.font = UIFont(name: FontNames.Raleway.semibold, size: 18)
        b.layer.cornerRadius = 6
        b.backgroundColor = Colors.grayLightColor
        return b
    }()
    
    let backBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        //        b.tintColor = UIColor(hex: "#8F9599")
        b.setImage(#imageLiteral(resourceName: "arrow-back"), for: .normal)
        return b
    }()
    
    let navBar: UIView = {
        let v = UIView(backgroundColor: .white)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let progressBar: AddLotProgressView = {
        let p = AddLotProgressView(frame: .zero)
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.color = .darkGray
        return s
    }()
    
    
    private var images: [UIImage] = [] {
        didSet {
            self.items = []
            for image in images {
                let imgView = UIImageView()
                let galleryItem = GalleryItem.image { imageCompletion in
                    imgView.image = image
                    imageCompletion(image)
                }
                self.items.append(DataItem(imageView: imgView, galleryItem: galleryItem))
            }
        }
    }
    private var brands: [Brand] = []
    
    var fillLotFormData: FillLotFormData
    
    init(formData: FillLotFormData) {
        self.fillLotFormData = formData
        self.detailVC = LotDetailVC(formData: formData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImages(_ images: [UIImage]) {
        self.images = images
    }
    func setBrands(_ brands: [Brand]) {
        self.brands = brands
    }
    var items: [DataItem] = []
    var onAction: LotSummaryVCAction?
    func onAction(_ callback: LotSummaryVCAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavBar()
        setupTableView()
        setupAction()
        
        detailVC.showImageAction = { [weak self] index in
            self?.showImage(at: index)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(nextBtn.withHeight(45))
        view.addSubview(cancelBtn.withHeight(45))
        view.addSubview(navBar)
        view.addSubview(progressBar)
        navBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 48))
        progressBar.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16), size: CGSize(width: 0, height: 8))
        
        NSLayoutConstraint.activate([
            nextBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextBtn.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8.5),
            cancelBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelBtn.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8.5)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressBar.updateWithProgress(1.0)
    }
    
    private func setupTableView() {
        view.addSubview(detailVC.tableView)
        detailVC.tableView.anchor(top: progressBar.bottomAnchor, leading: view.leadingAnchor, bottom: nextBtn.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 24, left: 0, bottom: 5, right: 0))
        view.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
    }
    
    private func setupNavBar() {
        let titleLbl = UILabel(text: "Summary", font: UIFont(name: FontNames.Raleway.semibold, size: 18), textColor: UIColor(hex: "#8F9599"), textAlignment: .center, numberOfLines: 1)
        navBar.addSubview(backBtn)
        backBtn.anchor(top: navBar.topAnchor, leading: navBar.leadingAnchor, bottom: navBar.bottomAnchor, trailing: nil, size: CGSize(width: 56, height: 48))
        navBar.addSubview(titleLbl)
        titleLbl.centerInSuperview()
    }
    
    private func setupAction() {
        self.backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.nextBtn.addTarget(self, action: #selector(submit), for: .touchUpInside)
        self.cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }
    
    @objc func submit() {
        
        self.loadIndication(displayed: true)
        
        self.addLotService.sendLot(
            brand: fillLotFormData.brand ?? -1,
            year: fillLotFormData.year ?? "",
            box: fillLotFormData.box,
            documents: fillLotFormData.document,
            model: fillLotFormData.model ?? "",
            reference: fillLotFormData.referenceNo ?? "", description: fillLotFormData.detail ?? "",
            images: images) { [weak self] lot_id in
                guard let self = self else { return }
                if let lot_id = lot_id {
//                    NotificationCenter.default.post(name: NSNotification.Name("newLot"), object: self.fillLotFormData)
                    self.addLotService.sendNewLotApn(lotId: lot_id)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.onAction?(.submitSuccess)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.loadIndication(displayed: false)
                    }
                } else {
                    self.loadIndication(displayed: false)
                    self.showError(title: "Error",
                                   message: "Unexpected error")
                }
        }
    }
    
    @objc func back() {
        self.onAction?(.back)
    }
    
    @objc func cancel() {
        self.onAction?(.cancel)
    }
    
    private func showImage(at index: Int) {
        let galleryVC = GalleryViewController(startIndex: 0, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: nil, configuration: galleryConfiguration())
        presentImageGallery(galleryVC)
    }
    
    private func showImage(_ image: UIImage?) {
        let imgView = UIImageView()
        let galleryItem = GalleryItem.image { imageCompletion in
            guard let image = image else {
                return
            }
            imgView.image = image
            imageCompletion(image)
        }
        self.items = [DataItem(imageView: imgView, galleryItem: galleryItem)]
        let galleryVC = GalleryViewController(startIndex: 0, itemsDataSource: self, itemsDelegate: nil, displacedViewsDataSource: nil, configuration: galleryConfiguration())
        presentImageGallery(galleryVC)
    }
    
    private func galleryConfiguration() -> GalleryConfiguration {
        return [.swipeToDismissMode(.never),  .thumbnailsButtonMode(.none), .deleteButtonMode(.none)]
    }
}

extension UIImageView: DisplaceableView {}

struct DataItem {
    
    let imageView: UIImageView
    let galleryItem: GalleryItem
}

extension LotSummaryVC: GalleryItemsDataSource {
    func itemCount() -> Int {
        return items.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return items[index].galleryItem
    }
}

private extension LotSummaryVC {
    func validateYear(fields: [FillLotModel.Field]) -> Bool {
        let year = fields.first(where: { $0.key == .model_year })?.text ?? ""
        guard !year.isEmpty else { return true }
        guard let intYear = Int(year) else { return true }
        let currentYear = Calendar.current.component(.year, from: Date())
        if intYear > currentYear || intYear < 1600 {
            return false
        } else {
            return true
        }
    }
    
    func callAddLotApiWithModels(fields: [FillLotModel.Field], checks: [FillLotModel.CheckBox]) {
        let brand = fields.first(where: { $0.key == .watch_name })?.id ?? -1
        let model = fields.first(where: { $0.key == .watch_model })?.text ?? ""
        let year = fields.first(where: { $0.key == .model_year })?.text ?? ""
        let reference = fields.first(where: { $0.key == .reference_no })?.text ?? ""
        let box = checks.first(where: { $0.key == .box })?.checked ?? false
        let documents = checks.first(where: { $0.key == .documents })?.checked ?? false
        let images = self.images
        let description = fields.first(where: { $0.key == .description })?.text ?? ""
        
        self.loadIndication(displayed: true)
        
        self.addLotService.sendLot(
            brand: brand,
            year: year,
            box: box,
            documents: documents,
            model: model,
            reference: reference, description: description,
            images: images) { [weak self] lot_id in
                guard let self = self else { return }
                if let lot_id = lot_id {
                    self.addLotService.sendNewLotApn(lotId: lot_id)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.onAction?(.submitSuccess)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.loadIndication(displayed: false)
                    }
                } else {
                    self.loadIndication(displayed: false)
                    self.showError(title: "Error",
                                   message: "Unexpected error")
                }
        }
    }
    
    func showError(title: String,
                   message: String) {
        onMainQueue {
            self.showAlert(title: title,
                           message: message)
        }
    }
}

extension LotSummaryVC {
    
//    func updateErrorsWithKeyValues(_ dict: [String: String]) -> [String: String] {
//        let cantFind = self.tableViewDataAdapter?.updateErrorsWithKeyValues(dict) ?? [:]
//        onMainQueue {
//            self.tableView.reloadData()
//        }
//        return cantFind
//    }
    
    func loadIndication(displayed: Bool) {
        onMainQueue {
            self.view.isUserInteractionEnabled = !displayed
            self.activityIndicator.isHidden = !displayed
            displayed ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        }
    }
}

private extension LotSummaryVC {
    func showAddLotAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Your post will become visible",
                   button1Title: "Confirm",
                   button2Title: "Cancel",
                   button1Style: .black,
                   button2Style: .white,
                   dismissButtonIsHidden: true)
        view.onAction { actionType in
            switch actionType {
            case .one:
                confirm?()
            default: ()
            }
        }
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
    
    func showInvalidYearAlert(_ confirm: (() -> Void)?) {
        let view = DialogView.storyboardInstance()
        view.modalPresentationStyle = .overCurrentContext
        view.modalTransitionStyle = .crossDissolve
        view.setup(title: "Invalid Year",
                   button1Title: "OK",
                   dismissButtonIsHidden: true)
        view.onAction { actionType in
            switch actionType {
            case .one:
                confirm?()
            default: ()
            }
        }
        self.tabBarController?.present(view, animated: true, completion: nil)
    }
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct LotSummaryVCViewRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> LotSummaryVC {
        return LotSummaryVC(formData: FillLotFormData())
    }

    func updateUIViewController(_ uiViewController: LotSummaryVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct LotSummaryVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            LotSummaryVCViewRepresentable().previewDevice(PreviewDevice(stringLiteral: "iPhone X"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }

    }
}
#endif
