//
//  FillLotFormItem.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 16.11.2020.
//  Copyright © 2020 m1c0. All rights reserved.
//

import Foundation

enum FillLotFormItem {
    case model(String?)
    case brand(Int?)
    case referenceNo(String?)
    case year(String?)
    case detail(String?)
    case document(Bool)
    case box(Bool)
    
    var title: String {
        switch self {
        case .model(_):
            return "Watch model"
        case .brand(_):
            return "Watch brand"
        case .referenceNo(_):
            return "Reference No"
        case .year(_):
            return "Year"
        case .detail(_):
            return "Detailed description"
        case .box(_):
            return "Box"
        case .document(_):
            return "Warranty Papers"
        }
    }
}
