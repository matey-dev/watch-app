//
//  CatalogTableViewBigCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 12/16/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Hero

private let previewImageWidth: CGFloat = 130.0
private let titlesContainerOffset: CGFloat = 15.0
private let previewImageViewInactiveOpacity: CGFloat = 0.6
private let previewImageViewActiveOpacity: CGFloat = 1.0

class CatalogTableViewBigCell: UITableViewCell {
    weak var tapDelegate: CatalogTableViewCellDelegate?
    
    private var container: UIView?
    private var previewImageView: UIImageView?
    var customImageView: UIImageView? {
        return self.previewImageView
    }
    
    private var titlesContainer: UIView?
    
    private var nameLabel: UILabel?
    private var referenceNumberLabel: UILabel?
    
    private var statusLabel: UILabel?
    private var expiresLabel: UILabel?
    private var appraisalsLabel: UILabel?
    
    var viewModel: Catalog.LotViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.viewModel = nil
        self.previewImageView?.heroID = nil
        self.clear()
    }
    
    private func clear() {
        let labels = [self.nameLabel, self.referenceNumberLabel, self.statusLabel, self.expiresLabel, self.appraisalsLabel]
        labels.forEach {
            $0?.text = nil
            $0?.isHidden = false
        }
        
        self.setPreviewImage(active: false)
    }
    
    func configure(with viewModel: Catalog.LotViewModel) {
        self.viewModel = viewModel
        self.updateViewsWithModel()
    }
}

private extension CatalogTableViewBigCell {
    func updateViewsWithModel() {
        
        if let image = self.viewModel?.previewImage {
            self.previewImageView?.image = image
        } else {
            self.viewModel?.previewURL.map {
                self.previewImageView?.setImage(withUrl: $0)
            } ?? {
                self.previewImageView?.image = nil
            }()
        }
        
        self.previewImageView?.heroID = "photo\(self.viewModel?.lot.id ?? 0)"
        
        self.viewModel?.nameString
            .map {
                self.nameLabel?.isHidden = false
                self.nameLabel?.text = $0 } ?? {
                    self.nameLabel?.isHidden = true
            }()
        self.nameLabel?.heroID = "name\(self.viewModel?.lot.id ?? 0)"
        self.viewModel?.referenceString
            .map {
                self.referenceNumberLabel?.isHidden = false
                self.referenceNumberLabel?.text = $0 } ?? {
                    self.referenceNumberLabel?.isHidden = true
            }()
        self.referenceNumberLabel?.heroID = "ref\(self.viewModel?.lot.id ?? 0)"
        self.viewModel?.statusAttributedString
            .map {
                self.statusLabel?.isHidden = false
                self.statusLabel?.attributedText = $0 } ?? {
                    self.statusLabel?.isHidden = true
            }()
        self.statusLabel?.heroID = "status\(self.viewModel?.lot.id ?? 0)"
        self.viewModel?.expiresAttributedString
            .map {
                self.expiresLabel?.isHidden = false
                self.expiresLabel?.attributedText = $0 } ?? {
                    self.expiresLabel?.isHidden = true
            }()
        
        if let hintString = self.viewModel?.hintString {
            self.appraisalsLabel?.isHidden = false
            self.appraisalsLabel?.text = hintString
            if hintString.lowercased().contains("0") {
                self.appraisalsLabel?.textColor = Colors.blackLight_80opacity
            } else {
                self.appraisalsLabel?.textColor = Colors.orange
            }
        } else if let appraisalString = self.viewModel?.appraisalAttributedString {
            self.appraisalsLabel?.isHidden = false
            self.appraisalsLabel?.attributedText = appraisalString
        } else {
            self.appraisalsLabel?.isHidden = true
        }
        
        var previewImageActive = true
        if let sellerStatus = self.viewModel?.lot.sellerStatus {
            switch sellerStatus {
            case .new:
//                self.statusLabel?.isHidden = true
                self.expiresLabel?.isHidden = true
            case .sold, .shippedForAuthentication:
                self.expiresLabel?.isHidden = true
                self.appraisalsLabel?.isHidden = true
                previewImageActive = false
            default: ()
            }
        } else if let dealerStatus = self.viewModel?.lot.dealerStatus {
            switch dealerStatus {
            case .new:
//                self.statusLabel?.isHidden = true
                self.expiresLabel?.isHidden = true
            case .shipping:
                self.expiresLabel?.isHidden = true
                self.appraisalsLabel?.isHidden = true
                previewImageActive = false
            default: ()
            }
        }
        
        self.setPreviewImage(active: previewImageActive)
    }
    
