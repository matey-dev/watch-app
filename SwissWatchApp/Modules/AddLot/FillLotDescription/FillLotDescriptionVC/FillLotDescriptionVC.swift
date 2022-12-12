//
//  FillLotDescriptionVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 16.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import LBTATools
import MagazineLayout
import Combine
//swiftlint:disable all

typealias FillLotDescriptionVCAction = ((FillLotDescriptionVCActionType) -> Void)

enum FillLotDescriptionVCActionType {
    case back
    case next(formData: FillLotFormData)
    case cancel
}

class FillLotDescriptionVC: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: MagazineLayout())
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.backgroundColor = .white
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
    
    let addLotService = AddLotAPIService()
    
    private var images: [UIImage] = []
    private var brands: [Brand] = []
    
    var fillLotFormData = FillLotFormData() {
        didSet {
            self.images = fillLotFormData.images
            self.brands = fillLotFormData.brands
        }
    }
    
//    func setImages(_ images: [UIImage]) {
//        self.images = images
//        self.fillLotFormData.images = images
//    }
//    func setBrands(_ brands: [Brand]) {
//        self.brands = brands
//        self.fillLotFormData.brands = brands
//    }
    
    var onAction: FillLotDescriptionVCAction?
    func onAction(_ callback: FillLotDescriptionVCAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCollectionView()
        setupNavBar()
        setupAction()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(nextBtn.withHeight(45))
        view.addSubview(cancelBtn.withHeight(45))
        view.addSubview(navBar)
        view.addSubview(progressBar)
        navBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 48))
        progressBar.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16), size: CGSize(width: 0, height: 8))
        
        collectionView.anchor(top: progressBar.bottomAnchor, leading: view.leadingAnchor, bottom: nextBtn.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 24, left: 0, bottom: 5, right: 0))
        
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
        self.progressBar.updateWithProgress(6.0/7.0)
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.register(FillLotTextInfoCell.self, forCellWithReuseIdentifier: FillLotTextInfoCell.reuseIdentifier())
        collectionView.register(FillLotDescriptionCell.self
            , forCellWithReuseIdentifier: FillLotDescriptionCell.reuseIdentifier())
        collectionView.register(FillLotDropDownCell.self, forCellWithReuseIdentifier: FillLotDropDownCell.reuseIdentifier())
        collectionView.register(FillLotCheckCell.self, forCellWithReuseIdentifier: FillLotCheckCell.reuseIdentifier())
        collectionView.register(FillLotYearCell.self, forCellWithReuseIdentifier: FillLotYearCell.reuseIdentifier())
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupNavBar() {
        let titleLbl = UILabel(text: "Watch Info", font: UIFont(name: FontNames.Raleway.semibold, size: 18), textColor: UIColor(hex: "#8F9599"), textAlignment: .center, numberOfLines: 1)
        navBar.addSubview(backBtn)
        backBtn.anchor(top: navBar.topAnchor, leading: navBar.leadingAnchor, bottom: navBar.bottomAnchor, trailing: nil, size: CGSize(width: 56, height: 48))
        navBar.addSubview(titleLbl)
        titleLbl.centerInSuperview()
    }
    
    private func setupAction() {
        self.backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.nextBtn.addTarget(self, action: #selector(summary), for: .touchUpInside)
        self.cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    var triedToContinue: Bool = false {
        didSet {
            fillLotFormData.triedToContinue = triedToContinue
        }
    }
    
    @objc func summary() {
        triedToContinue = true
        
        guard fillLotFormData.isValid else {
            self.collectionView.reloadData()
            return
        }
        self.onAction?(.next(formData: fillLotFormData))
    }
    
    @objc func back() {
        self.onAction?(.back)
    }
    
    @objc func cancel() {
        self.onAction?(.cancel)
    }
    
}

extension FillLotDescriptionVC: UICollectionViewDelegateMagazineLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeModeForItemAt indexPath: IndexPath) -> MagazineLayoutItemSizeMode {
        let widthMode = indexPath.section == 2 ? MagazineLayoutItemWidthMode.halfWidth : MagazineLayoutItemWidthMode.fullWidth(respectsHorizontalInsets: true)
        let heightMode = MagazineLayoutItemHeightMode.dynamic
        return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForHeaderInSectionAtIndex index: Int) -> MagazineLayoutHeaderVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForFooterInSectionAtIndex index: Int) -> MagazineLayoutFooterVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForBackgroundInSectionAtIndex index: Int) -> MagazineLayoutBackgroundVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, horizontalSpacingForItemsInSectionAtIndex index: Int) -> CGFloat {
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, verticalSpacingForElementsInSectionAtIndex index: Int) -> CGFloat {
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAtIndex index: Int) -> UIEdgeInsets {
        if index == 2 {
            return UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 7.5)
        }
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemsInSectionAtIndex index: Int) -> UIEdgeInsets {
        if index == 2 {
            return UIEdgeInsets(top: 0, left: 8.5, bottom: 0, right: 8.5)
        }
        return UIEdgeInsets.zero
    }
    
}

extension FillLotDescriptionVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        fillLotFormData.sections.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fillLotFormData.sections[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fillLotFormData.getCell(collectionView, for: indexPath)
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: { context in
//            self.collectionView.collectionViewLayout.invalidateLayout()
//        }, completion: nil)
//    }
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct FillLotDescriptionVCViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> FillLotDescriptionVC {
        return FillLotDescriptionVC()
    }
    
    func updateUIViewController(_ uiViewController: FillLotDescriptionVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct FillLotDescriptionVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            FillLotDescriptionVCViewRepresentable().previewDevice(PreviewDevice(stringLiteral: "iPhone X"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }
        
    }
}
#endif

//swiftlint:disable all
