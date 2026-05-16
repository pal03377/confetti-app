import SwiftUI
import KeyboardShortcuts

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct ConfettiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    @State private var window: NSWindow?
    @StateObject var appState = AppState.shared
    @State private var mouseLocationThrottleTimer: DispatchSourceTimer?
    
    var body: some Scene {
        Window("Confetti", id: "confetti") {
            ZStack {
                SideConfettiCannons(confettiRunning: appState.confettiRunning, confettiKind: appState.confettiKind)
                MouseConfettiCannon(mouseLocation: appState.mouseLocation)
            }
            .onAppear {
                NSApp.setActivationPolicy(.accessory)
            }
            .background(WindowAccessor(window: $window))
            .onChange(of: window) { _ in
                guard let window else { return; }
                setupWindow(window)
            }
            .onChange(of: appState.confettiRunning) { _ in
                if appState.confettiRunning { // Confetti now running?
                    moveWindowToCursorScreen() // Move window to cursor screen to show confetti there
                }
            }
            .onChange(of: appState.confettiKind) { _ in
                if appState.confettiRunning {
                    moveWindowToCursorScreen()
                }
            }
            .onChange(of: appState.mouseConfettiCannonEnabled) { _ in
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
        window.level = .screenSaver
        window.hidesOnDeactivate = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary] // No interaction with window cycling
        window.isMovableByWindowBackground = false
        window.setFrame(window.screen!.visibleFrame, display: true)
        window.orderFrontRegardless()
    }
    
    private func moveWindowToCursorScreen() {
        for screen in NSScreen.screens {
            if NSMouseInRect(NSEvent.mouseLocation, screen.frame, false) {
                guard let window else { return }
                // Move window to screen
                window.setFrame(screen.visibleFrame, display: false)
                window.level = .screenSaver
                window.orderFrontRegardless()
                break
            }
        }
    }

}

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    @Published var confettiRunning = false // For triggering a confetti animation
    @Published var confettiKind: ConfettiKind = .default
    @Published var mouseLocation = NSPoint()
    @Published var mouseConfettiCannonEnabled = false
    private var pressedConfettiKinds: [ConfettiKind] = []
    private var confettiTurnOffTask: Task<Void, Never>?
    
    init() {
        // Register keyboard shortcuts
        for confettiKind in ConfettiKind.allCases {
            KeyboardShortcuts.onKeyDown(for: confettiKind.shortcutName) { [self] in
                self.startHoldingConfetti(confettiKind)
            }
            KeyboardShortcuts.onKeyUp(for: confettiKind.shortcutName) { [self] in
                self.stopHoldingConfetti(confettiKind)
            }
        }
        KeyboardShortcuts.onKeyDown(for: .toggleMouseConfettiCannonEnabled) {
            self.mouseConfettiCannonEnabled.toggle()
        }
        // Register global internal app notifications to make Clipboard Portal sync of confetti possible :D
        DistributedNotificationCenter.default().addObserver(forName: Notification.Name("de.pschwind.Confetti.fire"), object: nil, queue: .main) { [weak self] notification in
            print("Global Confetti notification received!")
            Task { @MainActor [weak self] in // Weird construct that is needed for no compile errors
                guard let self = self else { return }
                let confettiKind = ConfettiKind.fromNotificationUserInfo(notification.userInfo)
                self.fireTransientConfetti(confettiKind)
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in // Every X seconds
            Task { @MainActor [weak self] in // Weird construct that is needed for no compile errors
                guard let self = self else { return }
                if self.confettiRunning && self.confettiTurnOffTask == nil { // While confetti is running, but not because of a previous event (to prevent infinite loop)
                    print("Sending global Confetti notification for Clipboard Portal")
                    DistributedNotificationCenter.default().postNotificationName(Notification.Name("de.pschwind.Confetti.wasFired"), object: nil, userInfo: self.confettiKind.notificationUserInfo, deliverImmediately: true) // Send notification to tell Clipboard Portal that there is now confetti so that the other person can also see it if they have Clipboard Portal and Confetti Magic installed
                }
            }
        }
    }

    private func startHoldingConfetti(_ confettiKind: ConfettiKind) {
        confettiTurnOffTask?.cancel()
        confettiTurnOffTask = nil
        pressedConfettiKinds.removeAll { $0 == confettiKind }
        pressedConfettiKinds.append(confettiKind)
        self.confettiKind = confettiKind
        self.confettiRunning = true
    }

    private func stopHoldingConfetti(_ confettiKind: ConfettiKind) {
        pressedConfettiKinds.removeAll { $0 == confettiKind }

        if let lastPressedConfettiKind = pressedConfettiKinds.last {
            self.confettiKind = lastPressedConfettiKind
            self.confettiRunning = true
        } else {
            self.confettiRunning = false
        }
    }

    private func fireTransientConfetti(_ confettiKind: ConfettiKind) {
        self.confettiKind = confettiKind
        self.confettiRunning = true // Start confetti
        confettiTurnOffTask?.cancel() // Cancel last planned confetti stop
        confettiTurnOffTask = Task { // Schedule confetti stop after Xms
            try? await Task.sleep(for: .milliseconds(200)) // Wait Xms
            if Task.isCancelled { return } // Stop if task was cancelled because of another confetti event
            DispatchQueue.main.async { self.confettiRunning = false } // Stop confetti
            self.confettiTurnOffTask = nil // Reset confetti turnoff task to allow sending the confetti throwing event again
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
