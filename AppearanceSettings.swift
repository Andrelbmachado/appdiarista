import SwiftUI
import Combine

final class AppearanceSettings: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case system = "Automático"
        case light = "Claro"
        case dark = "Escuro"
        
        var id: String { rawValue }
        var scheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    @Published var mode: Mode = .system
    @Published var dynamicType: DynamicTypeSize = .large
    
    var colorScheme: ColorScheme? { mode.scheme }
}
