//
//  HTTPHandler.swift
//  mobilegewalt
//
//  Created by ruter on 27.11.25.
//

import Foundation
import Swifter
import Network

var netService: NetService?

func httpserver(port: in_port_t) {
    let server = HttpServer()
    
    let docs = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
    
    print("[ i ] serving documents directory: \(docs.path)")

    server["/:path"] = { request in
        var path = request.params.first(where: { $0.0 == "path" })?.1 ?? ""
        if path.isEmpty { path = "index.html" }
        
        let fileurl = docs.appendingPathComponent(path)
        
        guard FileManager.default.fileExists(atPath: fileurl.path) else {
            let body = "<pre>fuck, 404</pre>"
            return HttpResponse.raw(404, "Not Found", ["Content-Type": "text/html"]) { writer in
                try writer.write(Array(body.utf8))
            }
        }
        
        do {
            let data = try Data(contentsOf: fileurl)
            let contentType = mimetype(fileurl)
            return HttpResponse.raw(200, "OK", ["Content-Type": contentType]) { writer in
                try writer.write(data)
            }
        } catch {
            let body = "<pre>fuck, 500</pre>"
            return HttpResponse.raw(500, "Internal Server Error", ["Content-Type": "text/html"]) { writer in
                try writer.write(Array(body.utf8))
            }
        }
    }
    
    server.POST["/uploadPairing"] = { request in
        guard
            let contentType = request.headers["content-type"],
            contentType.contains("application/octet-stream") || contentType.contains("multipart/form-data")
        else {
            return HttpResponse.raw(400, "Bad Request", ["Content-Type": "text/html"]) { writer in
                try writer.write(Array("<pre>Invalid Content-Type</pre>".utf8))
            }
        }

        let bodyData = Data(request.body)
        let filename = "uploaded.mobiledevicepairing"
        let destURL = docs.appendingPathComponent(filename)

        do {
            try bodyData.write(to: destURL)

            DispatchQueue.main.async {
                UserDefaults.standard.set(String(data: bodyData, encoding: .utf8), forKey: "PairingFile")
            }

            return HttpResponse.raw(200, "OK", ["Content-Type": "text/html"]) { writer in
                try writer.write(Array("<pre>Pairing file imported</pre>".utf8))
            }
        } catch {
            return HttpResponse.raw(500, "Internal Server Error", ["Content-Type": "text/html"]) { writer in
                try writer.write(Array("<pre>Failed to save file: \(error.localizedDescription)</pre>".utf8))
            }
        }
    }
    
    do {
        try server.start(in_port_t(Int(port)), forceIPv4: true)
        print("[ i ] Server started on port \(port)")
    } catch {
        print("[!] Failed to start server: \(error)")
        return
    }

    netService = NetService(domain: "local.", type: "_mgserver._tcp.", name: "MobileGewalt", port: Int32(port))
    netService?.publish()
    print("[ i ] mDNS published as _mgserver._tcp.local.")

    RunLoop.main.run()
}

private func mimetype(_ url: URL) -> String {
    switch url.pathExtension.lowercased() {
    case "sqlite", "sqlitedb", "db": return "application/octet-stream"
    case "json": return "application/json"
    case "plist": return "application/xml"
    case "html": return "text/html"
    default: return "application/octet-stream"
    }
}
