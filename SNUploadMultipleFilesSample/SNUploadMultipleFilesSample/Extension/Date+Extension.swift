//
//  Date+Extension.swift
//  SNUploadMultipleFilesSample
//
//  Created by admin on 3/13/17.
//  Copyright © 2017 Si Nguyen. All rights reserved.
//

import UIKit

extension Date {
    static func durationString(duration:TimeInterval) -> String {
        if duration > 0 {
            let interval = Int(round(duration))
            return String(format: "%02d:%02d", interval/60, interval%60)
        }
        return ""
    }
}
