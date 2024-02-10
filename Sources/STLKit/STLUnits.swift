
/// STL files describe geometry in a unit-less abstract fashion, but ``RealityKit``
/// works in meters.
///
/// Units, along with your knowledge about the STL file authoring, allows you to
/// set an initial scaling.
///
public enum STLUnits : Float {
    case millimeters = 0.01
    case centimeters = 0.1
    case meters = 1.0
    case inches = 39.37
    case feet = 3.28
}
