import SwiftUI


struct SideConfettiCannons: View {
    var confettiRunning: Bool
    var confettiKind: ConfettiKind = .default
    
    var body: some View {
        GeometryReader { geometry in
            let outsideOffset = max(24, geometry.size.width * 0.04)

            ZStack {
                ConfettiCannonRepresentable(
                    confettiRunning: confettiRunning,
                    kind: confettiKind,
                    direction: .topRight,
                    emissionVelocity: geometry.size.width
                )
                .position(x: -outsideOffset, y: geometry.size.height)

                ConfettiCannonRepresentable(
                    confettiRunning: confettiRunning,
                    kind: confettiKind,
                    direction: .topLeft,
                    emissionVelocity: geometry.size.width
                )
                .position(x: geometry.size.width + outsideOffset, y: geometry.size.height)
            }
        }
    }
}

#Preview {
    SideConfettiCannons(confettiRunning: true)
        .frame(width: 600, height: 400)
}
