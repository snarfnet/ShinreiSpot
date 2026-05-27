import CoreLocation
import SwiftUI

struct RadarScanView: View {
    let spots: [HauntedSpot]
    let locationManager: LocationManager
    let onSpotTap: (HauntedSpot) -> Void
    @State private var sweepAngle: Double = 0
    @State private var blipOpacity: [Int: Double] = [:]

    private let maxRange: Double = 50_000 // 50km radius

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) - 40
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size / 2

            ZStack {
                // Range rings
                ForEach(1..<5) { ring in
                    Circle()
                        .stroke(Theme.red.opacity(0.18), lineWidth: 1)
                        .frame(width: size * CGFloat(ring) / 4, height: size * CGFloat(ring) / 4)
                }

                // Crosshairs
                Path { p in
                    p.move(to: CGPoint(x: center.x, y: center.y - radius))
                    p.addLine(to: CGPoint(x: center.x, y: center.y + radius))
                }
                .stroke(Theme.red.opacity(0.12), lineWidth: 1)

                Path { p in
                    p.move(to: CGPoint(x: center.x - radius, y: center.y))
                    p.addLine(to: CGPoint(x: center.x + radius, y: center.y))
                }
                .stroke(Theme.red.opacity(0.12), lineWidth: 1)

                // Sweep beam
                SweepShape(angle: sweepAngle, radius: radius)
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [Theme.red.opacity(0.35), Theme.red.opacity(0.0)]),
                            center: .center,
                            startAngle: .degrees(sweepAngle - 40),
                            endAngle: .degrees(sweepAngle)
                        )
                    )
                    .frame(width: size, height: size)
                    .position(center)

                // Sweep line
                Path { p in
                    let endX = center.x + radius * CGFloat(cos((sweepAngle - 90) * .pi / 180))
                    let endY = center.y + radius * CGFloat(sin((sweepAngle - 90) * .pi / 180))
                    p.move(to: center)
                    p.addLine(to: CGPoint(x: endX, y: endY))
                }
                .stroke(Theme.red.opacity(0.7), lineWidth: 2)

                // Spot blips
                ForEach(nearbySpots) { spot in
                    let pos = spotPosition(spot: spot, center: center, radius: radius)
                    Button {
                        onSpotTap(spot)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Theme.red.opacity(blipOpacity[spot.id] ?? 0.3))
                                .frame(width: blipSize(spot), height: blipSize(spot))
                            Circle()
                                .fill(Theme.red)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .position(pos)
                }

                // Center dot (you)
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }
                .position(center)

                // Range labels
                VStack {
                    Spacer()
                    HStack {
                        Text("範囲: \(Int(maxRange / 1000))km")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.red.opacity(0.6))
                        Spacer()
                        Text("検出: \(nearbySpots.count)件")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.red.opacity(0.6))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                sweepAngle = 360
            }
            // Pulse blips
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                for spot in nearbySpots {
                    withAnimation(.easeOut(duration: 1.5)) {
                        blipOpacity[spot.id] = Double.random(in: 0.3...0.9)
                    }
                }
            }
        }
    }

    private var nearbySpots: [HauntedSpot] {
        spots.filter { spot in
            guard let d = locationManager.distance(to: spot) else { return true }
            return d <= maxRange
        }.prefix(20).map { $0 }
    }

    private func spotPosition(spot: HauntedSpot, center: CGPoint, radius: CGFloat) -> CGPoint {
        guard let userLoc = locationManager.location else {
            // Fallback: distribute evenly
            let angle = Double(spot.id * 37 % 360) * .pi / 180
            let dist = radius * CGFloat(0.3 + Double(spot.id * 13 % 60) / 100.0)
            return CGPoint(x: center.x + dist * CGFloat(cos(angle)), y: center.y + dist * CGFloat(sin(angle)))
        }

        let spotLoc = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        let distance = userLoc.distance(from: spotLoc)
        let normalizedDist = min(distance / maxRange, 0.95) * Double(radius)

        // Calculate bearing
        let lat1 = userLoc.coordinate.latitude * .pi / 180
        let lat2 = spot.latitude * .pi / 180
        let dLon = (spot.longitude - userLoc.coordinate.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) // radians from north

        let px = center.x + CGFloat(normalizedDist * sin(bearing))
        let py = center.y - CGFloat(normalizedDist * cos(bearing))
        return CGPoint(x: px, y: py)
    }

    private func blipSize(_ spot: HauntedSpot) -> CGFloat {
        CGFloat(12 + spot.level * 4)
    }
}

private struct SweepShape: Shape {
    var angle: Double
    let radius: CGFloat

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.move(to: center)
        p.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(angle - 90 - 40),
            endAngle: .degrees(angle - 90),
            clockwise: false
        )
        p.closeSubpath()
        return p
    }
}
