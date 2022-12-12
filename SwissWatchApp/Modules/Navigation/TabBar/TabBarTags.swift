//
//  TabBarTags.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/28/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

enum TabBarTags: Int {
    case newSubmissions
    case appraisals
    case profile
    case yourCatalogue
    case addLot
    case archive
    
    
    var inactiveIconName: String {
        switch self {
        case .newSubmissions:
            return ImageNames.InactiveBarIconNames.newSubmissions
        case .appraisals:
            return ImageNames.InactiveBarIconNames.appraisals
        case .yourCatalogue:
            return ImageNames.InactiveBarIconNames.yourCatalogue
        case .addLot:
            return ImageNames.InactiveBarIconNames.lotAddind
        case .profile:
            return ImageNames.InactiveBarIconNames.profile
        case .archive:
            return ImageNames.InactiveBarIconNames.archive
        }
    }
    
    var notificatedIconName: String {
        switch self {
        case .newSubmissions:
            return ImageNames.NotificatedIconNames.newSubmissions
        case .appraisals:
            return ImageNames.NotificatedIconNames.appraisals
        case .yourCatalogue:
            return ImageNames.NotificatedIconNames.yourCatalogue
        case .addLot:
            return ImageNames.NotificatedIconNames.lotAddind
        case .profile:
            return ImageNames.NotificatedIconNames.profile
        case .archive:
            return ImageNames.NotificatedIconNames.profile
        }
    }
    
    var activeIconName: String {
        switch self {
        case .newSubmissions:
            return ImageNames.ActiveBarIconNames.newSubmissions
        case .appraisals:
            return ImageNames.ActiveBarIconNames.appraisals
        case .yourCatalogue:
            return ImageNames.ActiveBarIconNames.yourCatalogue
        case .addLot:
            return ImageNames.ActiveBarIconNames.lotAddind
        case .profile:
            return ImageNames.ActiveBarIconNames.profile
        case .archive:
            return ImageNames.ActiveBarIconNames.archive
        }
    }
    
    var title: String? {
        switch self {
        case .yourCatalogue:
            return "Home"
        case .addLot:
            return "Add watch"
        case .archive:
            return "Archive"
        default:
            return nil
        }
    }
}
