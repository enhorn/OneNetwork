//
//  AppDelegate.swift
//  Thesaurus
//
//  Created by Robin Enhorn on 2019-12-21.
//  Copyright © 2019 Enhorn. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let apiKey = UserDefaults.standard.string(forKey: "thesaurus-api-key") ?? ""
        let contentView = ContentView(apiKey: apiKey, query: "")

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )

        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

}
