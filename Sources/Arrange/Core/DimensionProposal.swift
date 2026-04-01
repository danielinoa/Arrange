//
//  Created by Daniel Inoa on 2/15/26.
//

/// A proposed dimension value along a single axis.
///
/// Layouts use dimension proposals to communicate sizing intent to their children.
/// Unlike a raw `Double`, a `DimensionProposal` distinguishes between concrete values,
/// minimum/maximum probes, and the absence of a constraint.
public enum DimensionProposal: Sendable, Hashable {

  /// A specific fixed dimension.
  case fixed(Double)

  /// Proposes zero space, requesting the item's minimum size.
  case collapsed

  /// Proposes infinite space, requesting the item's maximum size.
  case expanded

  /// No proposal; the item should use its ideal size.
  case unspecified
}

extension DimensionProposal {

  /// A finite scalar value implied by this proposal, when one exists.
  ///
  /// `.collapsed` resolves to `0`. Finite `.fixed(...)` values resolve to their associated value as-is.
  /// `.expanded`, `.unspecified`, and non-finite fixed values have no finite value and return `nil`.
  public var finiteValue: Double? {
    switch self {
      case .collapsed:
        .zero
      case .fixed(let value):
        value.isFinite ? value : nil
      case .expanded, .unspecified:
        nil
    }
  }
}
