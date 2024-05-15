//
//  ContentView.swift
//  macRCM
//
//  Created by Constantin Clerc on 28.02.2024.
//

import SwiftUI
import Cocoa
import LaunchAtLogin

struct ContentView: View {
    @AppStorage("showMenuBar") var showMenuBar: Bool = true
    @AppStorage("bgMode") var bgMode: Bool = false
    @AppStorage("payloadPath") var payloadPath: URL = URL(fileURLWithPath:"/dev/null/")
    @State private var selectedFile: URL?
    @State private var selectedFileDef: URL?
    @State private var outputText: String = ""
    @State private var isShowingPopup = false
    @State private var isBg = false
    @State private var isPluggedIn = false
    @State private var isPopoverPresented = false
    @State private var plsRestart = false
    @State private var isThereAnyPayloadForBg = true
    @State private var machine: String = ""
    @State private var nxPath: URL?
    var body: some View {
        VStack {
            withAnimation {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .scaledToFit()
                    .padding()
                    .padding(.trailing, 50)
                    .padding(.leading, 50)
            }
            Text("macRCM")
                .font(.title2)
                .bold()
            Button("Select Payload") {
                let openPanel = NSOpenPanel()
                openPanel.prompt = "Select"
                openPanel.canChooseFiles = true
                openPanel.canChooseDirectories = false
                openPanel.allowsMultipleSelection = false
                openPanel.allowedFileTypes = ["bin"]
                
                if openPanel.runModal() == .OK {
                    selectedFile = openPanel.urls.first
                }

            }
            if !(selectedFile == nil) {
                Text("Selected payload : \(selectedFile!.lastPathComponent)")
            }
            HStack {
                Toggle(isOn: $isBg) {
                    Text("Background Mode")
                }
                .onAppear {
                    if payloadPath == URL(fileURLWithPath: "/dev/null/") {
                        isThereAnyPayloadForBg = false
                    }
                    else {
                        isThereAnyPayloadForBg = true
                    }
                }
                .onChange(of: isBg) { newValue in
                    bgMode = isBg
                }
                .disabled(!isThereAnyPayloadForBg)
                .padding(.top, 15)
                Button(action: {
                    isPopoverPresented.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.blue)
                }
                .padding(.top, 15)
                .buttonStyle(PlainButtonStyle())
                Button(action: {
                    let openPanel = NSOpenPanel()
                    openPanel.prompt = "Select a default Payload"
                    openPanel.canChooseFiles = true
                    openPanel.canChooseDirectories = false
                    openPanel.allowsMultipleSelection = false
                    openPanel.allowedFileTypes = ["bin"]
                    
                    if openPanel.runModal() == .OK {
                        selectedFileDef = openPanel.urls.first
                    }
                    if selectedFileDef != nil {
                        payloadPath = selectedFileDef!
                        plsRestart.toggle()
                    }
                    
                }) {
                    Image(systemName: "doc")
                        .foregroundColor(.blue)
                }
                .padding(.top, 15)
                .buttonStyle(PlainButtonStyle())
                if payloadPath.absoluteString != "file:///dev/null" {
                    Button(action: {
                        payloadPath = URL(fileURLWithPath: "/dev/null/")
                        plsRestart.toggle()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                    .padding(.top, 15)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom, content: {
                VStack {
                    Text("Background Mode")
                        .font(.headline)
                    Text("This mode keeps checking for an RCM connection and inject your last selected payload in the background.")
                        .font(.subheadline)
                        .padding(.top, 10)
                }
                .frame(width: 200)
                .padding()
            })
            .onAppear {
                isPopoverPresented = false
            }
            .toggleStyle(.checkbox)
            .padding(0.001)
            .alert("Default Payload Set! Please restart app for the changes to take place.", isPresented: $plsRestart) {
                Button("Restart", role: .none) {
                    restartApplication()
                }
            }
            
            LaunchAtLogin.Toggle()
            Toggle(isOn: $showMenuBar) {
                Text("Show in Menu Bar")
            }
                .padding(.bottom, 10)
            
            
            Text(isPluggedIn ? "RCM Detected!" : "Switch isn't plugged or RCM is disabled")
                .foregroundColor(isPluggedIn ? .green : .red)
                .onAppear {
                    self.checkPluggedStatus()
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        self.checkPluggedStatus()
                    }
                }
            if isPluggedIn {
                Button("Inject Payload !") {
                    if (selectedFile == nil) {
                        self.isShowingPopup = true
                    }
                    else {
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
                        process.arguments = [urltoString(selectedFile!)]
                        print(process.arguments!)
                        do {
                            
                            try process.run()
                        } catch {}
                    }
                }
                .onAppear {
                    var systeminfo = utsname()
                    uname(&systeminfo)
                    machine = withUnsafeBytes(of: &systeminfo.machine) {bufPtr->String in
                        let data = Data(bufPtr)
                        if let lastIndex = data.lastIndex(where: {$0 != 0}) {
                            return String(data: data[0...lastIndex], encoding: .isoLatin1)!
                        } else {
                            return String(data: data, encoding: .isoLatin1)!
                        }
                    }
                }
                .alert("No Payload Selected!", isPresented: $isShowingPopup) {
                    Button("Close", role: .cancel) { }
                }
                .padding()
            }
        }
        .padding()
    }
    func checkPluggedStatus() {
        self.isPluggedIn = isSwitchPluggedIn()
    }
}



func urltoString(_ selectedFile: URL) -> String {
    let stringFile = "\(selectedFile)"
    if stringFile.hasPrefix("file://") {
        let urlStringWithoutFilePrefix = stringFile.replacingOccurrences(of: "file://", with: "")
        return urlStringWithoutFilePrefix
    }
    else {
        return selectedFile.absoluteString
    }
}

func restartApplication() {
    let mainBundlePath = Bundle.main.bundlePath
    let task = Process()

    task.launchPath = "/usr/bin/open"
    task.arguments = ["-n", mainBundlePath]

    task.launch()
    exit(0)
}
