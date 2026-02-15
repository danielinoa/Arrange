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
