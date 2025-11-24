import Foundation

enum TasteTag: String, Codable, CaseIterable {
    case sweet
    case sour
    case fresh
    case floral
    case dessert
}

extension TasteTag {
    var adjective: String {
        switch self {
        case .sweet:   return "Sweet"
        case .sour:    return "Sour"
        case .fresh:   return "Fresh"
        case .floral:  return "Floral"
        case .dessert: return "Dessert"
        }
    }
    
    var taglinePhrase: String {
        switch self {
        case .sweet:
            return "Perfect for dessert lovers!"
        case .sour:
            return "For a bold, tangy mood!"
        case .fresh:
            return "Perfect for summer!"
        case .floral:
            return "Delicate and aromatic experience."
        case .dessert:
            return "Like a sweet treat in a hookah!"
        }
    }
}

enum FlavorCategory: String, Codable {
    case berry
    case citrus
    case fruit
    case tropical
    case dessert
    case drink
    case flower
    case herb
    case spice
    case other
}

struct Flavor: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let code: String
    let iconAssetName: String
    let category: FlavorCategory
    let tasteTags: [TasteTag]
}

extension Flavor {
    init(
        name: String,
        code: String,
        iconAssetName: String,
        category: FlavorCategory,
        tasteTags: [TasteTag]
    ) {
        self.id = UUID()
        self.name = name
        self.code = code
        self.iconAssetName = iconAssetName
        self.category = category
        self.tasteTags = tasteTags
    }
    
    static let raspberry = Flavor(
        name: "Raspberry",
        code: "raspberry",
        iconAssetName: "flavor_raspberry",
        category: .berry,
        tasteTags: [.sweet]
    )
    
    static let strawberry = Flavor(
        name: "Strawberry",
        code: "strawberry",
        iconAssetName: "flavor_strawberry",
        category: .berry,
        tasteTags: [.sweet]
    )
    
    static let apple = Flavor(
        name: "Apple",
        code: "apple",
        iconAssetName: "flavor_apple",
        category: .fruit,
        tasteTags: [.sweet, .sour, .fresh]
    )
    
    static let cola = Flavor(
        name: "Cola",
        code: "cola",
        iconAssetName: "flavor_cola",
        category: .drink,
        tasteTags: [.sweet, .dessert]
    )
    
    static let pie = Flavor(
        name: "Pie",
        code: "pie",
        iconAssetName: "flavor_pie",
        category: .dessert,
        tasteTags: [.sweet, .dessert]
    )
    
    static let mango = Flavor(
        name: "Mango",
        code: "mango",
        iconAssetName: "flavor_mango",
        category: .tropical,
        tasteTags: [.sweet, .fresh]
    )
    
    static let lime = Flavor(
        name: "Lime",
        code: "lime",
        iconAssetName: "flavor_lime",
        category: .citrus,
        tasteTags: [.sour, .fresh]
    )
    
    static let vanilla = Flavor(
        name: "Vanilla",
        code: "vanilla",
        iconAssetName: "flavor_vanilla",
        category: .dessert,
        tasteTags: [.sweet, .dessert]
    )
    
    static let mint = Flavor(
        name: "Mint",
        code: "mint",
        iconAssetName: "flavor_mint",
        category: .herb,
        tasteTags: [.fresh]
    )
    
    static let blueberry = Flavor(
        name: "Blueberry",
        code: "blueberry",
        iconAssetName: "flavor_blueberry",
        category: .berry,
        tasteTags: [.sweet, .sour]
    )
    
    static let watermelon = Flavor(
        name: "Watermelon",
        code: "watermelon",
        iconAssetName: "flavor_watermelon",
        category: .fruit,
        tasteTags: [.sweet, .fresh]
    )
    
    static let rose = Flavor(
        name: "Rose",
        code: "rose",
        iconAssetName: "flavor_rose",
        category: .flower,
        tasteTags: [.sweet, .floral]
    )
    
    static let coffee = Flavor(
        name: "Coffee",
        code: "coffee",
        iconAssetName: "flavor_coffee",
        category: .drink,
        tasteTags: [.dessert]
    )
    
    static let lychee = Flavor(
        name: "Lychee",
        code: "lychee",
        iconAssetName: "flavor_lychee",
        category: .tropical,
        tasteTags: [.sweet, .sour, .fresh]
    )
    
    static let pineapple = Flavor(
        name: "Pineapple",
        code: "pineapple",
        iconAssetName: "flavor_pineapple",
        category: .tropical,
        tasteTags: [.sweet, .sour, .fresh]
    )
    
