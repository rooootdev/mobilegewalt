//
//  muxer.swift
//  mobilegewalt
//
//  Created by ruter on 25.11.25.
//

import Foundation

func startmuxer(pairingfile: String) {
    let listener = muxerheartbeatlistener()
    target_minimuxer_address()

    do {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
        
        try start(pairingfile, docs)
        
        globallogger.log("[ i ] started muxer")
        listener.startlistening()
        globallogger.log("[ i ] started muxerheartbeatlistener")
    } catch {
        globallogger.log("[ - ] error starting muxer: \(error.localizedDescription)")
    }
}

class muxerheartbeatlistener {
    private var timer: DispatchSourceTimer?
    var updatestatus: ((Bool) -> Void)?
    
    func startlistening() {
        let queue = DispatchQueue(label: "com.roooot.mobilegewalt.muxerheartbeatlistener")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            self?.checkmuxerstatus()
        }
        timer?.resume()
    }
    
    func stoplistening() {
        timer?.cancel()
        timer = nil
    }
    
    private func checkmuxerstatus() {
        let connected = test_device_connection()
        let muxerready = ready()
        
        DispatchQueue.main.async {
            self.updatestatus?(connected && muxerready)
        }
    }
}

func startmuxerheartbeatlistener(update: @escaping (_ isready: Bool, _ beat: Bool) -> Void) -> muxerheartbeatlistener {
    let listener = muxerheartbeatlistener()
    
    listener.updatestatus = { isready in
        DispatchQueue.main.async {
            if isready {
                update(isready, true)
            } else {
                update(isready, false)
            }
        }
    }
    
    listener.startlistening()
    return listener
}
