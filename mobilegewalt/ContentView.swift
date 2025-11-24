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
    @State private var copyindex: Int? = nil
    
    var body: some View {
        TabView {
            MGTab
                .tabItem {
                    Label("MobileGewalt", systemImage: "wrench.and.screwdriver")
                }
            
            SettingsTab
                .tabItem {
                    Label("MobileGewalt", systemImage: "wrench.and.screwdriver")
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
