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
    @Environment(\.openWindow) var openWindow
    @State private var window: NSWindow?
    @StateObject var appState = AppState.shared
    @State private var mouseLocationThrottleTimer: DispatchSourceTimer?
    
    var body: some Scene {
        Window("Confetti", id: "confetti") {
            ZStack {
                SideConfettiCannons(confettiRunning: appState.confettiRunning)
                MouseConfettiCannon(mouseLocation: appState.mouseLocation)
            }
            .onAppear {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.setActivationPolicy(.accessory)
            }
            .background(WindowAccessor(window: $window))
            .onChange(of: window) {
                guard let window else { return; }
                setupWindow(window)
            }
            .onChange(of: appState.confettiRunning) {
                if appState.confettiRunning {
                    moveWindowToCursorScreen() // When firing, move to cursor screen
                }
            }
            .onChange(of: appState.mouseConfettiCannonEnabled) {
                if appState.mouseConfettiCannonEnabled {
                    // Register mouse move event for mouse confetti cannon
                    NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                        if !appState.mouseConfettiCannonEnabled { return nil } // Remove mouse event listener
                        DispatchQueue.main.async {
                            moveWindowToCursorScreen()
                            for screen in NSScreen.screens {
                                if NSMouseInRect(NSEvent.mouseLocation, screen.frame, false) {
                                    guard let window else { return }
                                    appState.mouseLocation = window.mouseLocationOutsideOfEventStream // Get coordinates within screen
                                    // Y coordinate is reversed (starts at bottom left) => change
                                    appState.mouseLocation.y = window.frame.height - appState.mouseLocation.y
                                    break
                                }
                            }
                        }
                        return $0
                    }
                }
            }
        }
        MenuBarExtra("Confetti", systemImage: "party.popper.fill") {
            ConfettiAppMenu()
        }
        Settings {
            SettingsScreen()
        }
    }
    
    private func setupWindow(_ window: NSWindow) {
        window.isRestorable = false
        window.styleMask = .borderless
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .floating
        window.setFrame(window.screen!.visibleFrame, display: true)
    }
    
    private func moveWindowToCursorScreen() {
        for screen in NSScreen.screens {
            if NSMouseInRect(NSEvent.mouseLocation, screen.frame, false) {
                guard let window else { return }
                if window.screen != screen { // Window not on correct screen yet?
                    // Move window to screen
                    window.setFrame(screen.visibleFrame, display: false)
                }
                break
            }
        }
    }

}

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    @Published var confettiRunning = false // For triggering a confetti animation
    @Published var mouseLocation = NSPoint()
    @Published var mouseConfettiCannonEnabled = false
    
    init() {
        KeyboardShortcuts.onKeyDown(for: .showConfetti) { [self] in
            self.confettiRunning = true
        }
        KeyboardShortcuts.onKeyUp(for: .showConfetti) { [self] in
            self.confettiRunning = false
        }
        KeyboardShortcuts.onKeyDown(for: .toggleMouseConfettiCannonEnabled) {
            self.mouseConfettiCannonEnabled.toggle()
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
