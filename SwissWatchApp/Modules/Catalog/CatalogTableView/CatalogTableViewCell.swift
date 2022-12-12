//
//  CatalogTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/7/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import MGSwipeTableCell

private let cellHeight: CGFloat = 150.0
private let previewImageWidth: CGFloat = 130.0
private let titlesContainerOffset: CGFloat = 15.0

protocol CatalogTableViewCellDelegate: class {
    func didTapLot(_ lot: Catalog.Lot)
}

class CatalogTableViewCell: MGSwipeTableCell {
    weak var tapDelegate: CatalogTableViewCellDelegate?
    
    private var container: UIView?
    private var previewImageView: UIImageView?
    
    private var titlesContainer: UIView?
    
    private var nameLabel: UILabel?
    private var referenceNumberLabel: UILabel?
    
    private var statusLabel: UILabel?
    private var expiresLabel: UILabel?
    private var appraisalsLabel: UILabel?
    private var reactiveLabel: UILabel?
    
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
            $0?.attributedText = nil
            $0?.isHidden = false
        }
        
        self.reactiveLabel?.isHidden = false
        self.previewImageView?.image = nil
    }
    
    func configure(with viewModel: Catalog.LotViewModel) {
        self.viewModel = viewModel
        self.updateViewsWithModel()
    }
}

private extension CatalogTableViewCell {
    func updateViewsWithModel() {
        if let image = self.viewModel?.previewImage {
            self.previewImageView?.image = image
        } else {
            self.previewImageView?.setImage(withUrl: self.viewModel?.previewURL)
        }
        
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
        
        if let hintString = self.viewModel?.hintString {
            self.appraisalsLabel?.isHidden = false
            self.appraisalsLabel?.text = hintString
        } else if let appraisalString = self.viewModel?.appraisalAttributedString {
            self.appraisalsLabel?.isHidden = false
            self.appraisalsLabel?.attributedText = appraisalString
        } else {
            self.appraisalsLabel?.isHidden = true
        }
        
        if let dealerStatus = self.viewModel?.lot.dealerStatus {
            switch dealerStatus {
            case .appraised, .shipping, .verified, .won:
                self.appraisalsLabel?.isHidden = false
            default:
                self.appraisalsLabel?.isHidden = true
            }
        }
        if let sellerStatus = self.viewModel?.lot.sellerStatus {
            switch sellerStatus {
            case .verified, .notVerified:
                self.expiresLabel?.isHidden = true
            default:
                self.expiresLabel?.isHidden = false
            }
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
        self.container = container
        self.contentView.addSubview(container)
        
        container.addShadow(color: Colors.white, opacity: 0.89, offset: CGSize(width: 2, height: 2), radius: 3.0)
        
        container.snp.makeConstraints {
            let edges = UIEdgeInsets(top: 8.0,
                                     left: 16.0,
                                     bottom: 8.0,
                                     right: 16.0)
            $0.edges.equalToSuperview().inset(edges)
            $0.height.equalTo(cellHeight)
        }
        
        // SEPARATOR (bottom)
        let separator = UIView()
        self.contentView.addSubview(separator)
        separator.backgroundColor = Colors.black_5opacity
        separator.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(11.0)
            $0.trailing.equalToSuperview().inset(11.0)
            $0.height.equalTo(1)
        }
        
        // DELETE BUTTON (swipeable)
        let delImage = UIImage(named: "iconDelete")
        let delButton = MGSwipeButton(title: "",
                                      icon: delImage,
                                      backgroundColor: .clear)
        delButton.frame = CGRect(x: 0, y: 0, width: 80, height: 150)
        delButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        let delTitleLabel = UILabel()
        delTitleLabel.text = "Delete Lot"
        delTitleLabel.font = Fonts.System.medium(size: 12.0)
        delTitleLabel.textColor = Colors.black
        delButton.addSubview(delTitleLabel)
        delTitleLabel.snp.makeConstraints {
            $0.height.equalTo(15.0)
            $0.width.equalTo(60.0)
            $0.centerX.equalToSuperview().offset(-5.0)
            $0.centerY.equalToSuperview().offset(30.0)
        }
        self.rightButtons = [delButton]
        self.rightSwipeSettings.transition = .drag
        
        // PREVIEW IMAGE
        let previewImageView = UIImageView()
        previewImageView.clipsToBounds = true
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.cornerRadius = 8
        previewImageView.backgroundColor = .black
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
//        topTitlesStackView.alignment = .fill
        
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
        //        bottomTitlesStackView.alignment = .fill
        
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
        
        // APPRAISALS
        let appraisalsLabel = UILabel()
        appraisalsLabel.numberOfLines = 1
        appraisalsLabel.adjustsFontSizeToFitWidth = true
        appraisalsLabel.minimumScaleFactor = 0.85
        appraisalsLabel.font = Fonts.System.medium(size: 13.0)
        appraisalsLabel.textColor = Colors.blue
        self.appraisalsLabel = appraisalsLabel
        bottomTitlesStackView.addArrangedSubview(appraisalsLabel)
        
        // REACTIVE LABEL
        let reactiveLabel = UILabel()
        reactiveLabel.text = "Reactivate"
        reactiveLabel.numberOfLines = 1
        reactiveLabel.adjustsFontSizeToFitWidth = true
        reactiveLabel.minimumScaleFactor = 0.85
        reactiveLabel.font = Fonts.System.medium(size: 13.0)
        reactiveLabel.textColor = Colors.blue
        self.reactiveLabel = reactiveLabel
        bottomTitlesStackView.addArrangedSubview(reactiveLabel)
        
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
