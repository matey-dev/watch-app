//
//  DialogView.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/14/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

typealias DialogViewAction = (DialogViewActionType) -> Void
enum DialogViewActionType {
    case one, two, dismiss
}

class DialogView: BaseViewController {
    enum ButtonStyle {
        case black, white, red
        
        var backgroundColor: UIColor {
            switch self {
            case .black:
                return Colors.blackTextColor
            case .white:
                return UIColor(hex: "#F9FAFA")
            case .red:
                return Colors.redDark
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .black, .red:
                return Colors.white
            case .white:
                return UIColor(hex: "#8F9599")
            }
        }
        
        var titleFont: UIFont {
//            switch self {
//            case .black, .red:
//                return Fonts.System.semibold(size: 17)
//            case .white:
//                return Fonts.System.medium(size: 17)
//            }
            UIFont(name: FontNames.Raleway.semibold, size: 18)!
        }
        
        var borderColor: UIColor {
//            switch self {
//            case .black, .red:
//                return UIColor.clear
//            case .white:
//                return Colors.black_30opacity
//            }
            UIColor.clear
        }
    }
    
    var subTitle: String?
    var infoText: String?
    var subMessage: String?
    var button1Title: String?
    var button2Title: String?
    var button1Style: ButtonStyle = .black
    var button2Style: ButtonStyle = .black
    var dismissButtonIsHidden: Bool = false
    
    func setup(title: String? = nil,
               subTitle: String? = nil,
               infoText: String? = nil,
               subMessage: String? = nil,
               button1Title: String? = nil,
               button2Title: String? = nil,
               button1Style: ButtonStyle = .black,
               button2Style: ButtonStyle = .black,
               dismissButtonIsHidden: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.infoText = infoText
        self.button1Title = button1Title
        self.button2Title = button2Title
        self.button1Style = button1Style
        self.button2Style = button2Style
        self.subMessage = subMessage
        self.dismissButtonIsHidden = dismissButtonIsHidden
    }
    
    private var onAction: DialogViewAction?
    func onAction(_ callback: DialogViewAction?) {
        self.onAction = callback
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var subMessageLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
}

private extension DialogView {
    @IBAction func button1Action(_ sender: Any) {
        self.onAction?(.one)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func button2Action(_ sender: Any) {
        self.onAction?(.two)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.onAction?(.dismiss)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        if let title = self.title {
            self.titleLabel.text = title
        } else {
            self.titleLabel.isHidden = true
        }
        
        if let title = self.subTitle {
            self.subTitleLabel.text = title
        } else {
            self.subTitleLabel.isHidden = true
        }
        
        if let info = self.infoText {
            self.infoLabel.text = info
        } else {
            self.infoLabel.isHidden = true
        }
        
        if let subMessage = self.subMessage {
            self.subMessageLbl.text = subMessage
        } else {
            self.subMessageLbl.isHidden = true
        }
        
        if let title = self.button1Title {
            self.button1.setTitle(title, for: .normal)
        } else {
            self.button1.isHidden = true
        }
        
        if let title = self.button2Title {
            self.button2.setTitle(title, for: .normal)
        } else {
            self.button2.isHidden = true
        }
        
        [self.button1, self.button2].forEach { $0?.layer.borderWidth = 1 }
        
        self.button1.backgroundColor = self.button1Style.backgroundColor
        self.button2.backgroundColor = self.button2Style.backgroundColor
        self.button1.titleLabel?.font = self.button1Style.titleFont
        self.button2.titleLabel?.font = self.button2Style.titleFont
        self.button1.layer.borderColor = self.button1Style.borderColor.cgColor
        self.button2.layer.borderColor = self.button2Style.borderColor.cgColor
        self.button1.setTitleColor(self.button1Style.titleColor, for: .normal)
        self.button2.setTitleColor(self.button2Style.titleColor, for: .normal)
        self.dismissButton.isHidden = self.dismissButtonIsHidden
    }
}
