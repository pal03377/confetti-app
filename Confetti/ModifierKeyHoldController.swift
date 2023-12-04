//
//  ModifierKeyHoldController.swift
//  Confetti
//
//  Created by Paul Schwind on 04.12.23.
//

import AppKit

class ModifierKeyHoldController: ObservableObject {
    @Published var isOptionPressed = false
    
    init() {
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event -> NSEvent? in
            if event.modifierFlags.contains(.option) {
                self?.isOptionPressed = true
            } else {
                self?.isOptionPressed = false
            }
            return event
        }
    }
}
