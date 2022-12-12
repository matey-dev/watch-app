//
//  FillLotTest.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Alamofire

struct FillLotAPITest {
    let addLotService = AddLotAPIService()
    
    func callAddLotApiWithModels() {
        let brand = 1
        let model = "model"
        let year = "2000"
        let reference = "12345"
        let box = true
        let documents = false
        let images: [UIImage] = [UIImage(named: "iWatch4_black_transparent")!, UIImage(named: "iWatch4_silver")!, UIImage(named: "iWatch4_silver")!, UIImage(named: "iWatch4_silver")!, UIImage(named: "iWatch4_silver")!]
        
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
                                            "reference": reference]
        
        var imagesData = Data()
        var imageData = images.compactMap { $0.jpegData(compressionQuality: 0.7) }
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
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("responseJSON\n\(response)")
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    /*func callAddLotApiWithModels() {
     let brand = 1
     let model = "model"
     let year = "2000"
     let reference = "12345"
     let box = true
     let documents = false
     let images: [UIImage] = [UIImage(named: "iWatch4_black_transparent")!, UIImage(named: "iWatch4_silver")!, UIImage(named: "iWatch4_silver")!, UIImage(named: "iWatch4_silver")!, UIImage(named: "iWatch4_silver")!]
     
     self.addLotService.sendLot(
     brand: brand,
     year: year,
     box: box,
     documents: documents,
     model: model,
     reference: reference,
     images: images) { response in
     
     switch response {
     case .success(let success):
     if let error = success.error {
     print("\(error.message) \(error.description)")
     } else if let warnings = success.warnings {
     print("\(warnings)")
     } else {
     print("success")
     }
     case .failure(let failure):
     print("ERROR \(failure.localizedDescription)")
     }
     }
     }*/
}
