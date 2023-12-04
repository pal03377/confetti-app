//
//  SettingsScreen.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI
import KeyboardShortcuts

struct SettingsScreen: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Show Confetti:", name: .showConfetti)
            KeyboardShortcuts.Recorder("Toggle mouse confetti:", name: .toggleMouseConfettiCannonEnabled)
        }
        .padding(.all)
    }
}
