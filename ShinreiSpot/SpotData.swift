import CoreLocation
import Foundation

struct HauntedSpot: Identifiable, Codable {
    let id: Int
    let name: String
    let prefecture: String
    let description: String
    let latitude: Double
    let longitude: Double
    let level: Int // 1-5 danger level
    let category: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var levelText: String {
        String(repeating: "\u{1F480}", count: level)
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
        // -- 北海道 --
        HauntedSpot(id: 1, name: "円形校舎", prefecture: "北海道", description: "沼東小学校の廃校舎。夜になると窓に子供の影が映るという。", latitude: 43.3456, longitude: 144.3789, level: 3, category: "学校"),
        HauntedSpot(id: 2, name: "常紋トンネル", prefecture: "北海道", description: "建設時にタコ部屋労働者が人柱にされたと伝わる。壁から人骨が発見された。", latitude: 43.8012, longitude: 143.5134, level: 5, category: "トンネル"),
        HauntedSpot(id: 3, name: "中国人墓地", prefecture: "北海道", description: "旭川市内の丘にある墓地。深夜に行くと帰れなくなるという。", latitude: 43.7800, longitude: 142.3500, level: 3, category: "公園"),

        // -- 東北 --
        HauntedSpot(id: 4, name: "八甲田山雪中行軍遭難資料館", prefecture: "青森県", description: "199名が遭難死した八甲田雪中行軍の地。冬に軍人の行進が聞こえるという。", latitude: 40.7134, longitude: 140.8567, level: 4, category: "山"),
        HauntedSpot(id: 5, name: "慰霊の森", prefecture: "岩手県", description: "1971年の全日空機衝突事故の慰霊碑。深夜に悲鳴が聞こえるとの報告多数。", latitude: 39.7456, longitude: 141.0678, level: 5, category: "山"),

        // -- 関東 --
        HauntedSpot(id: 6, name: "旧犬鳴トンネル", prefecture: "福岡県", description: "入口がコンクリートで封鎖された廃トンネル。「この先日本国憲法は適用されない」の看板伝説。", latitude: 33.6234, longitude: 130.5678, level: 5, category: "トンネル"),
        HauntedSpot(id: 7, name: "八王子城跡", prefecture: "東京都", description: "北条氏の城。落城時に女性たちが滝に身を投げた。雨の日に女性の声が聞こえるという。", latitude: 35.6567, longitude: 139.2345, level: 4, category: "山"),
        HauntedSpot(id: 8, name: "千駄ヶ谷トンネル", prefecture: "東京都", description: "上に墓地がある都心のトンネル。タクシー運転手の怪談が有名。", latitude: 35.6789, longitude: 139.7123, level: 2, category: "トンネル"),
        HauntedSpot(id: 9, name: "平将門の首塚", prefecture: "東京都", description: "大手町のオフィス街にある塚。移転しようとすると災いが起きるという。", latitude: 35.6856, longitude: 139.7634, level: 3, category: "神社仏閣"),
        HauntedSpot(id: 10, name: "旧吹上トンネル", prefecture: "東京都", description: "青梅市の廃トンネル。白い影の目撃談や車の故障報告が多い。", latitude: 35.8012, longitude: 139.2456, level: 3, category: "トンネル"),
        HauntedSpot(id: 11, name: "鈴ヶ森刑場跡", prefecture: "東京都", description: "江戸時代の処刑場。火あぶりの柱石や磔台が残る。", latitude: 35.5912, longitude: 139.7389, level: 3, category: "公園"),
        HauntedSpot(id: 12, name: "田老鉱山跡", prefecture: "岩手県", description: "かつて栄えた鉱山の廃墟。建物内で足音が聞こえるという。", latitude: 39.7345, longitude: 141.8567, level: 3, category: "廃墟"),

        // -- 中部 --
        HauntedSpot(id: 13, name: "花魁淵", prefecture: "山梨県", description: "武田家の金山で働いた遊女55人が口封じのため斬殺された場所。", latitude: 35.7823, longitude: 138.7567, level: 4, category: "海・湖"),
        HauntedSpot(id: 14, name: "青木ヶ原樹海", prefecture: "山梨県", description: "富士山麓の広大な森。磁場の乱れでコンパスが狂う。", latitude: 35.4567, longitude: 138.6234, level: 4, category: "山"),
        HauntedSpot(id: 15, name: "人穴浅間神社", prefecture: "静岡県", description: "富士山の溶岩洞穴。源頼家の家臣が探索し多くが命を落とした。", latitude: 35.3456, longitude: 138.6123, level: 3, category: "神社仏閣"),

        // -- 関西 --
        HauntedSpot(id: 16, name: "清滝トンネル", prefecture: "京都府", description: "嵐山近くの古いトンネル。信号が長く、ミラーに人影が映ると言われる。", latitude: 35.0234, longitude: 135.6567, level: 3, category: "トンネル"),
        HauntedSpot(id: 17, name: "深泥池", prefecture: "京都府", description: "タクシーの幽霊話の発祥地。乗せた女性客が消え、座席が濡れていた。", latitude: 35.0678, longitude: 135.7789, level: 3, category: "海・湖"),
        HauntedSpot(id: 18, name: "一条戻り橋", prefecture: "京都府", description: "死者が蘇った伝説の橋。安倍晴明が式神を隠した場所としても有名。", latitude: 35.0234, longitude: 135.7534, level: 2, category: "橋"),
        HauntedSpot(id: 19, name: "化野念仏寺", prefecture: "京都府", description: "8000体の石仏が並ぶ。かつての葬送地で、夜は石仏が動くという。", latitude: 35.0278, longitude: 135.6456, level: 3, category: "神社仏閣"),
        HauntedSpot(id: 20, name: "信貴生駒スカイライン", prefecture: "奈良県", description: "深夜のドライブスポット。首なしライダーの目撃談が有名。", latitude: 34.6789, longitude: 135.6789, level: 3, category: "道路"),

        // -- 中国・四国 --
        HauntedSpot(id: 21, name: "大久野島毒ガス資料館", prefecture: "広島県", description: "戦時中に毒ガスを製造した島。廃墟に軍人の影が見えるという。", latitude: 34.3123, longitude: 132.9923, level: 3, category: "廃墟"),
        HauntedSpot(id: 22, name: "倉橋島の防空壕跡", prefecture: "広島県", description: "旧海軍の防空壕。内部から声が聞こえるという報告がある。", latitude: 34.1023, longitude: 132.5345, level: 3, category: "廃墟"),

        // -- 九州・沖縄 --
        HauntedSpot(id: 23, name: "旧犬鳴トンネル", prefecture: "福岡県", description: "封鎖されたトンネルの先に犬鳴村があるという都市伝説の発祥地。", latitude: 33.6312, longitude: 130.5534, level: 5, category: "トンネル"),
        HauntedSpot(id: 24, name: "SSビル", prefecture: "沖縄県", description: "那覇市内の廃ビル。米軍統治時代の悲劇が語り継がれている。", latitude: 26.3345, longitude: 127.7678, level: 3, category: "廃墟"),
        HauntedSpot(id: 25, name: "ひめゆりの塔", prefecture: "沖縄県", description: "沖縄戦でひめゆり学徒隊が犠牲になった壕。深い悲しみの場所。", latitude: 26.0912, longitude: 127.7234, level: 4, category: "山"),

        // -- 追加スポット --
        HauntedSpot(id: 26, name: "姫路の廃病院", prefecture: "兵庫県", description: "取り壊されずに残る廃病院。手術室で器具の音が聞こえるという。", latitude: 34.8234, longitude: 134.6912, level: 4, category: "病院"),
        HauntedSpot(id: 27, name: "犬山城周辺", prefecture: "愛知県", description: "国宝犬山城の裏手。落武者の霊が出るという古戦場跡。", latitude: 35.3878, longitude: 136.9389, level: 2, category: "山"),
        HauntedSpot(id: 28, name: "松尾鉱山跡", prefecture: "岩手県", description: "東洋一の硫黄鉱山の廃墟群。巨大な集合住宅が朽ちたまま残る。", latitude: 39.9234, longitude: 140.7678, level: 3, category: "廃墟"),
        HauntedSpot(id: 29, name: "雄島", prefecture: "福井県", description: "東尋坊の沖にある島。赤い橋を渡ると帰れなくなるという噂がある。", latitude: 36.2345, longitude: 136.1234, level: 3, category: "海・湖"),
        HauntedSpot(id: 30, name: "三段壁", prefecture: "和歌山県", description: "高さ50mの断崖。自殺の名所でもあり、供養塔が立つ。", latitude: 33.6712, longitude: 135.3456, level: 4, category: "海・湖"),
        HauntedSpot(id: 31, name: "旧小峰トンネル", prefecture: "東京都", description: "あきる野市の廃トンネル。女性の幽霊の目撃談が絶えない。", latitude: 35.7345, longitude: 139.1789, level: 3, category: "トンネル"),
        HauntedSpot(id: 32, name: "将門塚の周辺ビル", prefecture: "東京都", description: "首塚に背を向けてデスクを置いたOLが次々体調不良になったという。", latitude: 35.6860, longitude: 139.7640, level: 2, category: "廃墟"),
        HauntedSpot(id: 33, name: "池添のおばけ坂", prefecture: "高知県", description: "上り坂に見えて実は下り坂。車を停めると勝手に進む不思議な坂。", latitude: 33.5567, longitude: 133.5345, level: 1, category: "道路"),
        HauntedSpot(id: 34, name: "六甲山の廃ホテル", prefecture: "兵庫県", description: "かつての高級ホテルの廃墟。宴会場から笑い声が聞こえるという。", latitude: 34.7734, longitude: 135.2567, level: 3, category: "廃墟"),
        HauntedSpot(id: 35, name: "朝鮮トンネル", prefecture: "福岡県", description: "戦時中に朝鮮人労働者が建設したトンネル。うめき声が聞こえるという。", latitude: 33.7123, longitude: 130.8234, level: 4, category: "トンネル"),
        HauntedSpot(id: 36, name: "東京タワー蝋人形館跡", prefecture: "東京都", description: "かつて東京タワー内にあった蝋人形館。閉館後も人形が動いたという噂。", latitude: 35.6586, longitude: 139.7454, level: 1, category: "廃墟"),
        HauntedSpot(id: 37, name: "多摩湖", prefecture: "東京都", description: "ダム建設時に多くの労働者が亡くなった。湖面から手が出るという。", latitude: 35.7612, longitude: 139.3845, level: 3, category: "海・湖"),
        HauntedSpot(id: 38, name: "泉の広場", prefecture: "大阪府", description: "梅田地下街の噴水広場。赤い服の女の幽霊が出ると噂された。", latitude: 34.7034, longitude: 135.4989, level: 1, category: "公園"),
        HauntedSpot(id: 39, name: "犬吠埼灯台周辺", prefecture: "千葉県", description: "断崖絶壁の灯台。霧の夜に灯台守の影が見えるという。", latitude: 35.7078, longitude: 140.8689, level: 2, category: "海・湖"),
        HauntedSpot(id: 40, name: "軍艦島", prefecture: "長崎県", description: "端島炭鉱の廃墟島。廃墟群の窓から人影が見えるとの報告がある。", latitude: 32.6278, longitude: 129.7389, level: 3, category: "廃墟"),
    ]
}
