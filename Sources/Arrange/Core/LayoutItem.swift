//
//  Created by Daniel Inoa on 1/1/24.
//

/// A type that can participate in layout calculations by reporting its size preferences.
///
/// `LayoutItem` is actor-neutral so pure-value items can participate in layout without inheriting UI isolation.
/// Main-actor-bound UI types can instead conform to `UILayoutItem`, which exposes main-actor-specific
/// requirements and bridges them back to `LayoutItem`.
public protocol LayoutItem {

  var priority: LayoutPriority { get }

  /// The layout item's natural size, considering only properties of the item itself.
  var intrinsicSize: Size { get }

  /// Returns the item's preferred size given a proposal.
  func sizeThatFits(_ proposal: SizeProposal) -> Size
}

extension LayoutItem {
  public var priority: LayoutPriority { .zero }
  public var intrinsicSize: Size { .zero }
}
