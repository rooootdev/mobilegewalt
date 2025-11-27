//
//  ContentView.swift
//  mobilegewalt
//
//  Created by ruter on 18.11.25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("UDID") var storedudid: String?
    @AppStorage("PairingFile") var pairingfile: String?
    @AppStorage("GestaltFile") var mobilegestalt: String?
    
    @StateObject var pairingstatus = PairingStatus()
    @StateObject var logger = globallogger
    
    @State var showparingimporter = false
    @State var showgestaltimporter = false
    @State var modifiedgestalt = false
    @State var allownomodify = false
    @State var beattrigger = false
    @State var heartscale: CGFloat = 1.0
    @State var copyindex: Int? = nil
    @State var muxerready = false
    @State var listener: muxerheartbeatlistener?
    @State var confirm = false
    @State var muxeron = false
    @State var afc: AppleFileConduit?
    
    init() {
        let udid = UserDefaults.standard.string(forKey: "UDID")
        ?? MobileDevice.deviceList().first
        
        if let udid {
            UserDefaults.standard.set(udid, forKey: "UDID")
        }
        
        if let udid {
            _afc = State(initialValue: AppleFileConduit(udid: udid))
        } else {
            _afc = State(initialValue: nil)
        }
    }
    
    var body: some View {
        TabView {
            MGTab
                .tabItem {
                    Label("MobileGewalt", systemImage: "wrench.and.screwdriver")
                }
            
            ApplyTab
                .tabItem {
                    Label("Apply", systemImage: "checkmark.circle")
                }
            
            SettingsTab
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            listener = startmuxerheartbeatlistener { isReady, beat in
                muxerready = isReady
                
                guard beat else { return }
                
                if #available(iOS 18.0, *) {
                    beattrigger.toggle()
                } else {
                    withAnimation(Animation.easeInOut(duration: 0.6)) {
                        heartscale = 1.3
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        heartscale = 1.0
                    }
                }
            }
            
            /*
            pairingstatus.pairingfile = pairingfile
            if let udid = storedudid {
                pairingstatus.startchecking(udids: [udid])
            }
            */
        }
    }
    
    var MGTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    /*
                    Toggle("Action Button (iOS 17+)", isOn: gestaltkey(["cT44WE1EohiwRzhsZ8xEsw"]))
                    Toggle("Allow installing iPadOS apps", isOn: gestaltkey(["9MZ5AdH43csAUajl/dU+IQ"], type: [Int].self, defaultValue: [1], enableValue: [1, 2]))
                    Toggle("Always on Display (18.0+)", isOn: gestaltkey(["j8/Omm6s1lsmTDFsXjsBfA", "2OOJf1VhaM7NxfRok3HbWQ"]))
                    Toggle("Apple Pencil", isOn: gestaltkey(["yhHcB0iH0d1XzPO/CFd3ow"]))
                    Toggle("Boot chime", isOn: gestaltkey(["QHxt+hGLaBPbQJbXiUJX3w"]))
                    Toggle("Camera button (18.0rc+)", isOn: gestaltkey(["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"]))
                    Toggle("Charge limit (iOS 17+)", isOn: gestaltkey(["37NVydb//GP/GrhuTN+exg"]))
                    Toggle("Crash Detection (might not work)", isOn: gestaltkey(["HCzWusHQwZDea6nNhaKndw"]))
                    Toggle("Dynamic Island (17.4+, might not work)", isOn: gestaltkey(["YlEtTtHlNesRBMal1CqRaA"]))
                    Toggle("Disable region restrictions", isOn: regionrestrictionkey())
                    Toggle("Internal Storage info", isOn: gestaltkey(["LBJfwOEzExRxzlAnSuI7eg"]))
                    Toggle("Metal HUD for all apps", isOn: gestaltkey(["EqrsVvjcYDdxHBiQmGhAWw"]))
                    Toggle("Stage Manager (iPhone only)", isOn: gestaltkey(["qeaj75wk3HF4DwQ8qbIi7g"]))
                     */
                }
                
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    if !globallogger.logs.isEmpty {
                        globallogger.divider()
                    }
                } label: {
                    Text("Modify")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.4), radius: 12)
                        .padding(.bottom)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("MobileGewalt")
        }
    }
    
    var ApplyTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(globallogger.logs, id: \.self) { log in
                        Text(log)
                            .monospaced(true)
                            .font(.system(size: 15))
                            .textSelection(.enabled)
                            .padding(.vertical, 6)
                            .onTapGesture {
                                UIPasteboard.general.string = log
                                
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                    }
                }
                
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    if modifiedgestalt {
                        globallogger.log("[ + ] krafting downloads.28 with http://localhost:\(freeport)")
                        kraftdl28()
                        
                        if !globallogger.logs.isEmpty {
                            globallogger.divider()
                        }
                    } else {
                        if confirm {
                            confirm = false
                            
                            globallogger.log("")
                            globallogger.log("[ + ] krafting downloads.28 with http://localhost:\(freeport)")
                            kraftdl28()
                            if !(afc?.exists(remote: "MobileGewalt"))! {
                                afc?.mkdir(remote: "MobileGewalt")
                            }
                            savegestalt(to: "/var/mobile/Media/MobileGewalt/com.apple.MobileGestalt.plist", afc: AppleFileConduit(udid: storedudid ??  ""))
                        } else {
                            if allownomodify {
                                if !globallogger.logs.isEmpty {
                                    globallogger.divider()
                                }
                                
                                globallogger.log("[ ! ] RUNNING WITHOUT HAVING MODIFIED MOBILEGESTALT")
                                globallogger.log("[ ! ] CONFIRM BY PRESSING THE CONFIRM BUTTON")
                                confirm = true
                            } else {
                                if !globallogger.logs.isEmpty {
                                    globallogger.divider()
                                }
                                
                                globallogger.log("[ ! ] modify mobilegestalt first")
                            }
                        }
                    }
                } label: {
                    Text(confirm ? "Confirm" : "Apply")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(confirm ? .red : .blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: confirm ? .red : .blue.opacity(0.4), radius: 12)
                        .padding(.bottom)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Apply")
        }
    }
    
    var SettingsTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        Button {
                            if pairingfile == nil {
                                showparingimporter.toggle()
                            } else {
                                pairingfile = nil
                            }
                            
                            /*
                            pairingstatus.pairingfile = pairingfile
                            if let udid = storedudid {
                                pairingstatus.startchecking(udids: [udid])
                            }
                             */
                        } label: {
                            Text(pairingfile == nil ? "Select .mobiledevicepairing" : "Reset .mobiledevicepairing")
                        }
                        
                        /*
                        ForEach(Array(pairingstatus.statuses.keys), id: \.self) { udid in
                            HStack {
                                Text("Is valid?")
                                Spacer()
                                let ok = pairingstatus.statuses[udid] ?? false
                                
                                Text(ok ? "yes" : "nah")
                                    .font(.headline)
                                    .foregroundColor(ok ? .green : .red)
                                    .bold(ok ? true : false)
                                    .cornerRadius(8)
                            }
                        }
                        */
                    } header: {
                        Text("Pairing")
                    }
                    
                    Section {
                        HStack {
                            Text("Minimuxer")
                            Spacer()
                            if muxerready {
                                if #available(iOS 18.0, *) {
                                    if beattrigger {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .shadow(color: Color.red.opacity(0.5), radius: 12)
                                            .symbolEffect(.bounce.down.wholeSymbol, options: .nonRepeating)
                                    } else {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                            .shadow(color: Color.red.opacity(0.5), radius: 12)
                                    }
                                } else {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                        .scaleEffect(heartscale)
                                        .shadow(color: Color.red.opacity(0.5), radius: 12)
                                        .onAppear {
                                            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                                heartscale = 1.3
                                            }
                                        }
                                }
                            } else {
                                Image(systemName: "heart")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button {
                            if !muxeron {
                                _ = start_emotional_damage("127.0.0.1:51820")
                                
                                if let pf = pairingfile {
                                    startmuxer(pairingfile: pf)
                                    muxeron = true
                                } else {
                                    globallogger.log("[ - ] no pairing file selected")
                                }
                            }
                        } label: {
                            Text(muxeron ? "Minimuxer Running" : "Start Minimuxer")
                        }
                    } header: {
                        Text("Muxer")
                    }
                    
                    Section {
                        Button {
                            if mobilegestalt == nil {
                                showgestaltimporter.toggle()
                            } else {
                                mobilegestalt = nil
                            }
                        } label: {
                            Text(mobilegestalt == nil ? "Select com.apple.MobileGestalt.plist" : "Reset com.apple.MobileGestalt.plist")
                        }
                    } header: {
                        Text("MobileGestalt")
                    } footer: {
                        Text("NOTE: If no MobileGestalt is found, MobileGewalt will attempt to fetch it from the device automatically")
                    }
                    
                    Section() {
                        Toggle("Allow applying without modified MobileGestalt", isOn: $allownomodify)
                        Button {
                            if (storedudid == nil) {
                                savegestalt(to: "/var/mobile/Media/MobileGewalt/com.apple.MobileGestalt.plist", afc: AppleFileConduit(udid: storedudid ??  ""))
                            } else {
                                if var udidbinding: String? = _storedudid.wrappedValue {
                                    var afcbinding = afc
                                    getudid(stored: &udidbinding, afc: &afcbinding)
                                    storedudid = udidbinding
                                    afc = afcbinding
                                } else {
                                    var udidbinding: String? = storedudid
                                    var afcbinding = afc
                                    getudid(stored: &udidbinding, afc: &afcbinding)
                                    storedudid = udidbinding
                                    afc = afcbinding
                                }
                                
                                savegestalt(to: "/var/mobile/Media/MobileGewalt/com.apple.MobileGestalt.plist", afc: AppleFileConduit(udid: storedudid ??  ""))
                            }
                        } label: {
                            Text("Save MobileGestalt")
                        }
                    }
                    
                    Section("Device") {
                        HStack {
                            Text("UDID:")
                            Spacer()
                            Text(storedudid ?? "None")
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        
                        Button {
                            if var udidbinding: String? = _storedudid.wrappedValue {
                                var afcbinding = afc
                                getudid(stored: &udidbinding, afc: &afcbinding)
                                storedudid = udidbinding
                                afc = afcbinding
                            } else {
                                var udidbinding: String? = storedudid
                                var afcbinding = afc
                                getudid(stored: &udidbinding, afc: &afcbinding)
                                storedudid = udidbinding
                                afc = afcbinding
                            }
                        } label: {
                            Text("Refresh UDID")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .fileImporter(
                isPresented: $showparingimporter,
                allowedContentTypes: [UTType(filenameExtension: "mobiledevicepairing", conformingTo: .data)!],
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        guard url.startAccessingSecurityScopedResource() else {
                            globallogger.log("[ - ] could not access file")
                            return
                        }
                        defer { url.stopAccessingSecurityScopedResource() }

                        do {
                            let contents = try String(contentsOf: url)
                            pairingfile = contents
                            
                            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let desturl = docs.appendingPathComponent(url.lastPathComponent)
                            if FileManager.default.fileExists(atPath: desturl.path) {
                                try FileManager.default.removeItem(at: desturl)
                            }
                            try contents.write(to: desturl, atomically: true, encoding: .utf8)
                        } catch {
                            globallogger.log("[ - ] error reading pairing file: \(error.localizedDescription)")
                        }

                    case .failure(let error):
                        globallogger.log("[ - ] error: \(error.localizedDescription)")
                    }
                }
            )
        }
    }
}

@main
struct mobilegewalt: App {
    init () {
        let port = freeport
        
        print("[ i ] server running on: \(port)")
        
        DispatchQueue.global(qos: .background).async {
            httpserver(port: in_port_t(port))
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
