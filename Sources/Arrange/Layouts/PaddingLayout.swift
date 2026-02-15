//
//  Created by Daniel Inoa on 1/28/24.
//

// TODO: Add tests

public struct PaddingLayout: Sendable, Layout {

  public var insets: EdgeInsets = .zero

  public init(insets: EdgeInsets) {
    self.insets = insets
  }

  private let layout: ZStackLayout = .init(alignment: .topLeading)

  // MARK: - Layout

  public func naturalSize(for items: [LayoutItem]) -> Size {
    let size = layout.naturalSize(for: items)
    return .init(
      width: size.width + insets.left + insets.right,
      height: size.height + insets.top + insets.bottom
    )
  }

  public func size(fitting items: [LayoutItem], within proposal: SizeProposal) -> Size {
    let natural = naturalSize(for: items)
    let width: Double = switch proposal.width {
    case .fixed(let value): value
    case .collapsed: .zero
    case .expanded: .infinity
    case .unspecified: natural.width
    }
    let height: Double = switch proposal.height {
    case .fixed(let value): value
    case .collapsed: .zero
    case .expanded: .infinity
    case .unspecified: natural.height
    }
    let proposedSize = Size(width: width, height: height)
    let insettedSize = Size(
      width: proposedSize.width - insets.left - insets.right,
      height: proposedSize.height - insets.top - insets.bottom
    )
    let fittingSize = layout.size(fitting: items, within: .size(insettedSize))
    let size = Size(
      width: fittingSize.width + insets.left + insets.right,
      height: fittingSize.height + insets.top + insets.bottom
    )
    return size
  }

  public func frames(for items: [LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    let insettedBoundsSize = Size(
      width: bounds.width - insets.left - insets.right,
      height: bounds.height - insets.top - insets.bottom
    )
    let frames = layout.frames(
      for: items,
      within: Rectangle(
        origin: .init(x: bounds.origin.x + insets.left, y: bounds.origin.y + insets.top),
        size: insettedBoundsSize
      )
    )
    return frames
  }
}
