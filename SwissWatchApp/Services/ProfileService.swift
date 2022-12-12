//
//  ProfileService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/22/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
//swiftlint:disable all
typealias GetProfileCompletion = (Swift.Result<ProfileResponse, Error>) -> Void
typealias DeleteProfileCompletion = (Swift.Result<DeleteProfileResponse, Error>) -> Void

class ProfileAPIService {
    private struct ProfileParameters: Encodable {}
    private struct UpdateProfileParameters: Encodable {
        var first_name: String
        var last_name: String
        var zip: String
        var address: String
        var company_name: String
        var company_phone: String
        var city: String
        var state: String
        
        init(profile: Profile) {
            self.first_name = profile.firstName ?? ""
            self.last_name = profile.lastName ?? ""
            self.zip = profile.zip ?? ""
            self.address = profile.address ?? ""
            self.company_name = profile.companyName ?? ""
            self.company_phone = profile.companyPhone ?? ""
            self.city = profile.city ?? ""
            self.state = profile.state ?? ""
        }
    }
    
    private var userType: UserType
    
    private var getProfileApiUrlString: String {
        switch self.userType {
        case .seller:
            return API.sellerProfile
        case .dealer:
            return API.dealerProfile
        }
    }
    
    init(userType: UserType) {
        self.userType = userType
    }
    
    private let getNetworking = NetworkingService<ProfileResponse>()
    private let deleteNetworking = NetworkingService<DeleteProfileResponse>()
    
    func getProfile(completion: GetProfileCompletion?) {
        let parameters = ProfileParameters()
        let urlString = self.getProfileApiUrlString
        
        self.getNetworking.request(type: .GET,
                                   urlString: urlString,
                                   parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }
    
    func updateProfile(profile: Profile, _ completion: GetProfileCompletion?) {
        let parameters = UpdateProfileParameters(profile: profile)
        let urlString = API.updatteProfile

        self.getNetworking.request(type: .POST,
                                   urlString: urlString,
                                   parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)

        }
    }
    
    func updateProfile(profile: Profile, image: UIImage? = nil, _ completion: GetProfileCompletion?) {
        let url = API.updatteProfile
        
        let token = TokensStorage.shared.currentToken() ?? ""
        let authValue: String = "Bearer \(token)"
        let headers: HTTPHeaders = [
            "Authorization": authValue,
            "Content-type": "multipart/form-data"
        ]
        
        let parameters: [String: String] = UpdateProfileParameters(profile: profile).dictionary as! [String: String]
        
        let imagesData = image?.jpegData(compressionQuality: 1)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            if let imageData = imagesData {
                multipartFormData.append(imageData, withName: "images[0]", fileName: "0.jpeg", mimeType: "image/png")
            }
            
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { [weak self] (result) in
            debugPrint(result)
            self?.handle(result: result,
                         completion: completion)
        }
    }
    
    func deleteProfile(completion: DeleteProfileCompletion?) {
        let parameters = ProfileParameters()
        let urlString = API.deleteProfile
        
        self.deleteNetworking.request(type: .POST,
                                      urlString: urlString,
                                      parameters: parameters) { [weak self] (result) in
                                        self?.handle(result: result,
                                                     completion: completion)
                                        
        }
    }
    
    private func handle(result: Swift.Result<ProfileResponse, Error>,
                        completion: GetProfileCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
    
    private func handle(result: SessionManager.MultipartFormDataEncodingResult,
                        completion: GetProfileCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
            completion?(.failure(error))
        case .success(let request, _, _):
            request.responseData { (dataResponse) in
                let decoder = JSONDecoder()
                do {
                    let profileResponse = try decoder.decode(ProfileResponse.self, from: dataResponse.data!)
                    
                    if let json = try JSONSerialization.jsonObject(with: dataResponse.data!, options: []) as? [String: Any] {
                        // try to read out a string array
                        print("profileResponse: ", json)
                    }
//                    print(String(data: dataResponse.data!, encoding: .utf8)!)
                    completion?(.success(profileResponse))
                } catch {
                    Logger.log(logType: .error, message: error.localizedDescription)
                    completion?(.failure(error))
                }

            }
        }
    }
    
    private func handle(result: Swift.Result<DeleteProfileResponse, Error>,
                        completion: DeleteProfileCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}


extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
