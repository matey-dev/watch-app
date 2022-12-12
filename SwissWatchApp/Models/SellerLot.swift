//
//  Lot.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/29/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum ArchiveStatus: Int {
    case undefined = 0
    case new = 1
    case appraised = 2
    case won = 3
    case lost = 4
    case shipping = 5
    case blocked = 6
    case expired = 7
    case verified = 8
    case notVerified = 9
    
    var stringValue: String {
        switch self {
        case .undefined: return "Undefined"
        case .new: return "New"
        case .appraised: return "Appraised"
        case .won: return "Won"
        case .lost: return "Lost"
        case .shipping: return "Shipping"
        case .blocked: return "Blocked"
        case .expired: return "Expired"
        case .verified: return "Verified"
        case .notVerified: return "Not verified"
        }
    }
}

struct Appraisal: Decodable {
    enum Status: Int, Decodable {
        case add = 1
        case won = 2
        case shipped = 3
    }
    
    var id: Int?
    var status: Status?
    var price: String?
}

struct SellerLot: Decodable, Equatable {
    enum Status: Int, Decodable {
        case deleted = 0
        case new = 1
        case appraised = 2
        case sold = 3
        case shippedForAuthentication = 4
        case verified = 5
        case notVerified = 6
        
        var stringValue: String {
            switch self {
            case .deleted:
                return "Deleted"
            case .new:
                return "New"
            case .appraised:
                return "Appraised"
            case .sold:
                return "Sold"
            case .shippedForAuthentication:
                return "Shipped"
            case .verified:
                return "Verified"
            case .notVerified:
                return "Not verified"
            }
        }
    }
    
    private struct Image: Decodable {
        var src: String?
    }
    var id: Int
    var label: String?
    var images: [String]
    var imageUrls: [URL] {
        let urlStrings = self.images.map { $0 }
        let urls = urlStrings.map { URL(string: $0) }
        return urls.compactMap { $0 }
    }
    
    var tempImages: [UIImage] = []
    
    var status: Status?
    
    var reference: String?
    var expiredAt: String?
    var year: String?
    var box: Bool
    var documents: Bool
    
    var appraisals: [Appraisal]
    
    var notifications: Notifications?
    var description: String?
    
    var isValidLot: Bool {
        return self.id != -1
    }
    
    var statusAttributedString: NSAttributedString? {
        guard let status = self.status?.stringValue else { return nil }
        let attrString = NSMutableAttributedString()
        var bodyColor = UIColor(hex: "#29C7A9")
        switch self.status {
        case .appraised, .new, .verified:
            break
        default:
            bodyColor = Colors.blackTextColor
        }
        let head = "Status: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: UIFont(name: FontNames.SFProText.regular, size: 14)!,
                                                       .foregroundColor: UIColor(hex: "#8F9599")])
        
        let bodyAttr = NSAttributedString(string: status,
                                          attributes: [.font: UIFont(name: FontNames.SFProText.medium, size: 14)!,
                                                       .foregroundColor: bodyColor])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
    
    enum CodingKeys: String, CodingKey {
        case id, label, images, data, attributes, reference, status, expired, year, appraisals, box, documents, messages, description
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        let dataCont = try? cont?.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        let attrCont = try? dataCont?.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        
        self.id = (try? dataCont?.decode(Int.self, forKey: .id)) ?? -1
        self.label = try? dataCont?.decode(String.self, forKey: .label)
        let images = try? dataCont?.decode([Image].self, forKey: .images)
        self.images = images?.compactMap { $0.src } ?? []
        self.status = try? dataCont?.decode(Status.self, forKey: .status)
        
        self.appraisals = (try? dataCont?.decode([Appraisal].self, forKey: .appraisals)) ?? []
        
        self.reference = try? attrCont?.decode(String.self, forKey: .reference)
        self.expiredAt = try? attrCont?.decode(String.self, forKey: .expired)
        self.year = try? attrCont?.decode(String.self, forKey: .year)
        self.description = try? attrCont?.decode(String.self, forKey: .description)
        if let boxString = try? attrCont?.decode(String.self, forKey: .box) {
            self.box = boxString == "Yes" ? true : false
        } else {
            self.box = false
        }
        if let docsString = try? attrCont?.decode(String.self, forKey: .documents) {
            self.documents = docsString == "Yes" ? true : false
        } else {
            self.documents = false
        }
        
        self.notifications = try? cont?.decode(Notifications.self, forKey: .messages)
        self.notifications.map { notifications in
            let s = DotNotificationService.shared
            let appraisal = notifications.appraisal_message == 0 ? false : true
            let archive = notifications.archive_message == 0 ? false : true
            let catalog = notifications.catalog_message == 0 ? false : true
            s.sendMessages([DotNotificationService.Message.appraisal(appraisal),
                            DotNotificationService.Message.archive(archive),
                            DotNotificationService.Message.catalog(catalog)])
            
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = notifications.archive_message + notifications.appraisal_message + notifications.catalog_message
            }
        }
    }
    
    init(tempData: FillLotFormData) {
        self.id = Int.random(in: (-1000)...(-1))
        self.appraisals = []
        self.box = tempData.box
        self.description = tempData.detail
        self.documents = tempData.document
        self.expiredAt = nil
        self.label = tempData.brands[(tempData.brand ?? 0)].label + " " + (tempData.model ?? "")
        self.notifications = nil
        self.reference = tempData.referenceNo
        self.status = .new
        self.year = tempData.year
        self.images = []
        self.tempImages = tempData.images
    }
    
    static func == (lhs: SellerLot, rhs: SellerLot) -> Bool {
        return lhs.id == rhs.id
    }
}
