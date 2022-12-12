//
//  ReachabilityManager.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation
import SystemConfiguration

class ReachabilityManager {
    var isReachableLast: Bool = true
    var isReachable: Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        guard let routeReachability = defaultRouteReachability else { return false }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(routeReachability, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret
    }
    
    var onChange: ((Bool) -> Void)?
    
    init() {
        self.startTimer()
    }
    
    deinit {
        self.invalidateTimer()
    }
    
    private var updateTimer: DispatchTimer?
    
    func startTimer() {
        guard self.updateTimer.isNil else {
            return
        }
        
        self.updateTimer = DispatchTimer()
        self.updateTimer?.updateHandler = { [weak self] in
            guard let self = self else { return }
            let reachable = self.isReachable
            if reachable != self.isReachableLast {
                self.isReachableLast = reachable
                onMainQueue {
                    self.onChange?(reachable ?? false)
                }
            }
        }
    }
    
    func invalidateTimer() {
        self.updateTimer = nil
    }
}
