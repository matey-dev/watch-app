//
//  MediaItemDataSource.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

class MediaItemDataSource: NSObject {
    let items: [URL]
    var count: Int {
        return self.items.count
    }
    
    init(items: [URL]) {
        self.items = items
    }
    
    private func prepareMediaItemCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaItemCollectionViewCell.identifier, for: indexPath) as? MediaItemCollectionViewCell else {
                                                                return UICollectionViewCell()
        }
        
        let url = items[safe: indexPath.row]
        url.map { cell.configure(url: $0) }
        return cell
    }
}

extension MediaItemDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.prepareMediaItemCell(collectionView, indexPath: indexPath)
    }
}
