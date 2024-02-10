
/// The different ways loading STL can go wrong.
public enum STLError: Error {
    /// Check your URL for a typo!
    case urlNotFound
    /// Whatever this is, it is not STL
    case invalidSTLFormat(_ invalidLine: String)
}
