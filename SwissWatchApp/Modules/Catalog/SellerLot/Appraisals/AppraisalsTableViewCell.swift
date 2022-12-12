//
//  AppraisalsTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/29/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

protocol AppraisalsTableViewCellDelegate: AnyObject {
    func didSelect(appraisal: Appraisal)
}

class AppraisalsTableViewCell: UITableViewCell {
    private enum State { case normal, confirm }
    
    weak var tapDelegate: AppraisalsTableViewCellDelegate?
    
    var appraisal: Appraisal?
    private var state: State = .normal
    
    @IBOutlet weak var approveBackground: UIView!
    
    @IBOutlet weak var shadowView: RoundShadowView!
    
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var swipeToSellHint: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.appraisal = nil
        self.swipeToSellHint.isHidden = true
        self.state = .normal
        self.updateViewsWithModel()
    }
    
    override func layoutSubviews() {
        self.updateViewsWithModel()
        super.layoutSubviews()
    }
    
    func configure(with appraisal: Appraisal,
                   hint: Bool = false) {
        self.appraisal = appraisal
        self.swipeToSellHint.isHidden = !hint
    }
    
    @IBAction func tapButtonAction(_ sender: Any) {
        self.switchState()
    }
    
    @IBAction func approveButtonAction(_ sender: Any) {
        guard let appraisal = self.appraisal else { return }
        self.tapDelegate?.didSelect(appraisal: appraisal)
    }
    
    func setToNormalState() {
        switch self.state {
        case .confirm:
            self.switchState()
        case .normal: ()
        }
    }
}

private extension AppraisalsTableViewCell {
    func setup() {
        //self.shadowView.config(cornerRadius: 4.0, shadowColor: .black, shadowOffset: CGSize(width: 0, height: 1), shadowOpacity: 0.1, shadowRadius: 10.0)
        self.shadowView.isHidden = true
        
        self.background.layer.masksToBounds = true
        //self.background.layer.cornerRadius = 3.0
        self.background.backgroundColor = .white
        
        //self.approveBackground.applyGradient(colours: [Colors.green1, Colors.green2, Colors.green3])
        self.approveBackground.backgroundColor = Colors.green
    }
    
    func updateViewsWithModel() {
        self.label.text = self.appraisal?.price
    }
    
    func switchState() {
        switch self.state {
        case .confirm:
            self.state = .normal
        case .normal:
            self.state = .confirm
        }
        
        let animation: (() -> Void)
        let shiftWidth = self.frame.size.width * 0.35
        
        switch self.state {
        case .confirm:
            animation = { [weak self] in
                self?.labelContainer.frame.origin.x -= shiftWidth
                self?.label.frame.origin.x += shiftWidth/4
                self?.swipeToSellHint.isHidden = true
            }
        case .normal:
            animation = { [weak self] in
                self?.labelContainer.frame.origin.x += shiftWidth
                self?.label.frame.origin.x -= shiftWidth/4
            }
        }
        
        self.background.backgroundColor = Colors.whiteSnow
        self.background.layer.cornerRadius = 0.0
        self.label.textColor = Colors.black
        
        UIView.animateKeyframes(withDuration: 0.25,
                                delay: 0.0,
                                options: UIView.KeyframeAnimationOptions(rawValue: 7),
                                animations: animation,
                                completion: nil)
    }
}
