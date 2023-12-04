//
//  SettingsScreen.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin

struct SettingsScreen: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Show Confetti:", name: .showConfetti)
            KeyboardShortcuts.Recorder("Toggle mouse confetti:", name: .toggleMouseConfettiCannonEnabled)
            LaunchAtLogin.Toggle()
        }
        .frame(minWidth: 400)
        .padding(.all, 24)
    }
}
