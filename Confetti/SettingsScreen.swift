import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin

struct SettingsScreen: View {
    var body: some View {
        Form {
            Section {
                ForEach(ConfettiKind.allCases) { confettiKind in
                    KeyboardShortcuts.Recorder(confettiKind.settingsTitle, name: confettiKind.shortcutName)
                }
            } header: {
                Text(String(localized: "Confetti shortcuts"))
            }
            KeyboardShortcuts.Recorder(String(localized: "Toggle mouse confetti:"), name: .toggleMouseConfettiCannonEnabled)
            LaunchAtLogin.Toggle()
        }
        .frame(minWidth: 400)
        .padding(.all, 24)
    }
}
