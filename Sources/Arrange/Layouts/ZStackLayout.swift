//
//  Created by Daniel Inoa on 1/27/24.
//

// TODO: Add tests

/// A layout that overlays its items, aligning them in both axes.
public struct ZStackLayout: Sendable, Layout {

  public var alignment: Alignment

  public init(alignment: Alignment = .center) {
    self.alignment = alignment
  }

  public func naturalSize(for items: [LayoutItem]) -> Size {
    let maxWidth = items.map(\.intrinsicSize.width).max() ?? .zero
    let maxHeight = items.map(\.intrinsicSize.height).max() ?? .zero
    return .init(width: maxWidth, height: maxHeight)
  }

  public func size(fitting items: [LayoutItem], within proposal: SizeProposal) -> Size {
    let fittingSizes = items.map { $0.sizeThatFits(proposal) }
    let maxWidth = fittingSizes.map(\.width).max() ?? .zero
    let maxHeight = fittingSizes.map(\.height).max() ?? .zero
    return .init(width: maxWidth, height: maxHeight)
  }

  public func frames(for items: [LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    let frames = items.map { item in
      var frame = Rectangle.zero
      frame.size = item.sizeThatFits(.size(bounds.size))
      switch alignment {
      case .topLeading:
        frame.leadingX = bounds.leadingX
        frame.topY = bounds.topY
      case .top:
        frame.centerX = bounds.centerX
        frame.topY = bounds.topY
      case .topTrailing:
        frame.trailingX = bounds.trailingX
        frame.topY = bounds.topY
      case .leading:
        frame.leadingX = bounds.leadingX
        frame.centerY = bounds.centerY
      case .center:
        frame.centerX = bounds.centerX
        frame.centerY = bounds.centerY
      case .trailing:
        frame.trailingX = bounds.trailingX
        frame.centerY = bounds.centerY
      case .bottomLeading:
        frame.leadingX = bounds.leadingX
        frame.bottomY = bounds.bottomY
      case .bottom:
        frame.centerX = bounds.centerX
        frame.bottomY = bounds.bottomY
      case .bottomTrailing:
        frame.trailingX = bounds.trailingX
        frame.bottomY = bounds.bottomY
      default:
        frame.centerX = bounds.centerX
        frame.centerY = bounds.centerY
      }
      return frame
    }
    return frames
  }
}
