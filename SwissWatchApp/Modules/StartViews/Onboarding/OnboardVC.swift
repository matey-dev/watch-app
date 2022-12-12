//
//  OnboardVC.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 11.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import UIKit
import LBTATools
import CHIPageControl

class OnboardVC: UIViewController {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.contentInsetAdjustmentBehavior = .never
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    let nextBtn: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Next", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: FontNames.Raleway.semibold, size: 18)
        b.layer.cornerRadius = 6
        b.backgroundColor = Colors.blackTextColor
        return b
    }()
    
    let navBar: UIView = {
        let v = UIView(backgroundColor: .white)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let pageControl: CHIPageControlJaloro = {
        let pc = CHIPageControlJaloro()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = 3
        pc.currentPageTintColor = Colors.grayDarkColor
        pc.tintColor = UIColor(hex: "#F2F2F2")
        pc.progress = 0
        pc.radius = 1
        pc.padding = 4
        pc.elementWidth = 32
        pc.elementHeight = 4
        return pc
    }()
    
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
        view.addSubview(navBar)
        view.addSubview(pageControl)
        navBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: CGSize(width: 0, height: 48))
        collectionView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: nextBtn.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 19, left: 0, bottom: 50, right: 0))
        pageControl.anchor(top: collectionView.bottomAnchor, leading: view.leadingAnchor, bottom: nextBtn.topAnchor, trailing: view.trailingAnchor)
        NSLayoutConstraint.activate([
            nextBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextBtn.widthAnchor.constraint(equalToConstant: 163)
        ])
    }
    
    var currentIndex = 0 {
        didSet {
            if currentIndex == 2 {
                nextBtn.setTitle("Start", for: .normal)
            } else {
                nextBtn.setTitle("Next", for: .normal)
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(OnboardCell.self, forCellWithReuseIdentifier: OnboardCell.reuseIdentifier())
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupNavBar() {
        let logo = UIImageView(image: #imageLiteral(resourceName: "watch_logo_small"), contentMode: .scaleAspectFit)
        let titleLbl = UILabel(text: "Welcome to WatchValue", font: UIFont(name: FontNames.Raleway.semibold, size: 18), textColor: Colors.blackTextColor, textAlignment: .center, numberOfLines: 1)
        navBar.addSubview(logo)
        logo.anchor(top: navBar.topAnchor, leading: navBar.leadingAnchor, bottom: navBar.bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: 5, left: 14, bottom: 5, right: 0))
        navBar.addSubview(titleLbl)
        titleLbl.centerYToSuperview()
        titleLbl.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 42).isActive = true
        
    }
    
    private func setupAction() {
        nextBtn.addTarget(self, action: #selector(addLot), for: .touchUpInside)
    }
    
    var dataSrc: [OnboardItem] = [.step1, .step2, .step3]
    
    var onAction: OnboardingViewAction?
    func onAction(_ callback: OnboardingViewAction?) {
        self.onAction = callback
    }
    
    @objc func done() {
        self.onAction?(.done)
    }
    
    @objc func addLot() {
        if currentIndex == 2 {
            self.onAction?(.done)
        } else {
            let nextIndex = currentIndex + 1
            collectionView.scrollToItem(at: IndexPath(row: nextIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}

enum OnboardItem: String {
    case step1 = "Step 1"
    case step2 = "Step 2"
    case step3 = "Step 3"
    
    var descriptionString: String {
        switch self {
        case .step1:
            return "Grab your watch\n"
        case .step2:
            return "Take a few\nphotos"
        case .step3:
            return "Receive tons of\noffers and sell it!"
        }
    }
    
    var image: UIImage {
        switch self {
        case .step1:
            return #imageLiteral(resourceName: "onboard_step1")
        case .step2:
            return #imageLiteral(resourceName: "onboard_step2")
        case .step3:
            return #imageLiteral(resourceName: "onboard_step3")
        }
    }
}

extension OnboardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSrc.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(OnboardCell.self, forIndexPath: indexPath, identifier: OnboardCell.reuseIdentifier()) else {
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
        currentIndex = Int(round(value))
        self.pageControl.progress = Double(currentIndex)
    }
}

class OnboardCell: UICollectionViewCell {
    
    let titleLbl = UILabel(text: "Step 1", font: UIFont(name: FontNames.SFProDisplay.medium, size: 18), textColor: Colors.cyanColor, textAlignment: .center, numberOfLines: 1)
    
    let descriptionLbl = UILabel(text: "Describe your\nwatch", font: UIFont(name: FontNames.Raleway.bold, size: 32), textColor: Colors.blackTextColor, textAlignment: .center, numberOfLines: 2)
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "onboard_step1"), contentMode: .scaleAspectFit)
    
    var item: OnboardItem! {
        didSet {
            titleLbl.text = item.rawValue
            descriptionLbl.text = item.descriptionString
            imageView.image = item.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("OnboardCell!!!")
    }
    
    private func setupCell() {
        let stack = UIStackView(arrangedSubviews: [titleLbl, imageView, descriptionLbl])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 32
        stack.alignment = .center
        stack.distribution = .fill
        
        stack.setCustomSpacing(25, after: imageView)
        
        titleLbl.setContentHuggingPriority(.defaultHigh, for: .vertical)
        descriptionLbl.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLbl.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        descriptionLbl.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        contentView.addSubview(stack)
        stack.fillSuperview(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct OnboardVCViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> OnboardVC {
        return OnboardVC()
    }
    
    func updateUIViewController(_ uiViewController: OnboardVC, context: Context) {
    }
}

@available(iOS 13.0, *)
struct OnboardVCPreview: PreviewProvider {
    static var previews: some View {
        return Group {
            OnboardVCViewRepresentable().previewDevice(PreviewDevice(stringLiteral: "iPhone X"))
                .edgesIgnoringSafeArea(.all)
                .statusBar(hidden: false)
        }
        
    }
}
#endif
