import Foundation

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let showConfetti = Self("showConfetti", default: .init(.period, modifiers: [.command]))
    static let showChaosConfetti = Self("showChaosConfetti", default: .none)
    static let showSparklesConfetti = Self("showSparklesConfetti", default: .none)
    static let showHeartsConfetti = Self("showHeartsConfetti", default: .none)
    static let showSnowConfetti = Self("showSnowConfetti", default: .none)
    static let showShitConfetti = Self("showShitConfetti", default: .none)
    static let toggleMouseConfettiCannonEnabled = Self("toggleMouseConfettiCannonEnabled", default: .none)
}

extension ConfettiKind {
    var shortcutName: KeyboardShortcuts.Name {
        switch self {
        case .default:
            return .showConfetti
        case .chaos:
            return .showChaosConfetti
        case .sparkles:
            return .showSparklesConfetti
        case .hearts:
            return .showHeartsConfetti
        case .snow:
            return .showSnowConfetti
        case .shit:
            return .showShitConfetti
        }
    }
}
