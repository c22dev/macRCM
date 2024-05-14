//
//  macRCMApp.swift
//  macRCM
//
//  Created by Constantin Clerc on 14/05/2024.
//

import SwiftUI

// public var
var selectedPayloadPath = "None"
@main
struct macRCMApp: App {
    @AppStorage("showMenuBar") var showMenuBar: Bool = true
    @AppStorage("bgMode") var bgMode: Bool = false
    @Environment(\.openWindow) private var openWindow
    var body: some Scene {
        WindowGroup(id: "main-win") {
            ContentView()
        }
        .windowResizabilityContentSize()
        MenuBarExtra("macRCM", systemImage: "hammer", isInserted: $showMenuBar) {
            AppMenu()
        }
    }
}


// https://forums.developer.apple.com/forums/thread/719389
extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
