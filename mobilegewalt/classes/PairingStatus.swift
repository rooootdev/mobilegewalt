//
//  PairingStatus.swift
//  mobilegewalt
//
//  Created by ruter on 27.11.25.
//

import Foundation
import SwiftUI
import Combine

let pairingstatus = Logger()

class PairingStatus: ObservableObject {
    @Published var statuses: [String: Bool] = [:]
    @Published var pairingfile: String?

    private var timer: Timer?

    func startchecking(udids: [String]) {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.updatestatuses(for: udids)
        }

        updatestatuses(for: udids)
    }

    private func updatestatuses(for udids: [String]) {
        guard let pairingfile = pairingfile else { return }

        DispatchQueue.global(qos: .background).async {
            var newstatuses: [String: Bool] = [:]

            for udid in udids {
                let valid = ispairingreachable(udid: udid, pairingfile: pairingfile)
                newstatuses[udid] = valid
            }

            DispatchQueue.main.async {
                withAnimation {
                    self.statuses = newstatuses
                }
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
