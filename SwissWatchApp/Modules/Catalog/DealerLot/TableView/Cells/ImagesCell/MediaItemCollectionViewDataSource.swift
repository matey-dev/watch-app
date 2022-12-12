//
//  MediaItemCollectionViewDataSource.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class MediaItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    
    func configure(url: URL) {
        self.itemImageView.setImage(withUrl: url)
    }
}
