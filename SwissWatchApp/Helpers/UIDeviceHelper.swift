//
//  UIDeviceExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

struct UIDeviceHelper {
    static var isSmallScreenHeight: Bool {
        return UIScreen.main.bounds.height < 569
    }
}