    func setPreviewImage(active: Bool) {
        self.setPreviewImageViewAlpha(active ? previewImageViewActiveOpacity : previewImageViewInactiveOpacity)
    }
    
    func setPreviewImageViewAlpha(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.previewImageView?.alpha = alpha
        }
    }
    
    func setup() {
        self.setupUI()
    }
    
    // swiftlint:disable function_body_length
    func setupUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // CONTAINER
        let container = UIView()
        container.backgroundColor = .white
        container.clipsToBounds = true
        container.layer.cornerRadius = 6
        self.container = container
        self.contentView.addSubview(container)
        
        container.snp.makeConstraints {
            let edges = UIEdgeInsets(top: 8.0,
                                     left: 16.0,
                                     bottom: 8.0,
                                     right: 16.0)
            $0.edges.equalToSuperview().inset(edges)
        }
        
        // PREVIEW IMAGE
        let previewImageView = UIImageView()
        previewImageView.alpha = previewImageViewInactiveOpacity
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.cornerRadius = 0
        previewImageView.backgroundColor = .lightGray
        self.previewImageView = previewImageView
        container.addSubview(previewImageView)
        previewImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(previewImageView.snp.width).multipliedBy(261.0 / 343.0)
        }
        
        // TITLES CONTAINER
        let titlesContainer = UIView()
        titlesContainer.backgroundColor = .clear
        titlesContainer.layer.cornerRadius = 6
        titlesContainer.layer.borderWidth = 1
        titlesContainer.layer.borderColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 0.05).cgColor
        titlesContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.titlesContainer = titlesContainer
        self.container?.addSubview(titlesContainer)
        titlesContainer.snp.makeConstraints {
            $0.top.equalTo(previewImageView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            //$0.height.equalTo(100)
        }
        
        // TITLES TOP STACK VIEW
        
        // NAME
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.95
        nameLabel.font = UIFont(name: "SFProText-Semibold", size: 18)
        nameLabel.textColor = UIColor(red: 0.063, green: 0.118, blue: 0.161, alpha: 1)
        nameLabel.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(52)
        }
        self.nameLabel = nameLabel
        
        // REFERENCE NUMBER
        let referenceNumberLabel = UILabel()
        referenceNumberLabel.numberOfLines = 1
        referenceNumberLabel.adjustsFontSizeToFitWidth = true
        referenceNumberLabel.minimumScaleFactor = 0.85
        referenceNumberLabel.font = UIFont(name: "SFProDisplay-Regular", size: 14)
        referenceNumberLabel.textColor = UIColor(red: 0.561, green: 0.584, blue: 0.6, alpha: 1)
        referenceNumberLabel.textAlignment = .right
        self.referenceNumberLabel = referenceNumberLabel
        
        // STATUS
        let statusLabel = UILabel()
        statusLabel.numberOfLines = 1
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.85
        self.statusLabel = statusLabel
        
        // EXPIRES
        let expiresLabel = UILabel()
        expiresLabel.numberOfLines = 1
        expiresLabel.adjustsFontSizeToFitWidth = true
        expiresLabel.minimumScaleFactor = 0.85
        self.expiresLabel = expiresLabel
        
        // APPRAISALS
        let appraisalsLabel = UILabel()
        appraisalsLabel.numberOfLines = 1
        appraisalsLabel.adjustsFontSizeToFitWidth = true
        appraisalsLabel.minimumScaleFactor = 0.85
        appraisalsLabel.font = Fonts.System.medium(size: 13.0)
        appraisalsLabel.textColor = Colors.blue
        
        self.appraisalsLabel = appraisalsLabel
        
        titlesContainer
            .stack(
                   hstack(nameLabel,
                          referenceNumberLabel.withWidth(61),
                          spacing: 23,
                          alignment: .firstBaseline,
                          distribution: .fill),
                   self.statusLabel!,
                   spacing: 12,
                   alignment: .fill,
            distribution: .fill)
            .withMargins(UIEdgeInsets(top: 14, left: 16, bottom: 16, right: 16))
        
        // BUTTON ACTION
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.backgroundColor = .clear
        self.container?.addSubview(button)
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    // swiftlint:enable function_body_length
    
    @objc func buttonAction() {
        guard let model = self.viewModel,
        let tableType = model.tableType else { return }
        
        var canDidTapLot: Bool = false
        
        switch tableType {
        case .general:
            canDidTapLot = true
        case .archive:
            if (model.lot.archiveStatus ?? .undefined) == .expired {
                canDidTapLot = true
            }
        }
        
        if canDidTapLot {
            self.tapDelegate?.didTapLot(model.lot)
        }
    }
}
