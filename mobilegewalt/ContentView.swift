//
//  ContentView.swift
//  mobilegewalt
//
//  Created by ruter on 18.11.25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject var logger = globallogger
    @State var copyindex: Int? = nil
    @State var showparingimporter = false
    @State var showgestaltimporter = false
    @AppStorage("PairingFile") var pairingfile: String?
    @AppStorage("MobileGestalt") var mobilegestalt: String?
    
    var body: some View {
        TabView {
            MGTab
                .tabItem {
                    Label("MobileGewalt", systemImage: "wrench.and.screwdriver")
                }
            
            SettingsTab
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }

    var MGTab: some View {
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
                    
                    globallogger.log("[ + ] krafting downloads.28 with http://localhost:\(freeport)")
                    kraftdl28()
                } label: {
                    Text("Apply")
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
    
    var SettingsTab: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Button {
                        if pairingfile == nil {
                            showparingimporter.toggle()
                        } else {
                            pairingfile = nil
                        }
                    } label: {
                        Text(pairingfile == nil ? "Select .mobiledevicepairing" : "Reset .mobiledevicepairing")
                    }
                    Button {
                        if mobilegestalt == nil {
                            showgestaltimporter.toggle()
                        } else {
                            mobilegestalt = nil
                        }
                    } label: {
                        Text(mobilegestalt == nil ? "Select com.apple.MobileGestalt.plist" : "Reset com.apple.MobileGestalt.plist")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

@main
struct mobilegewalt: App {
    init () {
        let port = freeport
        print("[ i ] server running on: \(port)")
        
        DispatchQueue.global().async {
            try? httpserver(port: port)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
