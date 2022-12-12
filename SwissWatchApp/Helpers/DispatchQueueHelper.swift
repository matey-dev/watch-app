//
//  DispatchQueueHelper.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

func onMainQueue(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

func onGlobalUtilityQueue(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .utility).async(execute: block)
}

func onGlobalBackgroundQueue(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: block)
}

func onGlobalUserInitiatedQueue(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: block)
}
