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
    @ObservedObject var stage = stagestatus
    
    var body: some View {
        TabView {
            MGTab
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
                    
                    if !stage.onedone {
                        logger.log("[ 1/3 ] starting stage 1")
                        generator.impactOccurred()
                        kraftdl28()
                        globallogger.divider()
                    } else {
                        if !stage.twodone {
                            logger.log("[ 2/3 ] starting stage 2")
                            generator.impactOccurred()
                            kraftBLDMgr()
                            globallogger.divider()
                        } else {
                            let vc = UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .first?.windows.first?.rootViewController
                            
                            logger.log("[ 3/3 ] starting stage 3")
                            generator.impactOccurred()
                            if let vc = vc {
                                kraftepub(from: vc)
                            } else {
                                logger.log("[ - ] could not get UIViewController")
                            }
                            globallogger.divider()
                        }
                    }
                } label: {
                    Text(stage.text)
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
}

@main
struct mobilegewalt: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
