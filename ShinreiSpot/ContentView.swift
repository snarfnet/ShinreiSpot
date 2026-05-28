import MapKit
import SwiftUI

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var selectedTab = 1
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
            RadarBackground()

            VStack(spacing: 0) {
                header
                categoryBar

                TabView(selection: $selectedTab) {
                    listView.tag(0)
                    radarView.tag(1)
                    mapView.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear { locationManager.requestPermission() }
        .sheet(item: $selectedSpot) { spot in
            DetailSheet(spot: spot, locationManager: locationManager)
        }
        .safeAreaInset(edge: .bottom) {
            AdMobBannerView(adUnitID: AdMobConfig.bannerAdUnitID)
                .background(.black.opacity(0.82))
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Label("GPS心霊スポットレーダー", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                tabToggle
            }

            TextField("スポット名・都道府県で検索", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(13)
                .background(.white.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.red.opacity(0.42)))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var tabToggle: some View {
        HStack(spacing: 0) {
            tabButton(icon: "list.bullet", label: "リスト", index: 0)
            tabButton(icon: "dot.radiowaves.left.and.right", label: "レーダー", index: 1)
            tabButton(icon: "map", label: "マップ", index: 2)
        }
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
    }

    private func tabButton(icon: String, label: String, index: Int) -> some View {
        Button {
            withAnimation { selectedTab = index }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                Text(label)
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(selectedTab == index ? .white : .white.opacity(0.45))
            .frame(width: 56, height: 42)
            .background(selectedTab == index ? Theme.red.opacity(0.72) : .clear, in: RoundedRectangle(cornerRadius: 8))
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
                            .foregroundStyle(selectedCategory == cat ? .white : .white.opacity(0.58))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedCategory == cat ? Theme.red.opacity(0.62) : .white.opacity(0.08), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
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

    private var radarView: some View {
        RadarScanView(
            spots: filteredSpots,
            locationManager: locationManager,
            onSpotTap: { spot in selectedSpot = spot }
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
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
                                .fill(Theme.red.opacity(0.86))
                                .frame(width: 34, height: 34)
                            Text("\(spot.level)")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

private struct SpotRow: View {
    let spot: HauntedSpot
    let distance: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Theme.red.opacity(0.16))
                    .frame(width: 54, height: 54)
                Image(systemName: spot.categoryIcon)
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.red)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(spot.name)
                        .font(.system(size: 17, weight: .bold))
                        .lineLimit(1)
                    Spacer()
                    Text(distance)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.red)
                }
                HStack(spacing: 7) {
                    Text(spot.prefecture)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.54))
                    Text(spot.category)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.red.opacity(0.92))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.red.opacity(0.14), in: Capsule())
                    Spacer()
                    Text(spot.levelText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.red)
                }
                Text(spot.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(2)
            }
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(.black.opacity(0.34), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.red.opacity(0.18)))
    }
}

private struct DetailSheet: View {
    let spot: HauntedSpot
    let locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.07).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white.opacity(0.45))
                        }
                    }

                    Map {
                        Annotation(spot.name, coordinate: spot.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(Theme.red)
                        }
                    }
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 9) {
                        Text(spot.name)
                            .font(.system(size: 28, weight: .black))
                        HStack(spacing: 12) {
                            Label(spot.prefecture, systemImage: "mappin")
                            Label(spot.category, systemImage: spot.categoryIcon)
                            Label(locationManager.distanceText(to: spot), systemImage: "location")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.62))
                    }

                    HStack(spacing: 8) {
                        Text("危険度")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.62))
                        ForEach(0..<5) { i in
                            Image(systemName: i < spot.level ? "flame.fill" : "flame")
                                .font(.system(size: 20))
                                .foregroundStyle(i < spot.level ? Theme.red : .white.opacity(0.20))
                        }
                    }

                    Text(spot.description)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.84))
                        .lineSpacing(6)

                    Button {
                        let item = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinate))
                        item.name = spot.name
                        item.openInMaps()
                    } label: {
                        Label("マップで開く", systemImage: "map")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(Theme.red.opacity(0.74), in: RoundedRectangle(cornerRadius: 16))
                    }

                    Text("無断侵入は禁止です。現地では周囲の安全とルールを必ず確認してください。")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.38))
                        .lineSpacing(4)
                }
                .foregroundStyle(.white)
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct RadarBackground: View {
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            Image("HeroArtwork")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.42)
            LinearGradient(colors: [.black.opacity(0.18), .black.opacity(0.86)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
}

enum Theme {
    static let bg = Color(red: 0.04, green: 0.04, blue: 0.07)
    static let red = Color(red: 0.92, green: 0.13, blue: 0.18)
}
