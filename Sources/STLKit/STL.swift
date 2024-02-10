import Foundation
import RealityKit

/// Interact with STL files.
public struct STL {
    /// Loads a single STL file from an URL asynconronously.
    public static func load(contentsOf: URL, withUnits: STLUnits = STLUnits.meters) async throws -> ModelEntity {
        throw STLError.urlNotFound
    }
}
