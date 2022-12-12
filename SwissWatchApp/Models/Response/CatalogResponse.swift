//
//  CatalogResponse.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/26/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

struct Notifications: Decodable {
    var catalog_message: Int
    var archive_message: Int
    var appraisal_message: Int
}

struct CatalogResponse: ApiResponse, Decodable {
    struct Meta: Decodable {
        var currentPage: Int = 0
        var pageCount: Int = 0
        var perPage: Int = 0
        var totalCount: Int = 0
        
        init() {}
        
        enum CodingKeys: String, CodingKey {
            case currentPage, pageCount, perPage, totalCount
        }
        
        init(from decoder: Decoder) throws {
            let cont = try? decoder.container(keyedBy: CodingKeys.self)
            
            self.currentPage = (try? cont?.decode(Int.self, forKey: .currentPage)) ?? 0
            self.pageCount = (try? cont?.decode(Int.self, forKey: .pageCount)) ?? 0
            self.perPage = (try? cont?.decode(Int.self, forKey: .perPage)) ?? 0
            self.totalCount = (try? cont?.decode(Int.self, forKey: .totalCount)) ?? 0
        }
    }
    
    struct Message: Decodable {
        var message: String?
    }
    
    var lots: [Catalog.Lot] = []
    var filters: [Catalog.Filter] = []
    var meta: Meta
    
    var success: Message?
    var notifications: Notifications?
    var warnings: [String: String]?
    var error: ApiError?
    
    enum CodingKeys: String, CodingKey {
        case success, errors, messages, filters, items, data, _meta
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        let dataCont = try? cont?.nestedContainer(keyedBy: CodingKeys.self, forKey: .items)
        
        self.lots = (try? dataCont?.decode([Catalog.Lot].self, forKey: .data)) ?? []
        self.filters = (try? cont?.decode([Catalog.Filter].self, forKey: .filters)) ?? []
        self.success = try? cont?.decode(Message.self, forKey: .success)
        self.warnings = try? cont?.decode([String: String].self, forKey: .errors)
        self.error = try? cont?.decode(ApiError.self, forKey: .errors)
        self.notifications = try? cont?.decode(Notifications.self, forKey: .messages)
        self.meta = (try? dataCont?.decode(Meta.self, forKey: ._meta)) ?? Meta()
        
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
}
