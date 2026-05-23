import SwiftUI

enum ConfettiKind: String, CaseIterable, Identifiable {
    case `default`
    case chaos
    case sparkles
    case hearts
    case snow
    case shit

    var id: String {
        rawValue
    }

    var settingsTitle: String {
        switch self {
        case .default:
            return String(localized: "Default Confetti:")
        case .chaos:
            return String(localized: "Chaos Confetti:")
        case .sparkles:
            return String(localized: "Sparkles:")
        case .hearts:
            return String(localized: "Hearts:")
        case .snow:
            return String(localized: "Snow:")
        case .shit:
            return String(localized: "Sh**:")
        }
    }

    static func fromNotificationUserInfo(_ userInfo: [AnyHashable: Any]?) -> ConfettiKind {
        guard let value = userInfo?["kind"] as? String ?? userInfo?["type"] as? String else {
            return .default
        }

        return ConfettiKind(rawValue: value) ?? .default
    }

    var notificationUserInfo: [String: Any] {
        [
            "protocolVersion": 2,
            "kind": rawValue
        ]
    }
}

private struct ConfettiStyle {
    let assetNames: [String]
    let emojis: [String]
    let birthRateMultiplier: Float
    let velocityMultiplier: Double
    let spreadMultiplier: Double
    let scale: CGFloat
    let scaleRange: CGFloat
    let lifetime: Float

    static func style(for kind: ConfettiKind) -> ConfettiStyle {
        switch kind {
        case .default:
            return ConfettiStyle(
                assetNames: ConfettiStyle.defaultAssetNames,
                emojis: [],
                birthRateMultiplier: 1,
                velocityMultiplier: 1,
                spreadMultiplier: 1,
                scale: 0.5,
                scaleRange: 0.2,
                lifetime: 10
            )
        case .chaos:
            return ConfettiStyle(
                assetNames: ConfettiStyle.defaultAssetNames,
                emojis: ["🎉", "🎊", "✨"],
                birthRateMultiplier: 1.7,
                velocityMultiplier: 1.15,
                spreadMultiplier: 1.35,
                scale: 0.55,
                scaleRange: 0.35,
                lifetime: 10
            )
        case .sparkles:
            return ConfettiStyle(
                assetNames: [],
                emojis: ["✨", "⭐️", "💫"],
                birthRateMultiplier: 0.9,
                velocityMultiplier: 0.9,
                spreadMultiplier: 1.1,
                scale: 0.42,
                scaleRange: 0.22,
                lifetime: 8
            )
        case .hearts:
            return ConfettiStyle(
                assetNames: [],
                emojis: ["❤️", "💖", "💛", "💙", "💚", "💜"],
                birthRateMultiplier: 0.95,
                velocityMultiplier: 0.85,
                spreadMultiplier: 1,
                scale: 0.48,
                scaleRange: 0.22,
                lifetime: 9
            )
        case .snow:
            return ConfettiStyle(
                assetNames: [],
                emojis: ["❄️", "✦"],
                birthRateMultiplier: 0.75,
                velocityMultiplier: 0.55,
                spreadMultiplier: 1.45,
                scale: 0.38,
                scaleRange: 0.2,
                lifetime: 11
            )
        case .shit:
            return ConfettiStyle(
                assetNames: [],
                emojis: ["💩"],
                birthRateMultiplier: 1.1,
                velocityMultiplier: 0.85,
                spreadMultiplier: 1.15,
                scale: 0.55,
                scaleRange: 0.18,
                lifetime: 9
            )
        }
    }

    private static var defaultAssetNames: [String] {
        var assetNames: [String] = []
        for shape in ["ellipse", "parallelogram", "spiral", "triangle"] {
            for colorIndex in 1...5 {
                assetNames.append("\(shape)_\(colorIndex)")
            }
        }
        return assetNames
    }
}

struct ConfettiDirection: Equatable {
    var direction: Angle // 0 degrees is down; counterclockwise
    var spread: Angle
    
    static var topRight: ConfettiDirection {
        return ConfettiDirection(direction: .degrees(145), spread: .degrees(45))
    }
    
    static var topLeft: ConfettiDirection {
        return ConfettiDirection(direction: .degrees(215), spread: .degrees(45))
    }
}

