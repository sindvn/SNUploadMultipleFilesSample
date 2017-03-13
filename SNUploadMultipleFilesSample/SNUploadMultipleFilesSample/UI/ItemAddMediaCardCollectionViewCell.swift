//
//  ItemAddMediaCardCollectionViewCell.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit
import Photos

@objc protocol ItemAddMediaCardCollectionViewCellDelegate : class {
    func cellDidTapDelete(index:Int)
}

class ItemAddMediaCardCollectionViewCell: UICollectionViewCell {
    
    var index = 0
    var imageManager: PHImageManager?
    
    weak var delegate : ItemAddMediaCardCollectionViewCellDelegate? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    
    var asset: PHAsset? {
        willSet {
            guard let asset = newValue else {
                return
            }
            
            self.durationLabel.text = Date.durationString(duration: asset.duration)
            
            self.imageManager?.requestImage(for: asset, targetSize: CGSize(width: 160, height: 160), contentMode: .aspectFill, options: PHImageRequestOptions.optionForThumnail) { [weak self] image, info in
                self?.imageView.image = image
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func onTapDelete(sender: AnyObject) {
        delegate?.cellDidTapDelete(index: index)
    }
}
