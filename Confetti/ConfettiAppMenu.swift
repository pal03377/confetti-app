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
        SettingsLink()
        Button(action: quitApp, label: { Text("Quit") })
    }
}
