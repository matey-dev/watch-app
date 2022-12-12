/*
  SellerLotDescriptionView.swift
  SwissWatchApp

  Created by Matey Borisov on 12/16/19.
  Copyright © 2019 Matey Borisov. All rights reserved.
*/

import UIKit

private let cellHeight: CGFloat = 150.0
private let previewImageWidth: CGFloat = 130.0
private let titlesContainerOffset: CGFloat = 15.0

class SellerLotDescriptionView: UIView {
    private var container: UIView?
    private var previewImageView: UIImageView?
    
    private var titlesContainer: UIView?
    
    private var nameLabel: UILabel?
    private var referenceNumberLabel: UILabel?
    
    private var statusLabel: UILabel?
    private var expiresLabel: UILabel?
    private var reactiveLabel: UILabel?
    
    var viewModel: Catalog.LotViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func layoutSubviews() {
        self.updateViewsWithModel()
        super.layoutSubviews()
    }
    
    func configure(with viewModel: Catalog.LotViewModel) {
        self.viewModel = viewModel
        onMainQueue {
            self.updateViewsWithModel()
        }
    }
}

private extension SellerLotDescriptionView {
    func updateViewsWithModel() {
        self.previewImageView?.setImage(withUrl: self.viewModel?.previewURL)
        
        self.viewModel?.nameString
            .map {
                self.nameLabel?.isHidden = false
                self.nameLabel?.text = $0 } ?? {
                    self.nameLabel?.isHidden = true
            }()
        
        self.viewModel?.referenceString
            .map {
                self.referenceNumberLabel?.isHidden = false
                self.referenceNumberLabel?.text = $0 } ?? {
                    self.referenceNumberLabel?.isHidden = true
            }()
        
        self.viewModel?.statusAttributedString
            .map {
                self.statusLabel?.isHidden = false
                self.statusLabel?.attributedText = $0 } ?? {
                    self.statusLabel?.isHidden = true
            }()
        self.viewModel?.expiresAttributedString
            .map {
                self.expiresLabel?.isHidden = false
                self.expiresLabel?.attributedText = $0 } ?? {
                    self.expiresLabel?.isHidden = true
            }()
        self.viewModel.map {
            self.reactiveLabel?.isHidden = !$0.canReactivate
            } ?? {
                self.reactiveLabel?.isHidden = true
            }()
        
        if let sellerStatus = self.viewModel?.lot.sellerStatus {
            switch sellerStatus {
            case .new:
                self.statusLabel?.isHidden = true
                self.expiresLabel?.isHidden = true
            case .sold, .shippedForAuthentication:
                self.expiresLabel?.isHidden = true
            default: ()
            }
        }
    }
    
    func setup() {
        self.setupUI()
    }
    
    // swiftlint:disable function_body_length
    func setupUI() {
        self.backgroundColor = .clear
        
        // CONTAINER
        let container = UIView()
        container.backgroundColor = .white
        self.container = container
        self.addSubview(container)
        
        container.addShadow(color: Colors.white, opacity: 0.89, offset: CGSize(width: 2, height: 2), radius: 3.0)
        
        container.snp.makeConstraints {
            let edges = UIEdgeInsets(top: 12.0,
                                     left: 11.0,
                                     bottom: 12.0,
                                     right: 11.0)
            $0.edges.equalToSuperview().inset(edges)
            $0.height.equalTo(cellHeight)
        }
        
        // PREVIEW IMAGE
        let previewImageView = UIImageView()
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.cornerRadius = 8
        self.previewImageView = previewImageView
        container.addSubview(previewImageView)
        previewImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(previewImageWidth)
        }
        
        // TITLES CONTAINER
        let titlesContainer = UIView()
        titlesContainer.backgroundColor = .clear
        self.titlesContainer = titlesContainer
        self.container?.addSubview(titlesContainer)
        titlesContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(previewImageWidth + titlesContainerOffset)
            $0.trailing.equalToSuperview().offset(-titlesContainerOffset)
        }
        
        // TITLES TOP STACK VIEW
        let topTitlesStackView = UIStackView()
        topTitlesStackView.spacing = 10.0
        topTitlesStackView.axis = .vertical
        topTitlesStackView.distribution = .fillProportionally
        self.titlesContainer?.addSubview(topTitlesStackView)
        topTitlesStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        // NAME
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.85
        nameLabel.font = Fonts.System.semibold(size: 17.0)
        nameLabel.textColor = Colors.blackLight
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        self.nameLabel = nameLabel
        topTitlesStackView.addArrangedSubview(nameLabel)
        
        // REFERENCE NUMBER
        let referenceNumberLabel = UILabel()
        referenceNumberLabel.numberOfLines = 1
        referenceNumberLabel.adjustsFontSizeToFitWidth = true
        referenceNumberLabel.minimumScaleFactor = 0.85
        referenceNumberLabel.font = Fonts.System.medium(size: 12.0)
        referenceNumberLabel.textColor = Colors.blackLight_25opacity
        self.referenceNumberLabel = referenceNumberLabel
        topTitlesStackView.addArrangedSubview(referenceNumberLabel)
        
        // TITLES BOTTOM STACK VIEW
        let bottomTitlesStackView = UIStackView()
        bottomTitlesStackView.spacing = 6.0
        bottomTitlesStackView.axis = .vertical
        bottomTitlesStackView.distribution = .fillEqually
        self.titlesContainer?.addSubview(bottomTitlesStackView)
        bottomTitlesStackView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        // STATUS
        let statusLabel = UILabel()
        statusLabel.numberOfLines = 1
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.85
        self.statusLabel = statusLabel
        bottomTitlesStackView.addArrangedSubview(statusLabel)
        
        // EXPIRES
        let expiresLabel = UILabel()
        expiresLabel.numberOfLines = 1
        expiresLabel.adjustsFontSizeToFitWidth = true
        expiresLabel.minimumScaleFactor = 0.85
        self.expiresLabel = expiresLabel
        bottomTitlesStackView.addArrangedSubview(expiresLabel)
    }
    // swiftlint:enable function_body_length
}
