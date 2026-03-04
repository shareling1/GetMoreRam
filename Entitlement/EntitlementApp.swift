//
//  EntitlementApp.swift
//  Entitlement
//
//  Created by s s on 2025/3/14.
//

import SwiftUI

@main
struct EntitlementApp: App {
    @StateObject private var privacyManager = PrivacyManager()
    @StateObject private var powerThrottler = PowerThrottler()
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(privacyManager)
            .environmentObject(powerThrottler)
            .onAppear {
                // PowerThrottler owns the CMMotionManager — pass externalMotion: true
                privacyManager.startMonitoring(externalMotion: true)
                powerThrottler.attach(to: privacyManager, arSession: privacyManager.arSession)
                powerThrottler.start()
            }
        }
    }
}