class ConfettiCannon: NSView {
    private var emitter = CAEmitterLayer()
    private var emissionVelocity: Double = 400
    private var direction: ConfettiDirection = .topRight
    private var birthRate: Float = 50
    private var kind: ConfettiKind = .default
    private var style: ConfettiStyle = .style(for: .default)
    private var configuredCellBirthRates: [String: Float] = [:]
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupConfetti()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConfetti()
    }
    
    private func updateCellProperties() {
        for cell in emitter.emitterCells ?? [] {
            let velocity = emissionVelocity * style.velocityMultiplier
            let configuredBirthRate = birthRate * style.birthRateMultiplier

            cell.birthRate = configuredBirthRate
            cell.lifetime = style.lifetime
            cell.velocity = velocity
            cell.velocityRange = velocity / 2
            // Acceleration in opposite x direction of direction for drag effect
            cell.xAcceleration = 0.3 * velocity * CGFloat(cos(direction.direction.radians + .pi / 2)) // Angles are shifted 90° vs. the needed cos for the acceleration x direction
            // Gravity effect
            cell.yAcceleration = -velocity
            cell.spin = 0
            cell.spinRange = 10
            cell.scale = style.scale
            cell.scaleRange = style.scaleRange
            cell.alphaSpeed = 0 - 1 / cell.lifetime // Ensure invisibility after lifetime
            cell.emissionLongitude = direction.direction.radians
            cell.emissionRange = direction.spread.radians * style.spreadMultiplier

            if let cellName = cell.name, configuredCellBirthRates[cellName] != configuredBirthRate {
                emitter.setValue(configuredBirthRate, forKeyPath: "emitterCells.\(cellName).birthRate")
                configuredCellBirthRates[cellName] = configuredBirthRate
            }
        }
    }

    func setKind(_ kind: ConfettiKind) {
        if kind != self.kind {
            self.kind = kind
            self.style = .style(for: kind)
            rebuildEmitterCells()
            updateCellProperties()
        }
    }
    
    func setDirection(_ direction: ConfettiDirection) {
        if direction != self.direction {
            self.direction = direction
            updateCellProperties()
        }
    }
    
    func setEmissionVelocity(_ emissionVelocity: Double) {
        if emissionVelocity != self.emissionVelocity {
            self.emissionVelocity = emissionVelocity
            updateCellProperties()
        }
    }
    
    func setBirthRate(_ birthRate: Float) {
        if birthRate != self.birthRate {
            self.birthRate = birthRate
            updateCellProperties()
        }
    }

    private func setupConfetti() {
        self.wantsLayer = true
        
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: 0, y: 0)
        emitter.emitterSize = CGSize(width: 1, height: 1)
        emitter.birthRate = 1
        
        // see https://nshipster.com/caemitterlayer/ for confetti layer explaination
        // see https://bryce.co/caemitterbehavior/ for emitter behavior explaination - probably should not use
        
        rebuildEmitterCells()
        updateCellProperties()

        emitter.beginTime = CACurrentMediaTime(); // Important fix for strange emitter behavior on stop, see https://stackoverflow.com/a/18933226/4306257. The fix does not seem to work in the preview, but it works in the final app.
        layer!.addSublayer(emitter)
    }

    private func rebuildEmitterCells() {
        var cells: [CAEmitterCell] = []
        configuredCellBirthRates.removeAll()

        for assetName in style.assetNames {
            let cell = CAEmitterCell()
            cell.name = "asset_\(assetName)"
            cell.contents = NSImage(named: NSImage.Name(assetName))?.cgImage(forProposedRect: nil, context: nil, hints: nil)
            cells.append(cell)
        }

        for (emojiIndex, emoji) in style.emojis.enumerated() {
            let cell = CAEmitterCell()
            cell.name = "emoji_\(emojiIndex)"
            cell.contents = Self.emojiImage(for: emoji)
            cells.append(cell)
        }

        emitter.emitterCells = cells
    }

    private static func emojiImage(for emoji: String) -> CGImage? {
        let font = NSFont.systemFont(ofSize: 48)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: emoji, attributes: attributes)
        let stringSize = attributedString.size()
        let imageSize = NSSize(width: ceil(stringSize.width), height: ceil(stringSize.height))
        let image = NSImage(size: imageSize)

        image.lockFocus()
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: imageSize).fill()
        attributedString.draw(at: .zero)
        image.unlockFocus()

        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    func startConfetti() {
        emitter.lifetime = 10
    }

    func stopConfetti() {
        emitter.lifetime = 0
    }
}

struct ConfettiCannonRepresentable: NSViewRepresentable {
    var confettiRunning: Bool
    var kind: ConfettiKind = .default
    var direction: ConfettiDirection
    var emissionVelocity: Double = 400
    var birthRate: Float = 50

    func makeNSView(context: Context) -> ConfettiCannon {
        return ConfettiCannon()
    }
    
    func updateNSView(_ nsView: ConfettiCannon, context: Context) {
        nsView.setKind(kind)
        nsView.setEmissionVelocity(emissionVelocity)
        nsView.setDirection(direction)
        nsView.setBirthRate(birthRate)
        if confettiRunning {
            nsView.startConfetti()
        } else {
            nsView.stopConfetti()
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, nsView: ConfettiCannon, context: Context) -> CGSize? {
        // Small 1x1 emitter
        return CGSize(width: 1, height: 1)
    }
}

#Preview {
    @State var confettiRunning = true
    
    return VStack {
        Spacer()
        HStack {
            ConfettiCannonRepresentable(confettiRunning: confettiRunning, direction: .topRight, emissionVelocity: 600)
                .background(Color.yellow)
            Spacer()
            Button("toggle") {
                confettiRunning.toggle()
            }
        }
    }
    .frame(width: 600, height: 400)
}
