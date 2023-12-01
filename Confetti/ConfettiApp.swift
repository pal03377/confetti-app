//
//  ConfettiApp.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI

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

@main
struct ConfettiApp: App {
    @State private var window: NSWindow?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(WindowAccessor(window: $window))
                .onChange(of: window) {
                    guard let window else { return; }
                    setupWindow(window)
                }
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
