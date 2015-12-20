//
//  ThumbnailCollectionViewCell.swift
//  PlayUICollectionView
//
//  Created by Wenzheng Li on 12/19/15.
//  Copyright © 2015 Wenzheng Li. All rights reserved.
//

import UIKit

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var thumbnail: UIImage? {
        get {
            return thumbnailImageView.image
        }
        set {
            thumbnailImageView.image = newValue
            thumbnailImageView.contentMode = .ScaleAspectFit
        }
    }
}
