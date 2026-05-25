import MapKit
import SwiftUI

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var selectedTab = 0
    @State private var selectedSpot: HauntedSpot?
    @State private var searchText = ""
    @State private var selectedCategory = "すべて"

    private var categories: [String] {
        ["すべて"] + Array(Set(SpotDatabase.spots.map(\.category))).sorted()
    }

    private var filteredSpots: [HauntedSpot] {
        var spots = SpotDatabase.spots
        if selectedCategory != "すべて" {
            spots = spots.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            spots = spots.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.prefecture.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        return spots.sorted { a, b in
            let da = locationManager.distance(to: a) ?? .greatestFiniteMagnitude
            let db = locationManager.distance(to: b) ?? .greatestFiniteMagnitude
            return da < db
        }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                categoryBar

                TabView(selection: $selectedTab) {
                    listView.tag(0)
                    mapView.tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .sheet(item: $selectedSpot) { spot in
            DetailSheet(spot: spot, locationManager: locationManager)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.red)
                    .symbolEffect(.pulse)
                Text("心霊レーダー")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(.white)
                Spacer()
                tabToggle
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            TextField("スポット名・都道府県で検索", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(12)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.red.opacity(0.3)))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }

    private var tabToggle: some View {
        HStack(spacing: 0) {
            tabButton(icon: "list.bullet", index: 0)
            tabButton(icon: "map", index: 1)
        }
        .background(Color.white.opacity(0.08), in: Capsule())
    }

    private func tabButton(icon: String, index: Int) -> some View {
        Button {
            withAnimation { selectedTab = index }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(selectedTab == index ? .white : .white.opacity(0.4))
                .frame(width: 40, height: 34)
                .background(selectedTab == index ? Theme.red.opacity(0.6) : .clear, in: Capsule())
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        Text(cat)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(selectedCategory == cat ? .white : .white.opacity(0.5))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(selectedCategory == cat ? Theme.red.opacity(0.5) : Color.white.opacity(0.06), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredSpots) { spot in
                    SpotRow(spot: spot, distance: locationManager.distanceText(to: spot))
                        .onTapGesture { selectedSpot = spot }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 80)
        }
    }

    private var mapView: some View {
        Map {
            ForEach(filteredSpots) { spot in
                Annotation(spot.name, coordinate: spot.coordinate) {
                    Button {
                        selectedSpot = spot
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Theme.red.opacity(0.8))
                                .frame(width: 32, height: 32)
                            Text("\(spot.level)")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Spot Row

private struct SpotRow: View {
    let spot: HauntedSpot
    let distance: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.red.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: spot.categoryIcon)
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.red)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(spot.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Text(distance)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.red)
                }
                HStack(spacing: 6) {
                    Text(spot.prefecture)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    Text(spot.category)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.red.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Theme.red.opacity(0.12), in: Capsule())
                    Spacer()
                    Text(spot.levelText)
                        .font(.system(size: 12))
                }
                Text(spot.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.red.opacity(0.12)))
    }
}

// MARK: - Detail Sheet

private struct DetailSheet: View {
    let spot: HauntedSpot
    let locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }

                    // Map
                    Map {
                        Annotation(spot.name, coordinate: spot.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Theme.red)
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(spot.name)
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(.white)
                        HStack(spacing: 12) {
                            Label(spot.prefecture, systemImage: "mappin")
                            Label(spot.category, systemImage: spot.categoryIcon)
                            Label(locationManager.distanceText(to: spot), systemImage: "location")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    }

                    // Danger level
                    HStack(spacing: 8) {
                        Text("危険度")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                        ForEach(0..<5) { i in
                            Image(systemName: i < spot.level ? "flame.fill" : "flame")
                                .font(.system(size: 20))
                                .foregroundStyle(i < spot.level ? Theme.red : .white.opacity(0.2))
                        }
                    }

                    Text(spot.description)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(6)

                    // Open in Maps
                    Button {
                        let item = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinate))
                        item.name = spot.name
                        item.openInMaps()
                    } label: {
                        HStack {
                            Image(systemName: "map")
                            Text("マップで開く")
                        }
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Theme.red.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
                    }

                    Text("※ 心霊スポットへの無断侵入は法律で禁止されている場合があります。敷地に入る際は所有者の許可を得てください。")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.35))
                        .lineSpacing(4)
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Theme

enum Theme {
    static let bg = Color(red: 0.06, green: 0.06, blue: 0.10)
    static let red = Color(red: 0.85, green: 0.15, blue: 0.20)
}
