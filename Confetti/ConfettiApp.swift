//
//  ConfettiApp.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI
import KeyboardShortcuts

@main
struct ConfettiApp: App {
    @State private var window: NSWindow?
    @StateObject var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView(confettiRunning: appState.confettiRunning)
                    .background(WindowAccessor(window: $window))
                    .onChange(of: window) {
                        guard let window else { return; }
                        setupWindow(window)
                    }
            }
        }
        Settings {
            SettingsScreen()
        }
    }
    
    private func setupWindow(_ window: NSWindow) {
        window.isRestorable = false
        window.moveToScreenWithMouseCursor()
        window.styleMask = .borderless
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .floating
        window.setFrame(window.screen!.visibleFrame, display: true)
    }
}

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    @Published var confettiRunning = false // For triggering a confetti animation
    
    init() {
        KeyboardShortcuts.onKeyUp(for: .showConfetti) { [self] in
            self.confettiRunning = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.confettiRunning = false
            }
        }
    }
}


struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window   // << right after inserted in window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}


extension NSWindow {
    func moveToScreenWithMouseCursor() {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        for screen in screens {
            if NSMouseInRect(mouseLocation, screen.frame, false) {
                self.setFrame(screen.visibleFrame, display: true)
                break
            }
        }
    }
}
