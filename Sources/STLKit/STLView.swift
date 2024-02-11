import RealityKit
import SwiftUI

/// An incredibly simple view to test that we can load STL visually
struct STLView: View {
    let stlAtURL: URL
    var scale = SIMD3<Float>(1.0, 1.0, 1.0)
    var body: some View {
        RealityView { content in
            if let model = try? await STL.load(contentsOf: stlAtURL, withUnits: .millimeters, materials: [SimpleMaterial(color: .darkGray, isMetallic: false)]) {
                model.scale = self.scale
                content.add(model)
            }
        }
    }
}

#Preview("A Sphere Text") {
    STLView(stlAtURL: Bundle.module.url(forResource: "300_polygon_sphere_100mm", withExtension: "STL")!, scale: SIMD3<Float>(0.5, 0.5, 0.5))
}

#Preview("A Sphere Binary") {
    STLView(stlAtURL: Bundle.module.url(forResource: "300_polygon_sphere_100mm.bin", withExtension: "STL")!, scale: SIMD3<Float>(0.5, 0.5, 0.5))
}
