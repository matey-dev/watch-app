//
//  Catalog.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/14/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import UIKit
//swiftlint:disable all
struct Catalog: Decodable {
    struct Filter: Decodable {
        var id: Int
        var label: String
    }
    
    struct Lot: Decodable, Equatable {
        var id: Int
        var label: String?
        var reference: String?
        var rawStatus: Int?
        var sellerStatus: SellerLot.Status?
        var dealerStatus: DealerLot.Status?
        var archiveStatus: ArchiveStatus?
        var expiredAt: String?
        var hint: String?
        var appraisal: String?
        var preview: String?
        var description: String?
        var previewImage: UIImage?
        
        enum CodingKeys: String, CodingKey {
            case id, label, reference, status, expired_at, hint, preview, appraisal, description
        }
        
        init(from decoder: Decoder) throws {
            let cont = try? decoder.container(keyedBy: CodingKeys.self)
            
            self.id = (try? cont?.decode(Int.self, forKey: .id)) ?? -1
            self.label = try? cont?.decode(String.self, forKey: .label)
            self.reference = try? cont?.decode(String.self, forKey: .reference)
            self.rawStatus = try? cont?.decode(Int.self, forKey: .status)
            self.archiveStatus = ArchiveStatus(rawValue: self.rawStatus ?? -1)
            self.expiredAt = try? cont?.decode(String.self, forKey: .expired_at)
            self.hint = try? cont?.decode(String.self, forKey: .hint)
            self.appraisal = try? cont?.decode(String.self, forKey: .appraisal)
            self.preview = try? cont?.decode(String.self, forKey: .preview)
            self.description = try? cont?.decode(String.self, forKey: .description)
        }
        
        init(sellerLot: SellerLot) {
            self.id = sellerLot.id
            self.label = (sellerLot.label ?? "")
            self.reference = sellerLot.reference
            self.rawStatus = sellerLot.status?.rawValue
            self.archiveStatus = ArchiveStatus(rawValue: self.rawStatus ?? -1)
            self.expiredAt = sellerLot.expiredAt
            self.hint = nil
            self.appraisal = nil
            self.preview = nil
            self.previewImage = sellerLot.tempImages.first
            self.description = sellerLot.description
            self.sellerStatus = SellerLot.Status(rawValue: (self.rawStatus ?? -1))
            self.dealerStatus = DealerLot.Status(rawValue: (self.rawStatus ?? -1))
        }
        
        init(dealerLot: DealerLot) {
            self.id = dealerLot.id
            self.label = (dealerLot.label ?? "")
            self.reference = dealerLot.reference
            self.rawStatus = dealerLot.status?.rawValue
            self.archiveStatus = ArchiveStatus(rawValue: self.rawStatus ?? -1)
            self.expiredAt = dealerLot.expiredAt
            self.hint = nil
            self.appraisal = nil
            self.preview = nil
            self.description = dealerLot.description
            self.sellerStatus = SellerLot.Status(rawValue: (self.rawStatus ?? -1))
            self.dealerStatus = DealerLot.Status(rawValue: (self.rawStatus ?? -1))
        }
        
        static func == (lhs: Lot, rhs: Lot) -> Bool {
            return lhs.id == rhs.id
        }
        
        var previewURL: URL? {
            guard let previewString = self.preview else { return nil }
            return URL(string: API.baseUrl + previewString)
        }
        
        var statusAttributedString: NSAttributedString? {
            guard let status = self.archiveStatus?.stringValue else { return nil }
            let attrString = NSMutableAttributedString()
            let head = "Status: "
            let headAttr = NSAttributedString(string: head,
                                              attributes: [.font: UIFont(name: FontNames.SFProText.regular, size: 14)!,
                                                           .foregroundColor: UIColor(hex: "#8F9599")])
            var bodyColor = UIColor(hex: "#29C7A9")
            switch self.archiveStatus {
            case .appraised, .won, .shipping, .new, .verified:
                break
            case .lost, .blocked, .expired:
                bodyColor = Colors.redDark
            default:
                bodyColor = Colors.blackTextColor
            }
            let bodyAttr = NSAttributedString(string: status,
                                              attributes: [.font: UIFont(name: FontNames.SFProText.medium, size: 14)!,
                                                           .foregroundColor: bodyColor])
            attrString.append(headAttr)
            attrString.append(bodyAttr)
            return attrString
        }
    }
    
    struct LotViewModel {
        var lot: Lot
        let userType: UserType
        let tableType: CatalogTableViewType?
        
        init(lot: Lot,
             userType: UserType,
             tableType: CatalogTableViewType? = nil) {
            self.lot = lot
            self.userType = userType
            self.tableType = tableType
            switch userType {
            case .seller:
                self.lot.sellerStatus = SellerLot.Status(rawValue: (self.lot.rawStatus ?? -1))
            case .dealer:
                self.lot.dealerStatus = DealerLot.Status(rawValue: (self.lot.rawStatus ?? -1))
            }
        }
        
        var statusString: String? {
            if (self.tableType ?? .general) == .archive {
                return self.archiveStatusString
            } else {
                switch self.userType {
                case .seller:
                    return self.lot.sellerStatus?.stringValue ?? self.archiveStatusString
                case .dealer:
                    return self.lot.dealerStatus?.stringValue ?? self.archiveStatusString
                }
            }
//            self.archiveStatusString
        }
        
