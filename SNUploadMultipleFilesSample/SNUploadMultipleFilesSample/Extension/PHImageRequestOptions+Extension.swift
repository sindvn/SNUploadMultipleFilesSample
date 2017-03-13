//
//  PHImageRequestOptions+Extension.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import Photos

extension PHImageRequestOptions {
    
    static var sharedOptions: PHImageRequestOptions {
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        
        return options
    }
    
    static var optionForThumnail: PHImageRequestOptions {
        
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .fastFormat
        
        return options
    }
    
    static var optionForUploading: PHImageRequestOptions {
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        return options
    }
}

