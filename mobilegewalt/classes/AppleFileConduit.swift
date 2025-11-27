//
//  AppleFileConduit.swift
//  mobilegewalt
//
//  Created by ruter on 24.11.25.
//

import Foundation

public class AppleFileConduit {
    private let udid: String

    init(udid: String) {
        self.udid = udid
    }

    func replace(local: String, remote: String) {
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

                _ = data.withUnsafeBytes { (raw: UnsafeRawBufferPointer) -> UInt32 in
                    guard let addr = raw.baseAddress?.assumingMemoryBound(to: Int8.self) else {
                        globallogger.log("[ - ] failed to get base address")
                        return 0
                    }

                    var written: UInt32 = 0
                    let writeerr = afc_file_write(client, handle, addr, UInt32(data.count), &written)

                    if writeerr != AFC_E_SUCCESS {
                        globallogger.log("[ - ] failed to write data to \(remote): \(writeerr.rawValue)")
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

    func delete(remote: String) {
        MobileDevice.requireAppleFileConduitService(udid: udid) { client in
            let err = afc_remove_path(client, remote)

            if err == AFC_E_SUCCESS {
                globallogger.log("[ i ] deleted \(remote)")
            } else {
                globallogger.log("[ - ] failed to delete \(remote): \(err.rawValue)")
            }
        }
    }
    
    func write(remote: String, data: Data) {
        MobileDevice.requireAppleFileConduitService(udid: udid) { client in
            globallogger.log("[ + ] writing to \(remote)")

            var handle: UInt64 = 0
            let err = afc_file_open(client, remote, AFC_FOPEN_WRONLY, &handle)
            guard err == AFC_E_SUCCESS else {
                globallogger.log("[ - ] failed to open \(remote) for writing: \(err.rawValue)")
                return
            }
            defer { afc_file_close(client, handle) }

            _ = data.withUnsafeBytes { raw -> UInt32 in
                guard let addr = raw.baseAddress?.assumingMemoryBound(to: Int8.self) else {
                    globallogger.log("[ - ] failed to get base address")
                    return 0
                }

                var written: UInt32 = 0
                let writeerr = afc_file_write(client, handle, addr, UInt32(data.count), &written)

                if writeerr != AFC_E_SUCCESS {
                    globallogger.log("[ - ] failed to write data to \(remote): \(writeerr.rawValue)")
                } else {
                    globallogger.log("[ i ] wrote \(written) bytes to \(remote)")
                }
                return written
            }
        }
    }

    func read(remote: String) -> Data? {
        var result: Data? = nil

        MobileDevice.requireAppleFileConduitService(udid: udid) { client in
            globallogger.log("[ + ] reading \(remote)")

            var handle: UInt64 = 0
            let err = afc_file_open(client, remote, AFC_FOPEN_RDONLY, &handle)
            guard err == AFC_E_SUCCESS else {
                globallogger.log("[ - ] failed to open \(remote) for reading: \(err.rawValue)")
                return
            }
            defer { afc_file_close(client, handle) }

            var buffer = Data()
            let chunkSize: UInt32 = 4096

            while true {
                var readCount: UInt32 = 0
                var temp = [UInt8](repeating: 0, count: Int(chunkSize))

                let readErr = afc_file_read(client, handle, &temp, chunkSize, &readCount)

                if readErr != AFC_E_SUCCESS {
                    globallogger.log("[ - ] error reading \(remote): \(readErr.rawValue)")
                    break
                }

                if readCount == 0 {
                    break
                }

                buffer.append(contentsOf: temp.prefix(Int(readCount)))
            }

            globallogger.log("[ i ] read \(buffer.count) bytes from \(remote)")
            result = buffer
        }

        return result
    }
    
    func exists(remote: String) -> Bool {
        var found = false
        
        MobileDevice.requireAppleFileConduitService(udid: udid) { client in
            var info: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
            let err = afc_get_file_info(client, remote, &info)
            if err == AFC_E_SUCCESS, let info = info {
                found = true
                afc_dictionary_free(info)
            } else if err == AFC_E_OBJECT_NOT_FOUND {
                found = false
            } else {
                globallogger.log("[ - ] error checking existence of \(remote): \(err.rawValue)")
            }
        }
        
        return found
    }
    
    func mkdir(remote: String) {
        MobileDevice.requireAppleFileConduitService(udid: udid) { client in
            globallogger.log("[ + ] creating directory \(remote)")
            
            let err = afc_make_directory(client, remote)
            if err == AFC_E_SUCCESS {
                globallogger.log("[ i ] successfully created \(remote)")
            } else if err == AFC_E_OBJECT_EXISTS {
                globallogger.log("[ i ] directory \(remote) already exists")
            } else {
                globallogger.log("[ - ] failed to create directory \(remote): \(err.rawValue)")
            }
        }
    }
}
