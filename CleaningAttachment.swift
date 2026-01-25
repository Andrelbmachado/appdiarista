import SwiftUI
import UIKit

struct CleaningAttachment: Identifiable, Equatable {
    let id = UUID()
    var imageData: Data
    var description: String
    
    var image: Image? {
        guard let uiImage = UIImage(data: imageData) else { return nil }
        return Image(uiImage: uiImage)
    }
}
