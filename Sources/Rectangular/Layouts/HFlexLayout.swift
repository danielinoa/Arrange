//
//  Created by Daniel Inoa on 2/11/24.
//

// TODO: Add documentation.
// TODO: Add gap-spacing for all distributions.
// TODO: Add tests.

public struct HFlexLayout: Layout {

  public var distribution: Distribution
  public var alignment: VerticalAlignment

  public init(
    distribution: Distribution = .center(spacing: .zero), alignment: VerticalAlignment = .center
  ) {
    self.alignment = alignment
    self.distribution = distribution
  }

  public func naturalSize(for items: [LayoutItem]) -> Size {
    let spacing: Double =
      switch distribution {
      case .leading(let spacing), .center(let spacing), .trailing(let spacing): spacing
      case .spaceBetween, .spaceAround, .spaceEvenly: .zero
      }
    let totalInteritemSpacing: Double = !items.isEmpty ? Double(items.count - 1) * spacing : .zero
    let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
    let totalWidth = itemsWidth + totalInteritemSpacing
    let maxHeight = items.map(\.intrinsicSize.height).max() ?? .zero
    return .init(width: totalWidth, height: maxHeight)
  }

  public func size(fitting items: [LayoutItem], within proposal: Size) -> Size {
    let fittingHeight = items.map { $0.sizeThatFits(proposal).height }.max() ?? .zero
    return .init(width: proposal.width, height: fittingHeight)
  }

  public func frames(for items: [LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    switch distribution {
    case .leading(let spacing):
      var leadingOffset = bounds.leadingX
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = leadingOffset
        let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
        let frame = Rectangle(x: x, y: y, size: size)
        leadingOffset += size.width + spacing
        return frame
      }
      return frames
    case .center(let spacing):
      let intrinsicWidth = naturalSize(for: items).width
      let remainingWidth = bounds.width - intrinsicWidth
      var leadingOffset = bounds.leadingX + (remainingWidth / 2)
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = leadingOffset
        let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
        let frame = Rectangle(x: x, y: y, size: size)
        leadingOffset += size.width + spacing
        return frame
      }
      return frames
    case .trailing(let spacing):
      let intrinsicWidth = naturalSize(for: items).width
      let remainingWidth = bounds.width - intrinsicWidth
      var leadingOffset = bounds.leadingX + remainingWidth
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = leadingOffset
        let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
        let frame = Rectangle(x: x, y: y, size: size)
        leadingOffset += size.width + spacing
        return frame
      }
      return frames
    case .spaceBetween:
      let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
      let remainingSpace = bounds.width - itemsWidth
      let interitemSpacing =
        items.count == 1 ? remainingSpace : remainingSpace / Double(items.count - 1)
      var leadingOffset = bounds.leadingX
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = leadingOffset
        let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
        let frame = Rectangle(x: x, y: y, size: size)
        leadingOffset += size.width + interitemSpacing
        return frame
      }
      return frames
    case .spaceAround:
      let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
      let remainingSpace = bounds.width - itemsWidth
      let interitemPadding =
        items.isEmpty ? remainingSpace : remainingSpace / (2 * Double(items.count))
      var leadingOffset = bounds.leadingX
      let frames: [Rectangle] = items.map { item in
        leadingOffset += interitemPadding
        let size = item.intrinsicSize
        let x = leadingOffset
        let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
        let frame = Rectangle(x: x, y: y, size: size)
        leadingOffset += size.width + interitemPadding
        return frame
      }
      return frames
    case .spaceEvenly:
      let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
      let remainingSpace = bounds.width - itemsWidth
      let interitemSpacing = remainingSpace / Double(items.count + 1)
      var leadingOffset = bounds.leadingX + interitemSpacing
      let frames: [Rectangle] = items.map { item in
        let size = item.intrinsicSize
        let x = leadingOffset
        let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
        let frame = Rectangle(x: x, y: y, size: size)
        leadingOffset += size.width + interitemSpacing
        return frame
      }
      return frames
    }
  }

  private static func topOffset(
    for size: Size, aligned: VerticalAlignment, within bounds: Rectangle
  ) -> Double {
    let shift: Double
    switch aligned {
    case .top: shift = .zero
    case .center: shift = (bounds.height - size.height) / 2
    case .bottom: shift = bounds.height - size.height
    }
    return bounds.topY + shift
  }
}

extension HFlexLayout {

  /// The distribution that defines the position of layout items along the horizontal axis.
  public enum Distribution {
    case leading(spacing: Double)
    case center(spacing: Double)
    case trailing(spacing: Double)
    case spaceBetween
    case spaceAround
    case spaceEvenly
  }
}
