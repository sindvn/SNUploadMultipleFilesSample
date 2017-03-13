//
//  PickPhotosViewController.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit
import Photos

protocol ReturnPickedPhotosDelegate: class {
    func returnSelectedAssets(assets: [PHAsset])
}

final class PickPhotosViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchResult: PHFetchResult<PHAsset>? {
        didSet {
            collectionView?.reloadData()
            guard let fetchResult = fetchResult, let collectionView = collectionView else { return }
            
            collectionView.scrollToItem(at: IndexPath(item: fetchResult.count - 1, section: 0), at: .centeredVertically, animated: false)
        }
    }
    var imagesDidFetch: Bool = false
    let imageManager = PHCachingImageManager()
    
    weak var delegate: ReturnPickedPhotosDelegate?

    var pickedAsset = [PHAsset]()
    var maximumAssetPicked = Int.max
    var maxumumAssetDuration : TimeInterval = TimeInterval.greatestFiniteMagnitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        automaticallyAdjustsScrollViewInsets = false
        collectionView.dataSource   = self
        collectionView.delegate     = self
        self.collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            let width: CGFloat = 80
            let height = width
            layout.itemSize = CGSize(width: width, height: height)
            
            let gap: CGFloat = 1
            layout.minimumInteritemSpacing = gap
            layout.minimumLineSpacing = gap
            layout.sectionInset = UIEdgeInsets(top: gap , left: gap, bottom: gap, right: gap)
        }
        
        if !imagesDidFetch {
            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            fetchResult = PHAsset.fetchAssets(with: options)
        }
        
        PHPhotoLibrary.shared().register(self)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: Actions
    @IBAction func done(_ sender: UIButton) {
        
        if pickedAsset.count > 0 {
            delegate?.returnSelectedAssets(assets: pickedAsset)
        }
        self.dismiss(animated: true, completion: nil)
    
    }

}

// MARK: UICollectionViewDataSource
extension PickPhotosViewController : UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        return cell
    }
    
}

// MARK: UICollectionViewDelegate
extension PickPhotosViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? PhotoCollectionViewCell {
            cell.imageManager = imageManager
            
            if let asset = fetchResult?[indexPath.item] {
                cell.asset = asset
                cell.photoPickedImageView.isHidden = !pickedAsset.contains(asset)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let asset = fetchResult?[indexPath.item] {
            if pickedAsset.contains(asset) {
                if let index = pickedAsset.index(of: asset) {
                    pickedAsset.remove(at: index)
                }
            } else {
                if (pickedAsset.count >= maximumAssetPicked) {
                    let alertController = UIAlertController(title: "Alert", message: "Maximum item selected < \(maximumAssetPicked)", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                else if asset.duration >= maxumumAssetDuration {
                    let alertController = UIAlertController(title: "Alert", message: "Maximum item duration < \(Date.durationString(duration: maxumumAssetDuration))", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                pickedAsset.append(asset)
            }
            
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.photoPickedImageView.isHidden = !pickedAsset.contains(asset)
        }
    }
    
}

// MARK: PHPhotoLibraryChangeObserver
extension PickPhotosViewController : PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let fetchResult = self.fetchResult, let changeDetails = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        
        self.fetchResult = changeDetails.fetchResultAfterChanges
        
        DispatchQueue.main.async {
            
            guard let
                indexPaths = self.collectionView?.indexPathsForVisibleItems,
                let changedIndexes = changeDetails.changedIndexes else {
                    return
            }
            
            for indexPath in indexPaths {
                if changedIndexes.contains(indexPath.item) {
                    if let cell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                        cell.asset = changeDetails.fetchResultAfterChanges[indexPath.item]
                    }
                }
            }
        }
    }
    
}

extension PickPhotosViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            return true
        }
        return false
    }
    
}
