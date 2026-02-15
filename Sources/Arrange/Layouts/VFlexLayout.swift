//
//  Created by Daniel Inoa on 2/25/24.
//

// TODO: Add documentation.
// TODO: Add gap-spacing for all distributions.
// TODO: Add tests.

public struct VFlexLayout: Layout {

  public var distribution: Distribution
  public var alignment: HorizontalAlignment

  public init(
    distribution: Distribution = .center(spacing: .zero), alignment: HorizontalAlignment = .center
  ) {
    self.alignment = alignment
    self.distribution = distribution
  }

  public func naturalSize(for items: [LayoutItem]) -> Size {
    let spacing: Double =
      switch distribution {
      case .top(let spacing), .center(let spacing), .bottom(let spacing): spacing
      case .spaceBetween, .spaceAround, .spaceEvenly: .zero
      }
    let totalInteritemSpacing: Double = !items.isEmpty ? Double(items.count - 1) * spacing : .zero

    let itemsHeight = items.map(\.intrinsicSize.height).reduce(.zero, +)
    let totalHeight = itemsHeight + totalInteritemSpacing
    let maxWidth = items.map(\.intrinsicSize.width).max() ?? .zero
    return .init(width: maxWidth, height: totalHeight)
  }

  public func size(fitting items: [LayoutItem], within proposal: Size) -> Size {
    let fittingWidth = items.map { $0.sizeThatFits(proposal).width }.max() ?? .zero
    return .init(width: fittingWidth, height: proposal.height)
  }

  public func frames(for items: [LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    switch distribution {
    case .top(let spacing):
      var topOffset = bounds.topY
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = Self.leadingOffset(for: size, aligned: alignment, within: bounds)
        let y = topOffset
        let frame = Rectangle(x: x, y: y, size: size)
        topOffset += size.height + spacing
        return frame
      }
      return frames
    case .center(let spacing):
      let intrinsicHeight = naturalSize(for: items).height
      let remainingHeight = bounds.height - intrinsicHeight
      var topOffset = bounds.topY + (remainingHeight / 2)
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = Self.leadingOffset(for: size, aligned: alignment, within: bounds)
        let y = topOffset
        let frame = Rectangle(x: x, y: y, size: size)
        topOffset += size.height + spacing
        return frame
      }
      return frames
    case .bottom(let spacing):
      let intrinsicHeight = naturalSize(for: items).height
      let remainingHeight = bounds.height - intrinsicHeight
      var topOffset = bounds.topY + remainingHeight
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = Self.leadingOffset(for: size, aligned: alignment, within: bounds)
        let y = topOffset
        let frame = Rectangle(x: x, y: y, size: size)
        topOffset += size.height + spacing
        return frame
      }
      return frames
    case .spaceBetween:
      let itemsHeight = items.map(\.intrinsicSize.height).reduce(.zero, +)
      let remainingSpace = bounds.height - itemsHeight
      let interitemSpacing =
        items.count == 1 ? remainingSpace : remainingSpace / Double(items.count - 1)
      var topOffset = bounds.topY
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = Self.leadingOffset(for: size, aligned: alignment, within: bounds)
        let y = topOffset
        let frame = Rectangle(x: x, y: y, size: size)
        topOffset += size.height + interitemSpacing
        return frame
      }
      return frames
    case .spaceAround:
      let itemsHeight = items.map(\.intrinsicSize.height).reduce(.zero, +)
      let remainingSpace = bounds.height - itemsHeight
      let interitemPadding =
        items.isEmpty ? remainingSpace : remainingSpace / (2 * Double(items.count))
      var topOffset = bounds.topY
      let frames: [Rectangle] = items.map { item in
        topOffset += interitemPadding
        let size = item.intrinsicSize
        let x = Self.leadingOffset(for: size, aligned: alignment, within: bounds)
        let y = topOffset
        let frame = Rectangle(x: x, y: y, size: size)
        topOffset += size.height + interitemPadding
        return frame
      }
      return frames
    case .spaceEvenly:
      let itemsHeight = items.map(\.intrinsicSize.height).reduce(.zero, +)
      let remainingSpace = bounds.height - itemsHeight
      let interitemSpacing = remainingSpace / Double(items.count + 1)
      var topOffset = bounds.topY + interitemSpacing
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = Self.leadingOffset(for: size, aligned: alignment, within: bounds)
        let y = topOffset
        let frame = Rectangle(x: x, y: y, size: size)
        topOffset += size.height + interitemSpacing
        return frame
      }
      return frames
    }
  }

  private static func leadingOffset(for size: Size, aligned: HorizontalAlignment, within bounds: Rectangle) -> Double {
    let shift: Double = switch aligned {
    case .leading: .zero
    case .center: (bounds.width - size.width) / 2
    case .trailing: bounds.width - size.width
    }
    return bounds.leadingX + shift
  }
}

extension VFlexLayout {

  /// The distribution that defines the position of layout items along the vertical axis.
  public enum Distribution {
    case top(spacing: Double)
    case center(spacing: Double)
    case bottom(spacing: Double)
    case spaceBetween
    case spaceAround
    case spaceEvenly
  }
}
