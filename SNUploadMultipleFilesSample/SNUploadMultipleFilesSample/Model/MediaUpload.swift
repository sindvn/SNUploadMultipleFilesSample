//
//  MediaUpload.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit
import Photos

class MediaUpload {
    
    enum MediaMimeType : String {
        case image = "image/jpeg"
        case video = "video/mp4"
    }
    enum MediaType : String {
        case image = "image"
        case video = "video"
    }
    enum MediaName : String {
        case image = "file.jpg"
        case video = "file.mp4"
    }
    
    private let compressionImageQualityUpload : CGFloat = 0.8
    
    var asset : PHAsset
    let imageManager : PHCachingImageManager
    let resourceManager : PHAssetResourceManager
    var mimeType : String
    var keyType : String
    var fileName : String
    var urlLocalPath : URL?
    var dataUpload : Data?
    
    init(asset : PHAsset, imageManager:PHCachingImageManager,resourceManager : PHAssetResourceManager) {
        self.asset = asset
        self.imageManager = imageManager
        self.resourceManager = resourceManager
        
        if asset.mediaType == .image {
            self.mimeType = MediaMimeType.image.rawValue
            self.fileName = MediaName.image.rawValue
            self.keyType = MediaType.image.rawValue
        }
        else {
            self.mimeType = MediaMimeType.video.rawValue
            self.fileName = MediaName.video.rawValue
            self.keyType = MediaType.video.rawValue
        }
    }
    
    func prepareForUploading(complete: @escaping () -> Void) {
        if asset.mediaType == .image {
            self.compressImageToData(complete: complete)
        }
        else {
            self.writeVideoToTempDirectory(complete: complete)
        }
    }
    
    func clearDataWhenFinish() {
        if asset.mediaType == .video {
            self.deleteVideoFromTempDirectory()
        }
        self.dataUpload = nil
        self.urlLocalPath = nil
    }
    
    private func writeVideoToTempDirectory(complete: @escaping () -> Void) {
        if let resource = PHAssetResource.assetResources(for: self.asset).first {
            let localPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(resource.originalFilename)
            self.resourceManager.writeData(for: resource, toFile: localPath, options: nil, completionHandler: {[weak self] error in
                if error == nil{
                    self?.urlLocalPath = localPath
                }
                complete()
            })
        }
        else {
            complete()
        }
    }
    
    private func deleteVideoFromTempDirectory() {
        let fileManager = FileManager.default
        guard let url = urlLocalPath else {
            return
        }
        do {
            try fileManager.removeItem(at: url)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    private func compressImageToData(complete: @escaping () -> Void) {
        self.imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: PHImageRequestOptions.optionForUploading) { [weak self] image, info in
            if let img = image {
                self?.dataUpload = UIImageJPEGRepresentation(img, self?.compressionImageQualityUpload ?? 0.5)
            }
            complete()
        }
    }
    
}
