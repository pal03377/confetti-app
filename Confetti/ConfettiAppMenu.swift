//
//  ConfettiAppMenu.swift
//  Confetti
//
//  Created by Paul Schwind on 03.12.23.
//

import SwiftUI

struct ConfettiAppMenu: View {
    func quitApp() {
        exit(0)
    }

    var body: some View {
        if #available(macOS 14, *) {
            SettingsLink()
        } else {
            // Backwards-compatible settings button
            Button("Settings") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
        }
        Button(action: quitApp, label: { Text(String(localized: "Quit")) })
    }
}
