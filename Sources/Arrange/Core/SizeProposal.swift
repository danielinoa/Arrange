//
//  Created by Daniel Inoa on 2/15/26.
//

/// A size proposal along both axes, used by layouts to communicate sizing intent to their children.
///
/// `SizeProposal` replaces raw `Size` in layout negotiation methods, allowing layouts and items
/// to distinguish between "here is a concrete size", "what is your minimum?", "what is your maximum?",
/// and "what is your ideal size?" — mirroring the semantics of SwiftUI's `ProposedViewSize`.
public struct SizeProposal: Sendable, Hashable {

  public var width: DimensionProposal
  public var height: DimensionProposal

  public init(width: DimensionProposal, height: DimensionProposal) {
    self.width = width
    self.height = height
  }

  public init(width: Double, height: Double) {
    self.width = .fixed(width)
    self.height = .fixed(height)
  }
}

extension SizeProposal {

  /// Both axes collapsed (zero). Requests minimum size.
  public static let collapsed = SizeProposal(width: .collapsed, height: .collapsed)

  /// Both axes expanded (infinity). Requests maximum size.
  public static let expanded = SizeProposal(width: .expanded, height: .expanded)

  /// Both axes unspecified. Requests ideal size.
  public static let unspecified = SizeProposal(width: .unspecified, height: .unspecified)

  /// Creates a proposal from a concrete `Size`.
  public static func size(_ size: Size) -> SizeProposal {
    .init(width: .fixed(size.width), height: .fixed(size.height))
  }

  /// Creates a proposal from concrete width and height values.
  public static func size(width: Double, height: Double) -> SizeProposal {
    .init(width: .fixed(width), height: .fixed(height))
  }
}
