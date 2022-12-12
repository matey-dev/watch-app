//
//  DispatchTimer.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/13/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

private let interval = 1
private let timerQueueName = "com.timer.queue"

final class DispatchTimer {
    
    // MARK: - Private properties
    
    private let timerQueue = DispatchQueue(label: timerQueueName, attributes: [])
    
    private lazy var dispatchTimer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: self.timerQueue)
        timer.schedule(deadline: .now() + .seconds(interval),
                       repeating: .seconds(interval))
        
        timer.setEventHandler(handler: { [weak self] in
            self?.updateHandler?()
        })
        return timer
    }()

    private var isActive = false
    
    // MARK: - Internal properties

    var updateHandler: (() -> Void)?
    
    // MARK: - Implementation
    
    init() {
        self.start()
    }
    
    private func start() {
        guard !self.isActive else {
            return
        }
        
        self.isActive = true
        self.dispatchTimer.resume()
    }
    
    func cancel() {
        guard self.isActive else {
            return
        }
        
        self.isActive = false
        self.dispatchTimer.cancel()
        self.updateHandler = nil
    }
    
    deinit {
        self.cancel()
    }
}
