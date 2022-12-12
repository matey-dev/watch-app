//
//  DealerLot.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/9/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

struct DealerLot: Decodable, Equatable {
    enum Status: Int, Decodable {
        case deleted = 0
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
            case .deleted:
                return "Deleted"
            case .new:
                return "New submission"
            case .appraised:
                return "Appraised"
            case .won:
                return "Won"
            case .lost:
                return "Lost"
            case .shipping:
                return "Shipped"
            case .blocked:
                return "Blocked"
            case .expired:
                return "Expired"
            case .verified:
                return "Authenticated"
            case .notVerified:
                return "Shipped back to seller"
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
        let urlStrings = self.images.map { API.baseUrl + $0 }
        let urls = urlStrings.map { URL(string: $0) }
        return urls.compactMap { $0 }
    }
    
    var status: Status?
    var statusString: String? {
        return self.status?.stringValue
    }
    
    var reference: String?
    var expiredAt: String?
    var year: String?
    var box: Bool
    var documents: Bool
    var flagged: Bool
    var description: String?
    var appraisal: Appraisal?
    
    var notifications: Notifications?
    
    var isValidLot: Bool {
        return self.id != -1
    }
    
    enum CodingKeys: String, CodingKey {
        case id, label, images, data, attributes, reference, status, expired, year, appraisal, box, documents, flagged, messages, description
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
        
        self.appraisal = try? dataCont?.decode(Appraisal.self, forKey: .appraisal)
        
        self.reference = try? attrCont?.decode(String.self, forKey: .reference)
        self.expiredAt = try? attrCont?.decode(String.self, forKey: .expired)
        self.year = try? attrCont?.decode(String.self, forKey: .year)
        
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
        self.flagged = (try? dataCont?.decode(Bool.self, forKey: .flagged)) ?? false
        self.description = try? attrCont?.decode(String.self, forKey: .description)
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
    
    static func == (lhs: DealerLot, rhs: DealerLot) -> Bool {
        return lhs.id == rhs.id
    }
}

extension DealerLot {
    func myAppraisalAttributedString() -> NSAttributedString? {
        guard let myAppraisal = self.appraisal?.price else { return nil }
        let attrString = NSMutableAttributedString()
        let head = "Your appraisal: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 20),
                                                       .foregroundColor: Colors.blackLight_60opacity])
        let bodyAttr = NSAttributedString(string: myAppraisal,
                                          attributes: [.font: Fonts.System.bold(size: 20),
                                                       .foregroundColor: Colors.blue])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
}

extension DealerLot {
    func brandAttributedString() -> NSAttributedString? {
        guard let brand = self.label,
            !brand.isEmpty else { return nil }
        let attrString = NSMutableAttributedString()
        let bodyAttr = NSAttributedString(string: brand,
                                          attributes: [.font: Fonts.System.semibold(size: 22),
                                                       .foregroundColor: Colors.blackLight])
        attrString.append(bodyAttr)
        return attrString
    }
    
    func referenceAttributedString() -> NSAttributedString? {
        guard let reference = self.reference,
        !reference.isEmpty else { return nil }
        let attrString = NSMutableAttributedString()
        let head = "Reference No: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_40opacity])
        let bodyAttr = NSAttributedString(string: reference,
                                          attributes: [.font: Fonts.System.medium(size: 17),
                                                       .foregroundColor: Colors.blackLight_80opacity])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
    
    func statusAttributedString() -> NSAttributedString? {
        guard let status = self.statusString,
            !status.isEmpty else { return nil }
        let attrString = NSMutableAttributedString()
        let head = "Status: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_40opacity])
        let bodyAttr = NSAttributedString(string: status,
                                          attributes: [.font: Fonts.System.medium(size: 17),
                                                       .foregroundColor: Colors.blackLight_80opacity])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
    
    func expiresAttributedString() -> NSAttributedString? {
        guard let expires = self.expiredAt,
            !expires.isEmpty else { return nil }
        let attrString = NSMutableAttributedString()
        let head = "Expires: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_40opacity])
        let bodyAttr = NSAttributedString(string: expires,
                                          attributes: [.font: Fonts.System.medium(size: 17),
                                                       .foregroundColor: Colors.blackLight_80opacity])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
    
    func yearAttributedString() -> NSAttributedString? {
        guard let year = self.year,
            !year.isEmpty else { return nil }
        let attrString = NSMutableAttributedString()
        let head = "Year: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_40opacity])
        let bodyAttr = NSAttributedString(string: year,
                                          attributes: [.font: Fonts.System.medium(size: 17),
                                                       .foregroundColor: Colors.blackLight_80opacity])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
    
    func boxAttributedString() -> NSAttributedString? {
        let boxString = self.box ? "Yes" : "No"
        let attrString = NSMutableAttributedString()
        let head = "Box: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_40opacity])
        let bodyAttr = NSAttributedString(string: boxString,
                                          attributes: [.font: Fonts.System.medium(size: 17),
                                                       .foregroundColor: Colors.blackLight_80opacity])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
    
    func papersAttributedString() -> NSAttributedString? {
        let docsString = self.documents ? "Yes" : "No"
        let attrString = NSMutableAttributedString()
        let head = "Documents: "
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_40opacity])
        let bodyAttr = NSAttributedString(string: docsString,
                                          attributes: [.font: Fonts.System.medium(size: 17),
                                                       .foregroundColor: Colors.blackLight_80opacity])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
    
    func detailsAttributedString() -> NSAttributedString? {
        let detailsString = self.description ?? ""
        let attrString = NSMutableAttributedString()
        let head = "More Details:\n"
        let headAttr = NSAttributedString(string: head,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_40opacity])
        let bodyAttr = NSAttributedString(string: detailsString,
                                          attributes: [.font: Fonts.System.regular(size: 17),
                                                       .foregroundColor: Colors.blackLight_80opacity])
        attrString.append(headAttr)
        attrString.append(bodyAttr)
        return attrString
    }
}
