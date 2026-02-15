//
//  Created by Daniel Inoa on 1/1/24.
//

/// A type that can participate in layout calculations by reporting its size preferences.
///
/// This protocol is currently `@MainActor` because its primary conformer (`UIView`) is main-actor-isolated.
/// This means all conformers and callers must operate on the main actor—even pure-value types with no UI state.
///
/// ## Alternatives to consider
///
/// - **Remove `@MainActor` from the protocol** and mark `UIView`'s conformance members as `nonisolated`,
///   using `MainActor.assumeIsolated` internally. This keeps the protocol usable off the main actor but shifts
///   the isolation proof from compile-time to runtime at the UIKit boundary.
///
/// - **Split into two protocols** (`LayoutItem` without isolation, `UILayoutItem: LayoutItem` with `@MainActor`).
///   Pure-value types conform to `LayoutItem` directly; `UIView` conforms to `UILayoutItem`. Adds a type but
///   preserves compile-time safety on both sides.
@MainActor
public protocol LayoutItem {

  // TODO: Consider using LayoutPriority to prevent collision with another protocol also requiring a `priority: Int`.
  var priority: Int { get }

  /// The layout item's natural size, considering only properties of the item itself.
  var intrinsicSize: Size { get }

  /// Returns the item's preferred size given a proposal.
  func sizeThatFits(_ proposal: SizeProposal) -> Size
}

extension LayoutItem {
  public var priority: Int { .zero }
  public var intrinsicSize: Size { .zero }
}
