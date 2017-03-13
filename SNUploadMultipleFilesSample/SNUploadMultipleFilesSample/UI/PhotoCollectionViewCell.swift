//
//  PhotoCollectionViewCell.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit
import Photos

final class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoPickedImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    
    var imageManager: PHImageManager?
    
    var asset: PHAsset? {
        willSet {
            guard let asset = newValue else {
                return
            }
            
            self.durationLabel.text = Date.durationString(duration: asset.duration)
            
            self.imageManager?.requestImage(for: asset, targetSize: CGSize(width: 160, height: 160), contentMode: .aspectFill, options: PHImageRequestOptions.optionForThumnail) { [weak self] image, info in
                self?.photoImageView.image = image
            }
        }
    }
}