    static let coconut = Flavor(
        name: "Coconut",
        code: "coconut",
        iconAssetName: "flavor_coconut",
        category: .tropical,
        tasteTags: [.sweet, .fresh]
    )
    
    static let caramel = Flavor(
        name: "Caramel",
        code: "caramel",
        iconAssetName: "flavor_caramel",
        category: .dessert,
        tasteTags: [.sweet, .dessert]
    )
    
    static let pear = Flavor(
        name: "Pear",
        code: "pear",
        iconAssetName: "flavor_pear",
        category: .fruit,
        tasteTags: [.sweet, .fresh]
    )
    
    static let orange = Flavor(
        name: "Orange",
        code: "orange",
        iconAssetName: "flavor_orange",
        category: .citrus,
        tasteTags: [.sweet, .sour, .fresh]
    )
    
    static let grape = Flavor(
        name: "Grape",
        code: "grape",
        iconAssetName: "flavor_grape",
        category: .fruit,
        tasteTags: [.sweet, .sour]
    )
    
    static let banana = Flavor(
        name: "Banana",
        code: "banana",
        iconAssetName: "flavor_banana",
        category: .fruit,
        tasteTags: [.sweet, .dessert]
    )
    
    static let kiwi = Flavor(
        name: "Kiwi",
        code: "kiwi",
        iconAssetName: "flavor_kiwi",
        category: .fruit,
        tasteTags: [.sweet, .sour, .fresh]
    )
    
    static let peach = Flavor(
        name: "Peach",
        code: "peach",
        iconAssetName: "flavor_peach",
        category: .fruit,
        tasteTags: [.sweet, .fresh]
    )
    
    static let chocolate = Flavor(
        name: "Chocolate",
        code: "chocolate",
        iconAssetName: "flavor_chocolate",
        category: .dessert,
        tasteTags: [.sweet, .dessert]
    )
    
    static let lavender = Flavor(
        name: "Lavender",
        code: "lavender",
        iconAssetName: "flavor_lavender",
        category: .flower,
        tasteTags: [.floral]
    )
    
    static let ginger = Flavor(
        name: "Ginger",
        code: "ginger",
        iconAssetName: "flavor_ginger",
        category: .spice,
        tasteTags: [.sour, .fresh]
    )
    
    static let pomegranate = Flavor(
        name: "Pomegranate",
        code: "pomegranate",
        iconAssetName: "flavor_pomegranate",
        category: .fruit,
        tasteTags: [.sweet, .sour, .fresh]
    )
    
    static let honey = Flavor(
        name: "Honey",
        code: "honey",
        iconAssetName: "flavor_honey",
        category: .dessert,
        tasteTags: [.sweet, .dessert]
    )
    
    static let cranberry = Flavor(
        name: "Cranberry",
        code: "cranberry",
        iconAssetName: "flavor_cranberry",
        category: .berry,
        tasteTags: [.sweet, .sour]
    )
    
    static let eucalyptus = Flavor(
        name: "Eucalyptus",
        code: "eucalyptus",
        iconAssetName: "flavor_eucalyptus",
        category: .herb,
        tasteTags: [.fresh]
    )
    
    static let allFlavors: [Flavor] = [
        raspberry,
        strawberry,
        apple,
        cola,
        pie,
        mango,
        lime,
        vanilla,
        blueberry,
        watermelon,
        rose,
        coffee,
        lychee,
        pineapple,
        coconut,
        caramel,
        pear,
        orange,
        grape,
        banana,
        kiwi,
        peach,
        chocolate,
        lavender,
        pomegranate,
        ginger,
        cranberry,
        honey,
        eucalyptus,
        mint
    ]
}

struct FlavorProfile: Codable, Equatable {
    let descriptors: [String]
    
    var description: String {
        descriptors.joined(separator: ", ")
    }
    
    static func makeProfile(from flavors: [Flavor]) -> FlavorProfile {
        var counter: [TasteTag: Int] = [:]
        
        for flavor in flavors {
            for tag in flavor.tasteTags {
                counter[tag, default: 0] += 1
            }
        }
        
        let sortedTags: [TasteTag] = counter
            .sorted { $0.value > $1.value }
            .map { $0.key }
        
        let adjectives: [String] = sortedTags
            .prefix(3)
            .map { $0.adjective }
        
        return FlavorProfile(descriptors: Array(adjectives))
    }
}

