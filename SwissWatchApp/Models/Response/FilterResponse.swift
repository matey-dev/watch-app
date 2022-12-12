//
//  SellerBrandsResponse.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

struct SellerBrandsResponse: ApiResponse, Decodable {
    var brands: [Brand]
    
    struct Message: Decodable {
        var message: String?
    }
    var success: Message?
    var warnings: [String: String]?
    var error: ApiError?
    
    enum CodingKeys: String, CodingKey {
        case success, errors, messages, items, data
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        let itemsCont = try? cont?.nestedContainer(keyedBy: CodingKeys.self, forKey: .items)
        
        self.brands = (try? itemsCont?.decode([Brand].self, forKey: .data)) ?? []
        self.success = try? cont?.decode(Message.self, forKey: .success)
        self.warnings = try? cont?.decode([String: String].self, forKey: .errors)
        self.error = try? cont?.decode(ApiError.self, forKey: .errors)
    }
}

struct Brand: Decodable {
    var id: Int = -1
    var label: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id, label
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        
        if let idInt = (try? cont?.decode(Int.self, forKey: .id)) {
            self.id = idInt
        } else if let idString = (try? cont?.decode(String.self, forKey: .id)),
            let idInt = Int(idString) {
            self.id = idInt
        } else {
            self.id = -1
        }
        
        self.label = (try? cont?.decode(String.self, forKey: .label)) ?? ""
    }
}

struct DealerFilterResponse: Decodable {
    var brands: [Brand]
    var models: [String]
    var years: [Int]
    
    enum CodingKeys: String, CodingKey {
        case brands, models, years
    }
    
    init(from decoder: Decoder) throws {
        let cont = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.brands = (try? cont?.decode([Brand].self, forKey: .brands)) ?? []
        self.models = (try? cont?.decode([String].self, forKey: .models)) ?? []
        
        if let yearsInt = (try? cont?.decode([Int?].self, forKey: .years)) {
            self.years = yearsInt.compactMap { $0 }
        } else if let yearsStr = (try? cont?.decode([String?].self, forKey: .years)) {
            self.years = yearsStr.compactMap { $0 }.map { Int($0) }.compactMap { $0 }
        } else {
            self.years = []
        }
    }
}