        var archiveStatusString: String? {
            guard let archiveStatus = self.lot.archiveStatus else { return nil }
//            switch archiveStatus {
//            case .verified, .notVerified:
//                var stringVal: String?
//                switch self.userType {
//                case .seller:
//                    stringVal = self.lot.sellerStatus?.stringValue
//                case .dealer:
//                    stringVal = self.lot.dealerStatus?.stringValue
//                }
//                return stringVal ?? archiveStatus.stringValue
//            default:
//                return archiveStatus.stringValue
//            }
            return archiveStatus.stringValue
        }
        
        var isNewStatus: Bool {
            if (self.lot.rawStatus ?? -1) == 1 {
                return true
            } else {
                return false
            }
        }
        
        var canReactivate: Bool {
            guard self.tableType == .archive,
            self.userType == .seller,
            (self.lot.archiveStatus ?? .undefined) == .expired else { return false }
            return true
        }
        
        var previewURL: URL? {
            guard let previewString = self.lot.preview else { return nil }
            return URL(string: API.baseUrl + previewString)
        }
        
        var previewImage: UIImage? {
            self.lot.previewImage
        }
        
        var nameString: String? {
            return self.lot.label
        }
        
        var referenceString: String? {
            return self.lot.reference
        }
        
        var referenceAttributedString: NSAttributedString? {
            guard let reference = self.lot.reference,
            !reference.isEmpty else { return nil }
            let attrString = NSMutableAttributedString()
            let head = "Reference No: "
            let headAttr = NSAttributedString(string: head,
                                              attributes: [.font: Fonts.Avenir.medium(size: 14.0),
                                                           .foregroundColor: Colors.black_45opacity])
            let bodyAttr = NSAttributedString(string: reference,
                                              attributes: [.font: Fonts.Avenir.medium(size: 14.0),
                                                           .foregroundColor: Colors.black])
            attrString.append(headAttr)
            attrString.append(bodyAttr)
            return attrString
        }
        
        var hintString: String? {
            return self.lot.hint
        }
        
        var expiresAttributedString: NSAttributedString? {
            guard let expiredAt = self.lot.expiredAt else { return nil }
            let attrString = NSMutableAttributedString()
            let head = "Expires: "
            var bodyColor = Colors.black
            switch (self.lot.sellerStatus ?? .deleted) {
            case .verified:
                bodyColor = Colors.green
            default: ()
            }
            let headAttr = NSAttributedString(string: head,
                                              attributes: [.font: Fonts.Avenir.medium(size: 13.0),
                                                           .foregroundColor: Colors.grayDark])
            let bodyAttr = NSAttributedString(string: expiredAt,
                                              attributes: [.font: Fonts.Avenir.medium(size: 13.0),
                                                           .foregroundColor: bodyColor])
            attrString.append(headAttr)
            attrString.append(bodyAttr)
            return attrString
        }
        
        var statusAttributedString: NSAttributedString? {
            guard let status = self.statusString else { return nil }
            //print("statusString: \(status), dealerStatus: \(self.lot.dealerStatus), sellerStatus: \(self.lot.sellerStatus), archiveStatus: \(self.lot.archiveStatus)")
            let attrString = NSMutableAttributedString()
            let head = "Status: "
            let headAttr = NSAttributedString(string: head,
                                              attributes: [.font: UIFont(name: FontNames.SFProText.regular, size: 14)!,
                                                           .foregroundColor: UIColor(hex: "#8F9599")])
            var bodyColor = UIColor(hex: "#29C7A9")
//            if let dealerStatus = self.lot.dealerStatus {
//                switch dealerStatus {
//                case .won, .verified:
//                    bodyColor = Colors.green
//                case .lost, .notVerified, .blocked:
//                    bodyColor = Colors.redDark
//                default: ()
//                }
//            } else if let sellerStatus = self.lot.sellerStatus {
//                switch sellerStatus {
//                case .sold, .shippedForAuthentication, .verified:
//                    bodyColor = Colors.green
//                case .notVerified:
//                    bodyColor = Colors.redDark
//                default: ()
//                }
//            } else if let archiveStatus = self.lot.archiveStatus {
//                switch archiveStatus {
//                case .won, .verified:
//                    bodyColor = Colors.green
//                case .notVerified, .lost, .blocked:
//                    bodyColor = Colors.redDark
//                default: ()
//                }
//            }
            switch self.lot.archiveStatus {
            case .appraised, .won, .shipping, .new, .verified:
                break
            case .lost, .blocked, .expired:
                bodyColor = Colors.redDark
            default:
                bodyColor = Colors.blackTextColor
            }
            let bodyAttr = NSAttributedString(string: status,
                                              attributes: [.font: UIFont(name: FontNames.SFProText.medium, size: 14)!,
                                                           .foregroundColor: bodyColor])
            attrString.append(headAttr)
            attrString.append(bodyAttr)
            return attrString
        }
        
        var appraisalAttributedString: NSAttributedString? {
            guard let appraisal = self.lot.appraisal else { return nil }
            let attrString = NSMutableAttributedString()
            let head = "Appraisal: "
            let headAttr = NSAttributedString(string: head,
                                              attributes: [.font: Fonts.Avenir.medium(size: 13.0),
                                                           .foregroundColor: Colors.grayDark])
            let bodyAttr = NSAttributedString(string: appraisal,
                                              attributes: [.font: Fonts.Avenir.medium(size: 13.0),
                                                           .foregroundColor: Colors.black])
            attrString.append(headAttr)
            attrString.append(bodyAttr)
            return attrString
        }
    }
}
