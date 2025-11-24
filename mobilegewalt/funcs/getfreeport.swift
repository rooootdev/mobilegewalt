//
//  getfreeport.swift
//  mobilegewalt
//
//  Created by ruter on 24.11.25.
//

import Foundation

let freeport = Int(getfreeport())

func getfreeport() -> UInt16 {
    let sock = socket(AF_INET, SOCK_STREAM, 0)
    if sock == -1 {
        return 0
    }

    var addr = sockaddr_in()
    addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = in_port_t(0).bigEndian
    addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))

    let bindres = withUnsafePointer(to: &addr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            bind(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }

    if bindres == -1 {
        close(sock)
        return 0
    }

    var len = socklen_t(MemoryLayout<sockaddr_in>.size)
    let portres = withUnsafeMutablePointer(to: &addr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            getsockname(sock, $0, &len)
        }
    }

    if portres == -1 {
        close(sock)
        return 0
    }
    
    close(sock)

    return UInt16(bigEndian: addr.sin_port)
}
