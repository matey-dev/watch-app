//
//  OnboardingView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/16/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias OnboardingViewAction = ((OnboardingViewActionType) -> Void)
enum OnboardingViewActionType {
    case done
    case addLot
}

class OnboardingView: BaseViewController {
    private var verticalInsets: CGFloat {
        return (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        + (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
    }
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var onAction: OnboardingViewAction?
    func onAction(_ callback: OnboardingViewAction?) {
        self.onAction = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.onViewDidLoad()
    }
}

private extension OnboardingView {
    func onViewDidLoad() {
        self.setup()
    }
    
    func setup() {
        self.setupScrollView()
        self.setupPageControl()
    }
    
    func setupPageControl() {
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
    }
    
    func setupScrollView() {
        guard let sv = self.scroll else { return }
        sv.delegate = self
        
        let w = self.view.frame.width
        let h = self.view.frame.height - 10 - verticalInsets
        
        self.setupFirstPage()
        self.setupSecondPage()
        self.setupThirdPage()
        
        sv.contentSize = CGSize(width: w*3, height: h)
    }
    
    func setupFirstPage() {
        guard let sv = self.scroll else { return }
        let w = self.view.frame.width
        let h = self.view.frame.height - 10 - self.verticalInsets
        
        let page = UIView()
        sv.addSubview(page)
        page.frame = CGRect(x: 0, y: 0, width: w, height: h)
        page.backgroundColor = .clear
        sv.addSubview(page)
        
        let b = GeneralButton()
        b.setTitle("Next", for: .normal)
        b.addTarget(self,
                     action: #selector(moveToNextPage),
                     for: .touchUpInside)
        page.addSubview(b)
        b.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(55)
        }
        
        let titlesContainer = UIView()
        titlesContainer.backgroundColor = .clear
        page.addSubview(titlesContainer)
        titlesContainer.snp.makeConstraints {
            $0.height.equalTo(235)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(b.snp.top)
        }
        
        let title = UILabel()
        title.text = "Welcome to Watch Value"
        title.numberOfLines = 1
        title.textAlignment = .center
        title.minimumScaleFactor = 0.85
        title.adjustsFontSizeToFitWidth = true
        title.font = Fonts.System.semibold(size: 28)
        title.textColor = Colors.blackLight
        titlesContainer.addSubview(title)
        title.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(30)
        }
        
        let subTitle = UILabel()
        subTitle.text = "The easiest way to sell your luxury watch"
        subTitle.numberOfLines = 3
        subTitle.textAlignment = .center
        subTitle.minimumScaleFactor = 0.85
        subTitle.adjustsFontSizeToFitWidth = true
        subTitle.font = Fonts.System.medium(size: 20)
        subTitle.textColor = Colors.blackLight_90opacity
        titlesContainer.addSubview(subTitle)
        subTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(title.snp.bottom).offset(20)
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "onboard1")
        page.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(titlesContainer.snp.top)
        }
    }
    
    func setupSecondPage() {
        guard let sv = self.scroll else { return }
        let w = self.view.frame.width
        let h = self.view.frame.height - 10 - self.verticalInsets
        
        let page = UIView()
        sv.addSubview(page)
        page.frame = CGRect(x: w, y: 0, width: w, height: h)
        page.backgroundColor = .clear
        sv.addSubview(page)
        
        let b = GeneralButton()
        b.setTitle("Next", for: .normal)
        b.addTarget(self,
                     action: #selector(moveToNextPage),
                     for: .touchUpInside)
        page.addSubview(b)
        b.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(55)
        }
        
        let titlesContainer = UIView()
        titlesContainer.backgroundColor = .clear
        page.addSubview(titlesContainer)
        titlesContainer.snp.makeConstraints {
            $0.height.equalTo(235)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(b.snp.top)
        }
        
        let title = UILabel()
        title.text = "Create a post"
        title.numberOfLines = 1
        title.textAlignment = .center
        title.minimumScaleFactor = 0.85
        title.adjustsFontSizeToFitWidth = true
        title.font = Fonts.System.semibold(size: 28)
        title.textColor = Colors.blackLight
        titlesContainer.addSubview(title)
        title.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(30)
        }
        
        let subTitle = UILabel()
        subTitle.text = "Photograph your watch and post it"
        subTitle.numberOfLines = 3
        subTitle.textAlignment = .center
        subTitle.minimumScaleFactor = 0.85
        subTitle.adjustsFontSizeToFitWidth = true
        subTitle.font = Fonts.System.medium(size: 20)
        subTitle.textColor = Colors.blackLight_90opacity
        titlesContainer.addSubview(subTitle)
        subTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(title.snp.bottom).offset(20)
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "onboard2")
        page.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(titlesContainer.snp.top)
        }
    }
    
    func setupThirdPage() {
        guard let sv = self.scroll else { return }
        let w = self.view.frame.width
        let h = self.view.frame.height - 10 - self.verticalInsets
        
        let page = UIView()
        sv.addSubview(page)
        page.frame = CGRect(x: w*2, y: 0, width: w, height: h)
        page.backgroundColor = .clear
        sv.addSubview(page)
        
        let b = GeneralButton()
        b.setTitle("Let's start", for: .normal)
        b.addTarget(self,
                     action: #selector(done),
                     for: .touchUpInside)
        page.addSubview(b)
        b.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview().inset(55)
        }
        
        let titlesContainer = UIView()
        titlesContainer.backgroundColor = .clear
        page.addSubview(titlesContainer)
        titlesContainer.snp.makeConstraints {
            $0.height.equalTo(235)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(b.snp.top)
        }
        
        let title = UILabel()
        title.text = "Sell easy"
        title.numberOfLines = 1
        title.textAlignment = .center
        title.minimumScaleFactor = 0.85
        title.adjustsFontSizeToFitWidth = true
        title.font = Fonts.System.semibold(size: 28)
        title.textColor = Colors.blackLight
        titlesContainer.addSubview(title)
        title.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(30)
        }
        
        let subTitle = UILabel()
        subTitle.text = "Get tons of offers from verified dealers and pick the best one"
        subTitle.numberOfLines = 3
        subTitle.textAlignment = .center
        subTitle.minimumScaleFactor = 0.85
        subTitle.adjustsFontSizeToFitWidth = true
        subTitle.font = Fonts.System.medium(size: 20)
        subTitle.textColor = Colors.blackLight_90opacity
        titlesContainer.addSubview(subTitle)
        subTitle.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(title.snp.bottom).offset(20)
        }
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "onboard3")
        page.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(titlesContainer.snp.top)
        }
    }
    
    @objc func moveToNextPage() {
        guard let sv = self.scroll else { return }
        
        let pageWidth: CGFloat = sv.frame.width
        let maxWidth: CGFloat = pageWidth * 3
        let contentOffset: CGFloat = sv.contentOffset.x
        
        var slideToX = contentOffset + pageWidth
        
        if  contentOffset + pageWidth == maxWidth {
            slideToX = 0
        }
        sv.scrollRectToVisible(CGRect(x: slideToX,
                                      y: 0,
                                      width: pageWidth,
                                      height: sv.frame.height),
                               animated: true)
    }
    
    @objc func done() {
        self.onAction?(.done)
    }
}

extension OnboardingView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        self.pageControl.currentPage = Int(round(value))
    }
}
