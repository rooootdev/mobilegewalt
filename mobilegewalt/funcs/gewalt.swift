//
//  gewalt.swift
//  mobilegewalt
//
//  Created by ruter on 26.11.25.
//

import SwiftUI
import Foundation

func savegestalt(to remotepath: String, afc: AppleFileConduit) {
    let gestaltpath = "/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    let tempdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let templocal = tempdir.appendingPathComponent("com.apple.MobileGestalt.plist")
    
    do {
        try FileManager.default.createDirectory(at: tempdir, withIntermediateDirectories: true)
    } catch {
        globallogger.log("[ - ] failed to create temporary directory: \(error.localizedDescription)")
        return
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: gestaltpath))
        let plistobject = try PropertyListSerialization.propertyList(from: data, format: nil)
        let xmldata = try PropertyListSerialization.data(fromPropertyList: plistobject, format: .xml, options: 0)
        
        try xmldata.write(to: templocal)
        globallogger.log("[ i ] converted mobilegestalt plist to xml at: \(templocal.path)")
        
        afc.write(remote: remotepath, data: xmldata)
    } catch {
        globallogger.log("[ - ] failed to read/convert/write mobilegestalt plist: \(error.localizedDescription)")
    }
}

var mobileGestalt: NSMutableDictionary = [:]

func gestaltkey<T: Equatable>(
    _ keys: [String],
    type: T.Type,
    defaultValue: T,
    enableValue: T
) -> Binding<Bool> {
    guard let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
        return State(initialValue: false).projectedValue
    }

    return Binding(
        get: {
            if let value = cacheExtra[keys.first!] as? T {
                return value == enableValue
            }
            return false
        },
        set: { enabled in
            for key in keys {
                if enabled {
                    cacheExtra[key] = enableValue
                } else {
                    cacheExtra.removeObject(forKey: key)
                }
            }
        }
    )
}

func regionrestrictionkey() -> Binding<Bool> {
    guard let cacheExtra = mobileGestalt["CacheExtra"] as? NSMutableDictionary else {
        return State(initialValue: false).projectedValue
    }
    return Binding<Bool>(
        get: {
            return cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] as? String == "US" &&
            cacheExtra["zHeENZu+wbg7PUprwNwBWg"] as? String == "LL/A"
        },
        set: { enabled in
            if enabled {
                cacheExtra["h63QSdBCiT/z0WU6rdQv6Q"] = "US"
                cacheExtra["zHeENZu+wbg7PUprwNwBWg"] = "LL/A"
            } else {
                cacheExtra.removeObject(forKey: "h63QSdBCiT/z0WU6rdQv6Q")
                cacheExtra.removeObject(forKey: "zHeENZu+wbg7PUprwNwBWg")
            }
        }
    )
}
