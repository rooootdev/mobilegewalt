import Foundation

public func ispairingreachable(
    udid: String,
    pairingfile: String
) -> Bool {
    var pairingdict: plist_t?

    guard let data = pairingfile.data(using: .utf8) else {
        globallogger.log("[ - ] pairing file not UTF-8?")
        return false
    }

    let ok = data.withUnsafeBytes { bytes -> Bool in
        plist_from_memory(
            bytes.baseAddress,
            UInt32(bytes.count),
            &pairingdict
        ) == PLIST_ERR_SUCCESS
    }

    if !ok || pairingdict == nil {
        globallogger.log("[ - ] invalid .mobiledevicepairing file")
        return false
    }

    var device: idevice_t?
    if idevice_new_with_options(&device, udid, IDEVICE_LOOKUP_NETWORK)
        != IDEVICE_E_SUCCESS || device == nil
    {
        globallogger.log("[ - ] device not reachable (\(udid))")
        return false
    }
    defer { idevice_free(device) }

    var lockdown: lockdownd_client_t?
    if lockdownd_client_new(device, &lockdown, "mobilegewalt")
        != LOCKDOWN_E_SUCCESS || lockdown == nil
    {
        globallogger.log("[ - ] lockdown open failed")
        return false
    }
    defer { lockdownd_client_free(lockdown) }

    var sessionID: UnsafeMutablePointer<CChar>? = nil
    var hostID: UnsafeMutablePointer<CChar>? = nil
    var sslEnabled: Int32 = 0

    let sessionStatus = lockdownd_start_session(
        lockdown,
        &sessionID,
        &hostID,
        &sslEnabled
    )

    if sessionStatus != LOCKDOWN_E_SUCCESS {
        globallogger.log("[ - ] pairing INVALID or device locked")
        return false
    }
    
    lockdownd_stop_session(lockdown, sessionID)

    globallogger.log("[ i ] pairing VALID and device reachable")
    return true
}
