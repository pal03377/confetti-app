import SwiftUI


struct SideConfettiCannons: View {
    var confettiRunning: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // Pushes content to the bottom
                HStack {
                    ConfettiCannonRepresentable(confettiRunning: confettiRunning, direction: .topRight, emissionVelocity: geometry.size.width)
                    Spacer()
                    ConfettiCannonRepresentable(confettiRunning: confettiRunning, direction: .topLeft, emissionVelocity: geometry.size.width)
                }
            }
        }
    }
}

#Preview {
    SideConfettiCannons(confettiRunning: true)
        .frame(width: 600, height: 400)
}
