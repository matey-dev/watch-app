//
//  SellerBrandsService.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 9/15/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

typealias SellerBrandsCompletion = (Result<SellerBrandsResponse, Error>) -> Void
typealias DealerFilterCompletion = (Result<DealerFilterResponse, Error>) -> Void

class FilterAPIService {
    private struct Parameters: Encodable {}
    
    let brandsNetworking = NetworkingService<SellerBrandsResponse>()
    let dealerFiltersNetworking = NetworkingService<DealerFilterResponse>()
    
    func getBrands(completion: SellerBrandsCompletion?) {
        self.brandsNetworking.request(type: .GET,
                                      urlString: API.sellerBrands,
                                      parameters: Parameters()) { [weak self] (result) in
                                        self?.handle(result: result,
                                                     completion: completion)
                                        
        }
    }
    
    func getDealerFilters(_ filter: DealerFilter.Selected? = nil, completion: DealerFilterCompletion?) {
        var urlString = API.buyerFilters
        filter.map { filter in
            guard filter.hasAnySelected else { return }
            filter.brand.map { urlString.append("?brand=\($0.id)") }
            filter.model.map { urlString.append("?model=\($0)") }
            filter.year.map { urlString.append("?year=\($0)") }
        }
        self.dealerFiltersNetworking.request(type: .GET,
                                      urlString: urlString.replacingOccurrences(of: " ", with: "%20"),
                                      parameters: Parameters()) { [weak self] (result) in
                                        self?.handle(result: result,
                                                     completion: completion)
                                        
        }
    }
    
    private func handle(result: Result<SellerBrandsResponse, Error>,
                        completion: SellerBrandsCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
    
    private func handle(result: Result<DealerFilterResponse, Error>,
                        completion: DealerFilterCompletion?) {
        switch result {
        case .failure(let error):
            Logger.log(logType: .error, message: error.localizedDescription)
        default:
            break
        }
        
        completion?(result)
    }
}
