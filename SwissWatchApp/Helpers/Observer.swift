//
//  Observer.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

protocol Observer: AnyObject {
    func onChanged<Item>(_ item: Item)
}

class Observable {
    private var observations: [AnyHashable: Observation] = [:]
    
    private struct Observation {
        weak var observer: Observer?
    }
    
    func add(observer: Observer) {
        let id = ObjectIdentifier(observer)
        self.observations[id] = Observation(observer: observer)
    }
    
    func remove(observer: Observer) {
        let id = ObjectIdentifier(observer)
        self.observations[id] = nil
    }
    
    func notify<Item>(_ item: Item) {
        self.observations.forEach { (id, observation) in
            guard let observer = observation.observer else {
                self.observations[id] = nil
                return
            }
            observer.onChanged(item)
        }
    }
    
}
