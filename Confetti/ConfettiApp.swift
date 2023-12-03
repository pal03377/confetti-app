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
            .background(WindowAccessor(window: $window))
            .onChange(of: window) {
                guard let window else { return; }
                setupWindow(window)
            }
            .onAppear(perform: {
                NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                    DispatchQueue.main.async {
                        for screen in NSScreen.screens {
                            if NSMouseInRect(NSEvent.mouseLocation, screen.frame, false) {
                                DispatchQueue.main.async {
                                    appState.mouseLocation = NSEvent.mouseLocation
                                    // Set mouse position relative to screen
                                    appState.mouseLocation.x -= screen.frame.origin.x
                                    appState.mouseLocation.y -= screen.frame.origin.y
                                    // Revert y axis to match SwiftUI coordinates
                                    appState.mouseLocation.y = screen.frame.height - appState.mouseLocation.y
                                    // If window not on correct screen yet
                                    if window?.screen != screen {
                                        // Move window to screen
                                        window?.setFrame(screen.visibleFrame, display: true)
                                    }
                                }
                                break
                            }
                        }
                    }
                    return $0
//                    mouseLocationThrottleTimer?.cancel()  // Cancel the existing timer if it exists
//                    mouseLocationThrottleTimer = DispatchSource.makeTimerSource()
//                    mouseLocationThrottleTimer?.schedule(deadline: .now() + 0.1, repeating: .never) // Throttle event to every 100ms
//                    mouseLocationThrottleTimer?.setEventHandler {
//                        appState.mouseLocation = NSEvent.mouseLocation
//                    }
//                    mouseLocationThrottleTimer?.resume()
//                    return $0
                }
            })
        }
        MenuBarExtra("Confetti", systemImage: "party.popper.fill") {
            ConfettiAppMenu()
        }
        Settings {
            SettingsScreen()
        }
    }
    
    private func setupWindow(_ window: NSWindow) {
        return
        window.isRestorable = false
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
    @Published var mouseLocation = NSPoint()
    
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
