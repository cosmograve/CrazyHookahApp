import Foundation
import SwiftUI
import Combine

enum CrazyHookahScreenState {
    case start
    case wheel
    case result
    case rating
    case archive
}

@MainActor
final class CrazyHookahStore: ObservableObject {
    
    let allFlavors: [Flavor]
    let wheelSectors: [WheelSector]
    
    let maxSpins: Int = 5
    let spinDuration: TimeInterval = 2.0
    
    private let repository: MixRepository
    
    @Published var screenState: CrazyHookahScreenState = .wheel
    
    
    @Published private(set) var archivedMixes: [HookahMix] = []
    @Published private(set) var currentSelectedFlavors: [Flavor] = []
    @Published private(set) var currentSpinCount: Int = 0
    @Published var currentWheelRotation: Double = 0.0
    @Published private(set) var lastSpinSector: WheelSector?
    @Published private(set) var currentMix: HookahMix?
    @Published var currentRating: Int = 0
    @Published var currentNote: String = ""
    @Published private(set) var isSpinning: Bool = false
    
    @Published var isArchiveActive: Bool = false
    
    init(repository: MixRepository) {
        self.repository = repository
        
        let flavors = Flavor.allFlavors
        self.allFlavors = flavors
        self.wheelSectors = WheelSector.makeWheelSectors(flavors: flavors)
        
        self.archivedMixes = Self.sortedByDateDescending(repository.loadAll())
    }
    
    convenience init() {
        self.init(repository: UserDefaultsMixRepository())
    }
    
    private static func sortedByDateDescending(_ mixes: [HookahMix]) -> [HookahMix] {
        mixes.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func resetCurrentSessionState() {
        currentSelectedFlavors = []
        currentSpinCount = 0
        currentWheelRotation = 0.0
        lastSpinSector = nil
        currentMix = nil
        currentRating = 0
        currentNote = ""
        isSpinning = false
    }
    
    private func normalizeAngle(_ angle: Double) -> Double {
        (angle.truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360)
    }
    
    func startNewSession() {
        resetCurrentSessionState()
        screenState = .wheel
    }
    
    func openArchive() {
        archivedMixes = Self.sortedByDateDescending(repository.loadAll())
        isArchiveActive = true
    }
    
    func openMixFromArchive(_ mix: HookahMix) {
        currentMix = mix
        currentSelectedFlavors = mix.flavors
        currentSpinCount = min(maxSpins, mix.flavors.count)
        currentRating = mix.rating ?? 0
        currentNote = mix.note ?? ""
        screenState = .result
    }
    
    func spinWheel() {
        guard !isSpinning, currentSpinCount < maxSpins else {
            return
        }
        
        isSpinning = true
        
        let availableSectors = wheelSectors.filter { sector in
            !currentSelectedFlavors.contains(where: { $0.code == sector.flavor.code })
        }
        
        guard let targetSector = availableSectors.randomElement() else {
            isSpinning = false
            return
        }
        
        let sectorsCount = wheelSectors.count
        let sectorAngle = 360.0 / Double(sectorsCount)
        let targetIndex = targetSector.index
        let targetLocalCenterAngle = (Double(targetIndex) - 0.5) * sectorAngle
        
        let currentAngleMod = normalizeAngle(currentWheelRotation)
        let desiredAngleMod = normalizeAngle(-targetLocalCenterAngle)
        
        var delta = desiredAngleMod - currentAngleMod
        if delta < 0 {
            delta += 360.0
        }
        
        let fullRotations = Double(Int.random(in: 3...6)) * 360.0
        let finalRotation = currentWheelRotation + fullRotations + delta
        
        withAnimation(.easeOut(duration: spinDuration)) {
            self.currentWheelRotation = finalRotation
        }
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(spinDuration * 1_000_000_000))
            finishSpin(with: targetSector)
        }
    }
    
    private func finishSpin(with sector: WheelSector) {
        guard isSpinning else { return }
        
        lastSpinSector = sector
        currentSelectedFlavors.append(sector.flavor)
        currentSpinCount += 1
        isSpinning = false
        
        if currentSpinCount >= maxSpins {
            generateMixIfPossible()
        }
    }
    
    func addFlavorManually(_ flavor: Flavor) {
        guard !isSpinning, currentSpinCount < maxSpins else {
            return
        }
        
        currentSelectedFlavors.append(flavor)
        currentSpinCount += 1
        
        if currentSpinCount >= maxSpins {
            generateMixIfPossible()
        }
    }
    
    func cancelCurrentMixAndReturnToWheel() {
        resetCurrentSessionState()
        screenState = .wheel
    }
    
    func userRequestedMixGeneration() {
        generateMixIfPossible()
    }
    
    func goToRatingScreen() {
        guard let mix = currentMix else { return }
        currentRating = mix.rating ?? 0
        currentNote = mix.note ?? ""
        screenState = .rating
    }
    
    func saveCurrentMixToArchive() {
        guard var mix = currentMix else { return }
        
        let clampedRating: Int
        if currentRating < 1 {
            clampedRating = 1
        } else if currentRating > 5 {
            clampedRating = 5
        } else {
            clampedRating = currentRating
        }
        
        mix.rating = clampedRating
        mix.note = currentNote.isEmpty ? nil : currentNote
        
        repository.save(mix)
        archivedMixes = Self.sortedByDateDescending(repository.loadAll())
        
        resetCurrentSessionState()
        
        isArchiveActive = true
    }
    
    func deleteMixFromArchive(_ mix: HookahMix) {
        repository.delete(mix)
        archivedMixes = Self.sortedByDateDescending(repository.loadAll())
    }
    
    private func generateMixIfPossible() {
        guard !currentSelectedFlavors.isEmpty else { return }
        
        let mix = HookahMix(flavors: currentSelectedFlavors)
        currentMix = mix
        currentRating = mix.rating ?? 0
        currentNote = mix.note ?? ""
        screenState = .result
    }
}
