//
//  AddLotService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Alamofire
//swiftlint:disable all
class AddLotAPIService {
    
    private struct Parameters: Encodable {
        var lot_id: Int
    }
    
    let networking = NetworkingService<GeneralResponse>()
    
    func sendLot(brand: Int,
                 year: String,
                 box: Bool,
                 documents: Bool,
                 model: String,
                 reference: String,
                 description: String,
                 images: [UIImage],
                 completion: ((Int?) -> Void)?) {
        
        let url = API.addLot
        
        let token = TokensStorage.shared.currentToken() ?? ""
        let authValue: String = "Bearer \(token)"
        let headers: HTTPHeaders = [
            "Authorization": authValue,
            "Content-type": "multipart/form-data"
        ]
        
        let parameters: [String: String] = ["brand": String(brand),
                                            "year": year,
                                            "box": box ? "1" : "0",
                                            "documents": documents ? "1" : "0",
                                            "model": model,
                                            "reference": reference,
                                            "description": description]
        
        var imagesData = Data()
        //        let imageData = images.compactMap { $0
        //            .resizeWithScaleAspectFitMode(to: 1000.0, resizeFramework: .uikit)?
        //            .jpegData(compressionQuality: 0.2) }
        let imageData = images.compactMap({$0.jpegData(compressionQuality: 0.8)})
        imageData.forEach {
            imagesData.append($0)
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            multipartFormData.append(imageData[0], withName: "images[0]", fileName: "0.jpeg", mimeType: "image/png")
            multipartFormData.append(imageData[1], withName: "images[1]", fileName: "1.jpeg", mimeType: "image/png")
            multipartFormData.append(imageData[2], withName: "images[2]", fileName: "2.jpeg", mimeType: "image/png")
            multipartFormData.append(imageData[3], withName: "images[3]", fileName: "3.jpeg", mimeType: "image/png")
            multipartFormData.append(imageData[4], withName: "images[4]", fileName: "4.jpeg", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            debugPrint(result)
            switch result {
            case .success(let upload, _, _):
                //                completion?(true)
                upload.responseJSON { response in
                    print("responseJSON\n\(response)")
                    if let status = response.response?.statusCode {
                        switch(status){
                        case 200:
                            if let result = response.result.value, let JSON = result as? [String: Int] {
                                let lot_id = JSON["lot_id"]
                                completion?(lot_id)
                                print(JSON)
                                
                            } else {
                                completion?(nil)
                            }
                        default:
                            completion?(nil)
                        }
                    }
                    //to get JSON return value
                    
                }
                
            case .failure(let error):
                completion?(nil)
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNewLotApn(lotId: Int) {
        let parameters = Parameters(lot_id: lotId)
        self.networking.request(type: .POST,
                                urlString: API.addApn,
                                parameters: parameters) { [weak self] (result) in
            print(result)
        }
    }
}
