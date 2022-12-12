//
//  DealerLotTableViewCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias DealerLotTableViewHandler = ((DealerLotTableViewAction) -> Void)

enum DealerLotTableViewAction {
    case back
    case flagOut
    case bid(Int, String?)
}

protocol DealerLotTableViewCell: class, Reusable {
    func configure(model: DealerLotTableViewCellModel?)
    var actionHandler: DealerLotTableViewHandler? { get set }
}

protocol DealerLotTableViewCellModel {
    var id: Int { get }
    
    var flagged: Bool { get }
    
    var imageUrls: [URL] { get }
  
    var reference: String? { get }
    var statusString: String? { get }
    var expiredAt: String? { get }
    var year: String? { get }
    var box: Bool { get }
    var documents: Bool { get }
    var description: String? { get }
    func myAppraisalAttributedString() -> NSAttributedString?
    
    func brandAttributedString() -> NSAttributedString?
    func referenceAttributedString() -> NSAttributedString?
    func statusAttributedString() -> NSAttributedString?
    func expiresAttributedString() -> NSAttributedString?
    func yearAttributedString() -> NSAttributedString?
    func boxAttributedString() -> NSAttributedString?
    func papersAttributedString() -> NSAttributedString?
    func detailsAttributedString() -> NSAttributedString?
}

extension DealerLot: DealerLotTableViewCellModel {}
