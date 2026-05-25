import CoreLocation
import Foundation

struct HauntedSpot: Identifiable, Codable {
    let id: Int
    let name: String
    let prefecture: String
    let description: String
    let latitude: Double
    let longitude: Double
    let level: Int
    let category: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var levelText: String {
        String(repeating: "★", count: level)
    }

    var categoryIcon: String {
        switch category {
        case "廃墟": return "building.2"
        case "トンネル": return "road.lanes"
        case "橋": return "figure.walk"
        case "山": return "mountain.2"
        case "病院": return "cross.case"
        case "神社仏閣": return "building.columns"
        case "公園": return "leaf"
        case "海・湖": return "water.waves"
        case "道路": return "car"
        case "学校": return "book"
        default: return "mappin"
        }
    }
}

enum SpotDatabase {
    static let spots: [HauntedSpot] = [
        HauntedSpot(id: 1, name: "常紋トンネル", prefecture: "北海道", description: "工事中の事故や人柱伝説で知られる山間のトンネル。夜は静けさが深く、独特の緊張感があります。", latitude: 43.8012, longitude: 143.5134, level: 5, category: "トンネル"),
        HauntedSpot(id: 2, name: "慰霊の森", prefecture: "岩手県", description: "航空事故の慰霊地として知られる場所。訪れるなら敬意を持ち、静かに手を合わせたいスポットです。", latitude: 39.7456, longitude: 141.0678, level: 5, category: "山"),
        HauntedSpot(id: 3, name: "旧犬鳴トンネル", prefecture: "福岡県", description: "福岡の有名な心霊スポット。立入制限のある場所も多いため、現地ルールの確認が必要です。", latitude: 33.6234, longitude: 130.5678, level: 5, category: "トンネル"),
        HauntedSpot(id: 4, name: "八王子城跡", prefecture: "東京都", description: "戦国時代の歴史を残す城跡。霧の夜には雰囲気が一変すると語られます。", latitude: 35.6567, longitude: 139.2345, level: 4, category: "山"),
        HauntedSpot(id: 5, name: "青木ヶ原樹海", prefecture: "山梨県", description: "富士山麓に広がる深い森。迷いやすい地形のため、散策には十分な準備が必要です。", latitude: 35.4567, longitude: 138.6234, level: 4, category: "山"),
        HauntedSpot(id: 6, name: "千駄ヶ谷トンネル", prefecture: "東京都", description: "都心にありながら不気味な噂が残るトンネル。交通量が多いので安全第一で。", latitude: 35.6789, longitude: 139.7123, level: 2, category: "トンネル"),
        HauntedSpot(id: 7, name: "将門塚", prefecture: "東京都", description: "長く大切に守られてきた都心の史跡。心霊スポットとしても語られますが、礼節を忘れずに。", latitude: 35.6856, longitude: 139.7634, level: 3, category: "神社仏閣"),
        HauntedSpot(id: 8, name: "深泥池", prefecture: "京都府", description: "静かな水面と古い伝承が残る池。夜の訪問は避け、明るい時間に楽しむのが安心です。", latitude: 35.0678, longitude: 135.7789, level: 3, category: "海・湖"),
        HauntedSpot(id: 9, name: "旧吹上トンネル", prefecture: "東京都", description: "古いトンネルの空気感が強く、都内でも人気の高い怪談スポットです。", latitude: 35.8012, longitude: 139.2456, level: 3, category: "トンネル"),
        HauntedSpot(id: 10, name: "犬山城下周辺", prefecture: "愛知県", description: "歴史ある町並みに不思議な噂が点在。散歩しながら雰囲気を味わえます。", latitude: 35.3878, longitude: 136.9389, level: 2, category: "山"),
        HauntedSpot(id: 11, name: "三段壁", prefecture: "和歌山県", description: "切り立った断崖で知られる名所。足元に注意し、夜間の無理な接近は避けましょう。", latitude: 33.6712, longitude: 135.3456, level: 4, category: "海・湖"),
        HauntedSpot(id: 12, name: "姫路の廃病院跡", prefecture: "兵庫県", description: "廃墟として語られることが多いスポット。無断侵入は避け、外から雰囲気だけ確認しましょう。", latitude: 34.8234, longitude: 134.6912, level: 4, category: "病院")
    ]
}
