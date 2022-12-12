//
//  DealerLotImagesCell.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/8/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit
import Kingfisher

class DealerLotImagesTableViewCell: UITableViewCell, DealerLotTableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var backButtonContainerTopConstraint: NSLayoutConstraint!
    var collectionViewDataSource: MediaItemDataSource?
    
    var model: DealerLotTableViewCellModel?
    var actionHandler: DealerLotTableViewHandler?
    
    func configure(model: DealerLotTableViewCellModel?) {
        guard let model = model else { return }
        self.model = model
        
        self.collectionViewDataSource = MediaItemDataSource(items: model.imageUrls)
        
        onMainQueue {
            //self.configurePageControl()
            self.collectionView.delegate = self
            self.collectionView.dataSource = self.collectionViewDataSource
            self.collectionView.reloadData()
          
            self.pageControl.hidesForSinglePage = true
            self.pageControl.numberOfPages = self.collectionViewDataSource?.count ?? 1
        }
    }
  
  @IBAction func backButtonAction(_ sender: Any) {
    self.actionHandler?(.back)
  }
}

extension DealerLotImagesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
  
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let index = indexPath.row
        self.pageControl.currentPage = index
    }
}
