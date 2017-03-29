//
//  UploadService.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit
import Photos
import Alamofire

class UploadService {
    
    static let sharedInstance = UploadService()
    private init(){
    }
    
    deinit {
    }
    
    lazy var sessionManager : SessionManager  = {
        return self.backgroundAlamofireManager() // don't init background session many times -> error: A background URLSession with identifier exist
    }()
    
    private let imageManager = PHCachingImageManager()
    private let resourceManager = PHAssetResourceManager.default()
    private var isUploadingOperation = false
    private var isStartServiceUpload = false
    private var uploadQueue = Array<UploadOperation>()
    private var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func addUploadOperation(id : Int, assets : Array<PHAsset>){
        print("add operation \(id)")
        let operation = UploadOperation.init(cardID: id, assets: assets, imageManager: self.imageManager, resourceManager : self.resourceManager)
        uploadQueue.append(operation)
        self.startUploadFirstOperation()
    }
    
    private func startUploadFirstOperation() {
        if uploadQueue.count > 0 {
            self.startService()
        }
        else {
            self.stopService()
        }
        if let operation = uploadQueue.first, isUploadingOperation == false {
            isUploadingOperation = true
            print("startUploadFirstOperation")
            operation.uploadMedia(successBlock: {[weak self] (data) in
                print("success")
                self?.uploadNextOperation()
            }, failureBlock: {[weak self] (appError) in
                print("failure")
                self?.uploadNextOperation()
            })
        }
    }
    
    private func uploadNextOperation() {
        if uploadQueue.count > 0 {
            uploadQueue.removeFirst()
            isUploadingOperation = false
            startUploadFirstOperation()
        }
    }
    
    private func startService() {
        if isStartServiceUpload == false {
            print("startService")
            isStartServiceUpload = true
//            self.sessionManager = backgroundAlamofireManager()
            self.registerBackgroundTask()
        }
    }
    
    private func stopService() {
        print("stopService")
        isStartServiceUpload = false
//        self.sessionManager = defaultAlamofireManager()
        self.endBackgroundTask()
    }
    
    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    private func endBackgroundTask() {
        if backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
    
    private func defaultAlamofireManager() -> SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        let manager = SessionManager(configuration: configuration)
        return manager
    }
    
    private func backgroundAlamofireManager() -> SessionManager {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.sample.upload")
        configuration.timeoutIntervalForRequest = 200 // seconds
        configuration.timeoutIntervalForResource = 200
        let manager = SessionManager(configuration: configuration)
        return manager
    }
}
