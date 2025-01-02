import SwiftUI

let MOUSE_CONFETTI_CANNON_DEBUGGING = false

struct ConfettiCannonConfig: Identifiable {
    let id: UUID
    let position: NSPoint
    let direction: ConfettiDirection
    let velocity: Double
}

struct MouseConfettiCannon: View {
    @State private var mouseVelocity: CGFloat = 0
    @State private var lastMouseUpdateTime = Date()
    @State private var confettiCannonConfigs: [ConfettiCannonConfig] = []
    @State private var shootingIds: [UUID] = []
    @State var oldMouseLocation: NSPoint = NSPoint()
    var mouseLocation: NSPoint
    
    var body: some View {
        Group {
            ForEach(confettiCannonConfigs) { cannonConfig in
                ConfettiCannonRepresentable(
                    confettiRunning: shootingIds.contains(cannonConfig.id),
                    direction: cannonConfig.direction,
                    emissionVelocity: cannonConfig.velocity,
                    birthRate: Float(cannonConfig.velocity / 10) // Emit more when faster
                )
                    .background(MOUSE_CONFETTI_CANNON_DEBUGGING ? .yellow : .clear)
                    .position(cannonConfig.position)
            }
            if MOUSE_CONFETTI_CANNON_DEBUGGING {
                Rectangle() // debug rect
                    .fill(.red)
                    .frame(width: 3, height: 3)
                    .position(mouseLocation)
            }
        }
        .onChange(of: mouseLocation) { _ in // Cannot use params because function is throttled
            // Throttle function to avoid problems with high event resolution
            let passedTimeSeconds = CGFloat(Date().timeIntervalSince(lastMouseUpdateTime))
            if passedTimeSeconds < 0.05 { return }
            let distance = sqrt(pow(mouseLocation.x - oldMouseLocation.x, 2) + pow(mouseLocation.y - oldMouseLocation.y, 2))
            let velocity = distance / passedTimeSeconds
            let angle = Angle.radians(atan2(0 - (mouseLocation.y - oldMouseLocation.y), mouseLocation.x - oldMouseLocation.x) + Double.pi / 2) // We reverted the y axis in ConfettiApp.swift => need to revert again for angles; angles are 90° rotated against each other
            let cannonConfig = ConfettiCannonConfig(
                id: UUID(),
                position: mouseLocation,
                direction: ConfettiDirection(direction: angle, spread: .degrees(30)),
                velocity: velocity / 2
            )
            confettiCannonConfigs.append(cannonConfig)
            shootingIds.append(cannonConfig.id)
            // Turn off after Xs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                shootingIds.removeAll { $0 == cannonConfig.id }
            }
            // Delete after Ys
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                confettiCannonConfigs.removeAll { $0.id == cannonConfig.id }
            }
            oldMouseLocation = mouseLocation
            lastMouseUpdateTime = Date()
        }
    }
}

#Preview {
    @State var mouseLocation = NSPoint(x: 300, y: 200)
    
    return MouseConfettiCannon(mouseLocation: mouseLocation)
        .frame(width: 600, height: 400)
}
