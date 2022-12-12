//
//  CatalogAPIService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/25/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias CatalogCompletion = (Result<CatalogResponse, Error>) -> Void

enum CatalogAPIType {
  case catalog(UserType)
  case archive(UserType)
  case appraisals
}

class CatalogAPIService {
    private struct CatalogParameters: Encodable {}
    
    private var type: CatalogAPIType
    
    private var apiUrlString: String {
      switch self.type {
      case .appraisals:
        return API.buyerAppraisals
      case .archive(let userType):
        switch userType {
        case .seller:
          return API.sellerArchive
        case .dealer:
          return API.buyerArchive
        }
      case .catalog(let userType):
        switch userType {
        case .seller:
          return API.sellerCatalog
        case .dealer:
          return API.buyerCatalog
        }
      }
    }
    
    init(type: CatalogAPIType) {
        self.type = type
    }
    
    let networking = NetworkingService<CatalogResponse>()

    func getList(filterId: Int? = nil,
                 perPage: Int? = 50,
                 page: Int? = nil,
                 dealerFilter: DealerFilter.Selected? = nil,
                 completion: CatalogCompletion?) {
        let parameters = CatalogParameters()
        var urlString = self.apiUrlString
        
        // seller
        filterId.map { urlString.append("?filter=\($0)") }
        
        perPage.map { urlString.append("?perPage=\($0)") }
        page.map { urlString.append("?page=\($0)") }
        
        // dealer
        dealerFilter.map { filter in
            guard filter.hasAnySelected else { return }
            filter.brand.map { urlString.append("&brand=\($0.id)") }
            filter.model.map { urlString.append("&model=\($0)") }
            filter.year.map { urlString.append("&year=\($0)") }
        }
        
        self.networking.request(type: .GET,
                                urlString: urlString.replacingOccurrences(of: " ", with: "%20"),
                                parameters: parameters) { [weak self] (result) in
                                    self?.handle(result: result,
                                                 completion: completion)
                                    
        }
    }

    private func handle(result: Result<CatalogResponse, Error>,
                        completion: CatalogCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }

        completion?(result)
    }
}