extension FlavorProfile {
    var mainTasteTag: TasteTag? {
        guard let first = descriptors.first else { return nil }
        if first == TasteTag.sweet.adjective   { return .sweet }
        if first == TasteTag.sour.adjective    { return .sour }
        if first == TasteTag.fresh.adjective   { return .fresh }
        if first == TasteTag.floral.adjective  { return .floral }
        if first == TasteTag.dessert.adjective { return .dessert }
        return nil
    }
    
    var tagline: String {
        mainTasteTag?.taglinePhrase ?? "Special mix for your session!"
    }
}

struct MixTitleGenerator {
    static func makeTitle(
        for flavors: [Flavor],
        profile: FlavorProfile
    ) -> String {
        guard !flavors.isEmpty else { return "Untitled Mix" }
        
        let categories = Set(flavors.map { $0.category })
        let tags = Set(flavors.flatMap { $0.tasteTags })
        
        if categories.contains(.citrus),
           (categories.contains(.berry) || tags.contains(.sweet)) {
            return "Citrus Blast"
        }
        
        if categories.contains(.berry), flavors.count >= 2 {
            return "Berry Paradise"
        }
        
        if categories.contains(.tropical), flavors.count >= 2 {
            return "Tropical Storm"
        }
        
        if categories.contains(.dessert) || tags.contains(.dessert) {
            return "Dessert Heaven"
        }
        
        if categories.contains(.flower) || tags.contains(.floral) {
            return "Floral Garden"
        }
        
        if tags.contains(.fresh),
           flavors.contains(where: { $0.code == "mint" || $0.code == "eucalyptus" }) {
            return "Minty Chill"
        }
        
        if let first = profile.descriptors.first {
            return "\(first) Mix"
        }
        
        return "Secret Mix"
    }
}

struct HookahMix: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let flavors: [Flavor]
    let profile: FlavorProfile
    let createdAt: Date
    var rating: Int?
    var note: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: createdAt)
    }
    
    init(flavors: [Flavor]) {
        self.id = UUID()
        self.flavors = flavors
        self.createdAt = Date()
        
        let profile = FlavorProfile.makeProfile(from: flavors)
        self.profile = profile
        self.title = MixTitleGenerator.makeTitle(for: flavors, profile: profile)
        
        self.rating = nil
        self.note = nil
    }
}

struct WheelSector: Identifiable {
    let index: Int
    let flavor: Flavor
    let startAngle: Double
    let endAngle: Double
    var id: Int { index }
}

extension WheelSector {
    static func makeWheelSectors(
        flavors: [Flavor]
    ) -> [WheelSector] {
        guard !flavors.isEmpty else { return [] }
        
        let sectorAngle = 360.0 / Double(flavors.count)
        
        return flavors.enumerated().map { index, flavor in
            let start = Double(index) * sectorAngle
            let end = start + sectorAngle
            return WheelSector(
                index: index,
                flavor: flavor,
                startAngle: start,
                endAngle: end
            )
        }
    }
    
    static func sector(
        for angle: Double,
        in sectors: [WheelSector]
    ) -> WheelSector? {
        guard !sectors.isEmpty else { return nil }
        
        let normalized = (angle.truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360)
        
        return sectors.first { sector in
            normalized >= sector.startAngle && normalized < sector.endAngle
        }
    }
}

protocol MixRepository {
    func loadAll() -> [HookahMix]
    func save(_ mix: HookahMix)
    func delete(_ mix: HookahMix)
}

final class UserDefaultsMixRepository: MixRepository {
    private let storageKey = "saved_hookah_mixes"
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    func loadAll() -> [HookahMix] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let mixes = try decoder.decode([HookahMix].self, from: data)
            return mixes
        } catch {
            print("⚠️ Failed to decode mixes: \(error)")
            return []
        }
    }
    
    func save(_ mix: HookahMix) {
        var mixes = loadAll()
        
        if let index = mixes.firstIndex(where: { $0.id == mix.id }) {
            mixes[index] = mix
        } else {
            mixes.append(mix)
        }
        
        do {
            let data = try encoder.encode(mixes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("⚠️ Failed to encode mixes: \(error)")
        }
    }
    
    func delete(_ mix: HookahMix) {
        var mixes = loadAll()
        mixes.removeAll { $0.id == mix.id }
        
        do {
            let data = try encoder.encode(mixes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("⚠️ Failed to encode mixes after deletion: \(error)")
        }
    }
}
