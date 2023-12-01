//
//  WindowTransparency.swift
//  Confetti
//
//  Created by Paul Schwind on 01.12.23.
//

import SwiftUI
import AppKit

struct WindowTransparency: NSWindowRepresentable {
    func makeNSWindow(context: Context) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: ContentView())
        return window
    }
}
