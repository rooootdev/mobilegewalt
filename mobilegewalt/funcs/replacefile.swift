//
//  replacefile.swift
//  mobilegewalt
//
//  Created by ruter on 24.11.25.
//

import Foundation

func replacefile(local: String, remote: String, udid: String) {
    MobileDevice.requireAppleFileConduitService(udid: udid) { client in
        globallogger.log("[ + ] moving \(local) to \(remote)")
        
        var handle: UInt64 = 0
        let err = afc_file_open(client, remote, AFC_FOPEN_WRONLY, &handle)
        guard err == AFC_E_SUCCESS else {
            globallogger.log("[ - ] failed to open \(remote) for writing: \(err.rawValue)")
            return
        }
        
        defer { afc_file_close(client, handle) }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: local))
            
            _ = data.withUnsafeBytes { (pdata: UnsafeRawBufferPointer) -> UInt32 in
                guard let baseaddr = pdata.baseAddress?.assumingMemoryBound(to: Int8.self) else {
                    globallogger.log("[ - ] failed to get base address")
                    return 0
                }
                
                var written: UInt32 = 0
                let error = afc_file_write(client, handle, baseaddr, UInt32(data.count), &written)
                
                if error != AFC_E_SUCCESS {
                    globallogger.log("[ - ] failed to write data to \(remote): \(error.rawValue)")
                } else {
                    globallogger.log("[ i ] replaced \(remote) (\(written) bytes)")
                }
                return written
            }
        } catch {
            globallogger.log("[ - ] failed to read local file \(local): \(error)")
        }
    }
}
