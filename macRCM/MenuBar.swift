//
//  MenuBar.swift
//  macRCM
//
//  Created by Constantin Clerc on 14/05/2024.
//

import Foundation
import SwiftUI

struct AppMenu: View {
    @State private var isPluggedIn = false
    @State private var isPluggedInAlert = false
    @State private var nxPath: URL?
    @AppStorage("payloadPath") var payloadPath: URL = URL(fileURLWithPath:"/dev/null/")
    @State private var selectedPayload: String = "None"
    @Environment(\.openWindow) private var openWindow
    func openApp() {
        openWindow(id: "main-win")
    }
    func quitApp() {
        exit(0)
    }
    func injectPayload() {
        var systeminfo = utsname()
        uname(&systeminfo)
        let machine = withUnsafeBytes(of: &systeminfo.machine) {bufPtr->String in
            let data = Data(bufPtr)
            if let lastIndex = data.lastIndex(where: {$0 != 0}) {
                return String(data: data[0...lastIndex], encoding: .isoLatin1)!
            } else {
                return String(data: data, encoding: .isoLatin1)!
            }
        }
        if isSwitchPluggedIn() {
            if machine == "arm64" {
                print("Detected Apple Silicon Mac (\(machine))")
                nxPath = Bundle.main.url(forResource: "nxboot_arm64", withExtension: "")
            }
            else {
                print("Detected Intel Mac (\(machine))")
                nxPath = Bundle.main.url(forResource: "nxboot", withExtension: "")
            }
            let process = Process()
            process.executableURL = nxPath
            process.arguments = [urltoString(payloadPath)]
            print(process.arguments!)
            do {
                try process.run()
            } catch {}
        }
        else {
            isPluggedInAlert.toggle()
        }
    }

    var body: some View {
        Text("Selected Payload:")
            .onAppear {
                DispatchQueue.global().async {
                    while true {
                        sleep(1)
                    }
                }
            }
        if payloadPath.absoluteString == "file:///dev/null" {
            Text("None")
        }
        else {
            Text("\(payloadPath.lastPathComponent)")
        }
        Divider()
        if !FileManager.default.fileExists(atPath: urltoString(payloadPath)) {
            Button(action: openApp, label: { Text("Payload Deleted") })
        }
        else {
            Button(action: injectPayload, label: { Text("Inject Payload") })
        }
        Divider()
        Button(action: openApp, label: { Text("Open App") })
        Button(action: quitApp, label: { Text("Quit App") })
            .alert("No RCM Device detected.", isPresented: $isPluggedInAlert) {
                Button("OK", role: .none) { isPluggedInAlert.toggle() }
            }
    }
}
