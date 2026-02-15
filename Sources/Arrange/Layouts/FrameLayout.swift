//
//  Created by Daniel Inoa on 7/1/24.
//

import SwiftPlus

/// A layout that proposes a fixed or constrained size for its children, analogous to SwiftUI's `.frame` modifier.
///
/// `FrameLayout` defines a region with optional minimum and maximum dimensions. Children are laid out
/// within that region using a `ZStackLayout` and the specified `alignment`.
///
/// ## Sizing Semantics
///
/// The behavior intentionally matches SwiftUI's `.frame(minWidth:maxWidth:minHeight:maxHeight:)`:
///
/// - **Both min and max set** (`width: N` or `minimumWidth: A, maximumWidth: B`):
///   The child's size is clamped to the `min...max` range, then clamped to the parent's bounds.
///
/// - **`minimumWidth` only** (no max):
///   The frame expands to at least `minimumWidth`, even if it exceeds the parent's bounds.
///   This mirrors SwiftUI where `minWidth` is a hard floor that the layout honors unconditionally.
///
/// - **`maximumWidth` only** (no min):
///   The frame is exactly `maximumWidth` (clamped to bounds) — it acts as a **target size**,
///   not merely a ceiling on the child. The child floats inside the frame region, positioned
///   by `alignment`. This matches SwiftUI where `.frame(maxWidth: 200)` creates a 200pt-wide
///   frame regardless of the child's natural width.
///
/// - **Neither set**: The child's natural fitting size is used, clamped to bounds.
///
/// The same logic applies symmetrically to height.
public struct FrameLayout: Sendable, Layout {

  // TODO: Add idealWidth and idealHeight along with SizeProposal enum (value, .zero, .unspecified, and .infinity)

  private var layout: ZStackLayout

  public var alignment: Alignment {
    get { layout.alignment }
    set { layout.alignment = newValue }
  }

  public let minimumWidth: Double?
  public let maximumWidth: Double?
  public let minimumHeight: Double?
  public let maximumHeight: Double?

  public init(
    minimumWidth: Double? = nil,
    maximumWidth: Double? = nil,
    minimumHeight: Double? = nil,
    maximumHeight: Double? = nil,
    alignment: Alignment = .center
  ) {
    self.minimumWidth = minimumWidth
    self.maximumWidth = maximumWidth
    self.minimumHeight = minimumHeight
    self.maximumHeight = maximumHeight
    self.layout = .init(alignment: alignment)
  }

  public init(
    width: Double? = nil,
    height: Double? = nil,
    alignment: Alignment = .center
  ) {
    self.minimumWidth = width
    self.maximumWidth = width
    self.minimumHeight = height
    self.maximumHeight = height
    self.layout = .init(alignment: alignment)
  }

  public func naturalSize(for items: [any LayoutItem]) -> Size {
    let childSize = layout.naturalSize(for: items)
    let width: Double =
      if let minimumWidth, let maximumWidth {
        childSize.width.clamped(within: minimumWidth...max(minimumWidth, maximumWidth))
      } else if let minimumWidth {
        max(minimumWidth, childSize.width)
      } else if let maximumWidth {
        min(maximumWidth, childSize.width)
      } else {
        childSize.width
      }
    let height: Double =
      if let minimumHeight, let maximumHeight {
        childSize.height.clamped(within: minimumHeight...max(minimumHeight, maximumHeight))
      } else if let minimumHeight {
        max(minimumHeight, childSize.height)
      } else if let maximumHeight {
        min(maximumHeight, childSize.height)
      } else {
        childSize.height
      }
    return .init(width: width, height: height)
  }

  public func size(fitting items: [any LayoutItem], within bounds: Size) -> Size {
    let minimumWidth = self.minimumWidth == .infinity ? bounds.width : self.minimumWidth
    let maximumWidth = self.maximumWidth == .infinity ? bounds.width : self.maximumWidth
    let minimumHeight = self.minimumHeight == .infinity ? bounds.height : self.minimumHeight
    let maximumHeight = self.maximumHeight == .infinity ? bounds.height : self.maximumHeight

    let childProposalWidth = maximumWidth?.clamped(upTo: bounds.width) ?? bounds.width
    let childProposalHeight = maximumHeight?.clamped(upTo: bounds.height) ?? bounds.height
    let childSize = layout.size(
      fitting: items, within: .init(width: childProposalWidth, height: childProposalHeight)
    )
    let preferredWidth: Double =
      if let minimumWidth, let maximumWidth {
        childSize.width.clamped(within: minimumWidth...max(minimumWidth, maximumWidth)).clamped(upTo: bounds.width)
      } else if let minimumWidth {
        max(minimumWidth, childSize.width)
      } else if let maximumWidth {
        maximumWidth.clamped(upTo: bounds.width)
      } else {
        childSize.width.clamped(upTo: bounds.width)
      }
    let preferredHeight: Double =
      if let minimumHeight, let maximumHeight {
        childSize.height.clamped(within: minimumHeight...max(minimumHeight, maximumHeight)).clamped(upTo: bounds.height)
      } else if let minimumHeight {
        max(minimumHeight, childSize.height)
      } else if let maximumHeight {
        maximumHeight.clamped(upTo: bounds.height)
      } else {
        childSize.height.clamped(upTo: bounds.height)
      }
    return .init(width: preferredWidth, height: preferredHeight)
  }

  public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    let constrainedSize = size(fitting: items, within: bounds.size)
    let constrainedBounds = Rectangle(origin: bounds.origin, size: constrainedSize)
    return layout.frames(for: items, within: constrainedBounds)
  }
}
