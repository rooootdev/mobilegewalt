//
//  getudid.swift
//  mobilegewalt
//
//  Created by ruter on 25.11.25.
//

import SwiftUI

public func getudid(stored: inout String?, afc: inout AppleFileConduit?) {
    guard let new = MobileDevice.deviceList().first else {
        globallogger.log("[ - ] no devices detected to refresh UDID")
        return
    }

    stored = new
    afc = AppleFileConduit(udid: new)

    globallogger.log("[ i ] UDID refreshed: \(new)")
}
