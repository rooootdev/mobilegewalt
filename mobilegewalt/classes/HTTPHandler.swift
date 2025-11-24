//
//  HTTPHandler.swift
//  mobilegewalt
//
//  Created by ruter on 24.11.25.
//

import Foundation
import NIO
import NIOHTTP1

func httpserver(port: Int) throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

    let threadPool = NIOThreadPool(numberOfThreads: 2)
    threadPool.start()

    let fileIO = NonBlockingFileIO(threadPool: threadPool)

    let documentsDir = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!

    let bootstrap = ServerBootstrap(group: group)
        .serverChannelOption(ChannelOptions.backlog, value: 256)
        .serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        .childChannelInitializer { channel in
            channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).flatMap {
                channel.pipeline.addHandler(HTTPHandler(documentRoot: documentsDir, fileIO: fileIO))
            }
        }
        .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)

    let channel = try bootstrap.bind(host: "0.0.0.0", port: port).wait()

    print("[ i ] server running on http://localhost:\(port)")
    print("[ i ] serving documents directory: \(documentsDir.path)")

    try channel.closeFuture.wait()
}

final class HTTPHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    let documentRoot: URL
    let fileIO: NonBlockingFileIO
    var requestHead: HTTPRequestHead?

    init(documentRoot: URL, fileIO: NonBlockingFileIO) {
        self.documentRoot = documentRoot
        self.fileIO = fileIO
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let req = self.unwrapInboundIn(data)

        switch req {
        case .head(let head):
            requestHead = head

        case .body:
            break

        case .end:
            guard let head = requestHead else { return }
            handleRequest(head, context: context)
            requestHead = nil
        }
    }

    private func handleRequest(_ head: HTTPRequestHead, context: ChannelHandlerContext) {
        var path = head.uri
        if path.hasPrefix("/") { path.removeFirst() }
        if path.isEmpty { path = "index.html" }

        let fileURL = documentRoot.appendingPathComponent(path)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            simpleresponse(
                status: .notFound,
                body: "<h1>fuck, 400</h1>",
                context: context
            )
            return
        }

        serve(at: fileURL, context: context)
    }

    private func serve(at url: URL, context: ChannelHandlerContext) {
        do {
            let handle = try NIOFileHandle(path: url.path)
            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as! NSNumber

            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: mimetype(url))
            headers.add(name: "Content-Length", value: "\(fileSize.intValue)")

            let head = HTTPResponseHead(
                version: .http1_1,
                status: .ok,
                headers: headers
            )
            context.write(self.wrapOutboundOut(.head(head)), promise: nil)

            let region = FileRegion(fileHandle: handle, readerIndex: 0, endIndex: fileSize.intValue)
            context.write(self.wrapOutboundOut(.body(.fileRegion(region))), promise: nil)

            context.writeAndFlush(self.wrapOutboundOut(.end(nil))).whenComplete { _ in
                try? handle.close()
            }

        } catch {
            simpleresponse(
                status: .internalServerError,
                body: "<h1>fuck, 500</h1>",
                context: context
            )
        }
    }

    private func simpleresponse(status: HTTPResponseStatus, body: String, context: ChannelHandlerContext) {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "text/html")
        headers.add(name: "Content-Length", value: "\(body.utf8.count)")

        let head = HTTPResponseHead(version: .http1_1, status: status, headers: headers)
        context.write(self.wrapOutboundOut(.head(head)), promise: nil)

        var buf = context.channel.allocator.buffer(capacity: body.utf8.count)
        buf.writeString(body)

        context.write(self.wrapOutboundOut(.body(.byteBuffer(buf))), promise: nil)
        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
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
}
