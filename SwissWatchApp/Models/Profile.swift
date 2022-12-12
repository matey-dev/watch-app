//
//  Profile.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

struct Profile {
    var firstName: String?
    var lastName: String?
    var email: String?
    var city: String?
    var state: String?
    var address: String?
    var zip: String?
    var companyName: String?
    var companyPhone: String?
    var avatar: String?
//    private struct Image: Decodable {
//        var src: String?
//    }
//
//    var avatar: [String]
//
//    enum CodingKeys: String, CodingKey {
//        case firstName, lastName, email, city, state, address, zip, companyName, companyPhone, avatar, data
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        firstName = try values.decode(String.self, forKey: .firstName)
//        lastName = try values.decode(String.self, forKey: .lastName)
//        email = try values.decode(String.self, forKey: .email)
//        city = try values.decode(String.self, forKey: .city)
//        state = try values.decode(String.self, forKey: .state)
//        address = try values.decode(String.self, forKey: .address)
//        zip = try values.decode(String.self, forKey: .zip)
//        companyName = try values.decode(String.self, forKey: .companyName)
//        companyPhone = try values.decode(String.self, forKey: .companyPhone)
//        let dataCont = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
//        let images = try? dataCont?.decode([Image].self, forKey: .avatar)
//        self.avatar = images?.compactMap { $0.src } ?? []
//    }
//
//    init(firstName: String?, lastName: String?, email: String?, city: String?, state: String?, address: String?, zip: String?, companyName: String?, companyPhone: String?, avatar: [String] = []) {
//        self.firstName = firstName
//        self.lastName = lastName
//        self.email = email
//        self.city = city
//        self.state = state
//        self.address = address
//        self.zip = zip
//        self.companyPhone = companyPhone
//        self.companyName = companyName
//        self.avatar = avatar
//    }
}
