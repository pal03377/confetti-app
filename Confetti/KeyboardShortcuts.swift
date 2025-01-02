import Foundation

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let showConfetti = Self("showConfetti", default: .init(.period, modifiers: [.command]))
    static let toggleMouseConfettiCannonEnabled = Self("toggleMouseConfettiCannonEnabled", default: .none)
}
