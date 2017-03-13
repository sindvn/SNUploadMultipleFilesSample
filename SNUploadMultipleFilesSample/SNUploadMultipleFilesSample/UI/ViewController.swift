//
//  ViewController.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let maximumAssetsCount : Int = 6
    fileprivate let maximumAssetsDuration : TimeInterval = 300 // 5 minutes
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var pickAssets = Array<PHAsset>()
    
    enum SectionPhoto: Int {
        case SectionPhoto = 0, SectionAdd, SectionCount
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(UINib(nibName: "ItemPhotoCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "ItemPhotoCollectionViewCell")
    }

    @IBAction func onTapSubmit(sender: AnyObject) {
        for var i in 0..<20 {
            UploadService.sharedInstance.addUploadOperation(id: i, assets: self.pickAssets)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionPhoto.SectionCount.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == SectionPhoto.SectionAdd.rawValue {
            return 1
        }
        return pickAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == SectionPhoto.SectionAdd.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Add", for: indexPath)
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemAddMediaCardCollectionViewCell", for: indexPath) as! ItemAddMediaCardCollectionViewCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.imageManager = self.imageManager
            cell.asset = pickAssets[indexPath.row]
            return cell
        }
    }
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == SectionPhoto.SectionAdd.rawValue {
            self.view.endEditing(true)
            
            if let pickPhotosViewController = self.storyboard?.pickPhotos {
                pickPhotosViewController.delegate = self
                pickPhotosViewController.maximumAssetPicked = maximumAssetsCount
                pickPhotosViewController.maxumumAssetDuration = maximumAssetsDuration
                pickPhotosViewController.pickedAsset = self.pickAssets
                self.present(pickPhotosViewController, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController : ItemAddMediaCardCollectionViewCellDelegate {
    func cellDidTapDelete(index: Int) {
        self.pickAssets.remove(at: index)
        self.collectionView.reloadData()
    }
}

extension ViewController : ReturnPickedPhotosDelegate {
    func returnSelectedAssets(assets: [PHAsset]) {
        self.pickAssets = assets
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath.init(row: 0, section: SectionPhoto.SectionAdd.rawValue), at: .right, animated: true)
    }
}

extension UIStoryboard {
    
    var pickPhotos: PickPhotosViewController {
        return UIStoryboard(name: "PickPhotos", bundle: nil).instantiateViewController(withIdentifier: "PickPhotosViewController") as! PickPhotosViewController
    }
}
