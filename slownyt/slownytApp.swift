//
//  slownytApp.swift
//  slownyt
//
//  Created by Noel Rohi on 1/8/26.
//

import SwiftUI

@main
struct slownytApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var viewModel = DiagnosticViewModel()

    var body: some Scene {
        MenuBarExtra {
            DiagnosticPopoverView(viewModel: viewModel)
        } label: {
            MenuBarIconView(status: viewModel.overallStatus)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView {
                viewModel.setupAutoRefresh()
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if another instance is already running
        let runningApps = NSWorkspace.shared.runningApplications
        let myBundleId = Bundle.main.bundleIdentifier ?? ""

        let instances = runningApps.filter { $0.bundleIdentifier == myBundleId }

        if instances.count > 1 {
            // Another instance is running, quit this one
            NSApplication.shared.terminate(nil)
        }
    }
}
