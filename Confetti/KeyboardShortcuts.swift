//
//  KeyboardShortcuts.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import Foundation

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let showConfetti = Self("showConfetti", default: .init(.period, modifiers: [.command]))
}
