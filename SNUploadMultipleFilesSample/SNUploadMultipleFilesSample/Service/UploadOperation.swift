//
//  UploadOperation.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit
import Photos

class UploadOperation {
    
    private var imageManager : PHCachingImageManager
    private var resourceManager : PHAssetResourceManager
    private var cardID : Int
    private var assets : Array<PHAsset>
    
    init(cardID : Int,assets : Array<PHAsset>, imageManager : PHCachingImageManager, resourceManager : PHAssetResourceManager) {
        self.cardID = cardID
        self.assets = assets
        self.imageManager = imageManager
        self.resourceManager = resourceManager
    }
    
    func uploadMedia(successBlock: @escaping ((Data?) -> Void), failureBlock: @escaping ((Error?) -> Void)) {
        
        self.prepareForUploading(assets: self.assets) {[weak self] (assetsUpload) in
            
            var requestParameters : [String: Any] =  ["attachable_type" : "card",  "attachable_id" : self?.cardID ?? 0]
            
            var filesUpload = Array<(key:String, mimeType:String, fileName: String, urlPath: URL?, fileData: Data?)>()
            var index = 0
            assetsUpload.forEach({ (mediaUpload) in
                if mediaUpload.urlLocalPath != nil || mediaUpload.dataUpload != nil {
                    filesUpload.append(("medias[\(index)][file]", mediaUpload.mimeType, mediaUpload.fileName, mediaUpload.urlLocalPath, mediaUpload.dataUpload))
                    requestParameters.updateValue(mediaUpload.keyType, forKey: "medias[\(index)][type]")
                    index += 1
                }
            })
            
            let URL = try! URLRequest(url: "http://example.com", method: .post, headers: ["Authorization" : "Token"])
            UploadService.sharedInstance.sessionManager.upload(multipartFormData: { (multipartFormData) in
                
            }, usingThreshold: 1024 * 32, with: URL, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        self?.clearDataWhenFinish(assetsUpload: assetsUpload)
                        successBlock(response.data)
                        
//                        print(response?.request)  // original URL request
//                        print(response.response) // URL response
//                        print(response.data)     // server data
//                        print(response.result)   // result of response serialization
                        
                    }
                    
                case .failure(let encodingError):
                    self?.clearDataWhenFinish(assetsUpload: assetsUpload)
                    failureBlock(encodingError)
                }
            })
        }
    }
    
    private func prepareForUploading(assets : Array<PHAsset>,complete: @escaping (Array<MediaUpload>) -> Void)  {
        var mediasUpload = Array<MediaUpload>()
        let group = DispatchGroup()
        assets.forEach { (asset) in
            group.enter()
            let media = MediaUpload.init(asset: asset, imageManager: self.imageManager, resourceManager : self.resourceManager)
            mediasUpload.append(media)
            media.prepareForUploading(complete: {
                print("request \(asset.localIdentifier)")
                group.leave()
            })
        }
        group.notify(queue: .main) {
            print("Finished prepare \(self.cardID)")
            complete(mediasUpload)
        }
    }
    
    private func clearDataWhenFinish(assetsUpload: Array<MediaUpload>) {
        assetsUpload.forEach({ (mediaUpload) in
            mediaUpload.clearDataWhenFinish()
        })
    }
}
