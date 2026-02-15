//
//  Created by Daniel Inoa on 2/6/24.
//

/// A layout that computes the frames of items within a containing bound where items are arranged horizontally and
/// wrapped vertically.
public struct FlowLayout: Sendable {

  /// Implementation Notes
  /// --------------------
  /// This layout works by first grouping subviews into rows based on the proposed container width,
  /// subviews' intrinsic size, and spacing values.
  /// Subviews, once grouped into rows, can be vertically and horizontally aligned within their row.

  /// The direction items flow within a row.
  public var direction: Direction

  /// The horizontal alignment of items within a row.
  public var horizontalAlignment: HorizontalAlignment

  /// The vertical alignment of items within a row.
  public var verticalAlignment: VerticalAlignment

  /// The horizontal distance between adjacent items within a row.
  public var horizontalSpacing: Double

  /// The vertical distance between adjacent rows.
  public var verticalSpacing: Double

  // MARK: - Lifecycle

  public init(
    direction: Direction = .forward,
    horizontalAlignment: HorizontalAlignment = .leading,
    verticalAlignment: VerticalAlignment = .top,
    horizontalSpacing: Double = .zero,
    verticalSpacing: Double = .zero
  ) {
    self.direction = direction
    self.horizontalAlignment = horizontalAlignment
    self.verticalAlignment = verticalAlignment
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
  }

  // MARK: - Layout Calculation

  /// Returns the positions of the items within the specified bounds,
  /// and the height require to fit all items within the bounds.
  public func layout(of items: [Rectangle], in bounds: Rectangle) -> Result {
    let (rows, fittingHeight) = rows(
      from: items, in: bounds, horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing
    )
    var _frames: [Rectangle] = []
    for row in rows {
      let rowFrames: [Rectangle] = frames(for: row, in: bounds)
      _frames.append(contentsOf: rowFrames)
    }
    return .init(fittingHeight: fittingHeight, frames: _frames)
  }

  private func frames(for row: Row, in bounds: Rectangle) -> [Rectangle] {
    // Implementation (when direction is .reverse):
    // A-B-C items will be reversed to C-B-A, positions will be calculated based on the items' size,
    // and resulting positions will be reversed so that they match the corresponding items from original array.
    let items: [Rectangle] = direction == .forward ? row.items : row.items.reversed()
    var frames: [Rectangle] = []
    var leadingOffset: Double = initialLeadingOffset(
      for: row, in: bounds, alignment: horizontalAlignment, horizontalSpacing: horizontalSpacing
    )
    for item in items {
      let topOffset = topOffset(for: item, aligned: verticalAlignment, within: row)
      frames.append(
        Rectangle(x: leadingOffset, y: topOffset, size: item.size)
      )
      leadingOffset += item.width + horizontalSpacing
    }
    if direction == .reverse {
      // Reverse once again so the positions' array-index match with the corresponding forwarded items.
      frames.reverse()
    }
    return frames
  }

  // MARK: - Row Grouping

  /// This function groups items into rows based on the available width defined by the bounds
  /// and the specified spacing.
  private func rows(
    from items: [Rectangle], in bounds: Rectangle, horizontalSpacing: Double,
    verticalSpacing: Double
  ) -> (rows: [Row], fittingHeight: Double) {
    var items = items
    var rows: [Row] = []
    while !items.isEmpty {
      let topOffset = rows.last.map { $0.topOffset + $0.height + verticalSpacing } ?? bounds.topY
      var row = Row(topOffset: topOffset)
      var isOverflown = false
      var leadingOffset = bounds.leadingX
      while !isOverflown && !items.isEmpty {
        let item = items.removeFirst()
        row.items.append(item)
        row.totalItemsWidth += item.width
        row.height = max(row.height, item.height)
        let nextItem = items.first
        leadingOffset += item.width + horizontalSpacing
        isOverflown = nextItem.map { (leadingOffset + $0.width) > bounds.trailingX } ?? false
      }
      rows.append(row)
    }
    let verticalGapsCount = rows.count > 1 ? rows.count - 1 : .zero
    let fittingHeight =
      rows.map(\.height).reduce(.zero, +) + (Double(verticalGapsCount) * verticalSpacing)
    return (rows, fittingHeight)
  }

  // MARK: - In-Row Vertical Positioning

  private func topOffset(for item: Rectangle, aligned: VerticalAlignment, within row: Row) -> Double
  {
    let shift: Double
    switch aligned {
    case .top: shift = .zero
    case .center: shift = (row.height - item.height) / 2
    case .bottom: shift = row.height - item.height
    }
    return row.topOffset + shift
  }

  // MARK: - In-Row Horizontal Positioning

  /// Returns the leading offset the row's first item can be placed in.
  private func initialLeadingOffset(
    for row: Row, in bounds: Rectangle, alignment: HorizontalAlignment, horizontalSpacing: Double
  ) -> Double {
    let gaps: Int = row.items.count == 1 ? .zero : row.items.count - 1
    let gapsWidth = Double(gaps) * horizontalSpacing
    let remainingSpace = bounds.width - (row.totalItemsWidth + gapsWidth)
    let shift: Double
    switch alignment {
    case .leading: shift = .zero
    case .center: shift = remainingSpace / 2
    case .trailing: shift = remainingSpace
    }
    return bounds.leadingX + shift
  }

  // MARK: - Types

  public struct Result: Sendable {

    /// The height require to fit all items, based on the width of the bounds originally passed in.
    public let fittingHeight: Double

    /// The items' frame within fitting height and the bounds' width.
    public let frames: [Rectangle]
  }

  /// The direction items flow within a row.
  public enum Direction: Sendable {

    /// In this direction items flow from left to right.
    case forward

    /// In this direction items flow from right to left.
    case reverse
  }

  private struct Row {

    var items: [Rectangle] = []

    /// The offset from the container-bounds' min-y (not necessarily zero).
    var topOffset: Double = .zero

    /// The height of the row, based on the tallest item within the row.
    var height: Double = .zero

    /// The sum of all the items' widths. This does not include any interim spacing.
    var totalItemsWidth: Double = .zero
  }
}

extension FlowLayout: Layout {

  public func naturalSize(for items: [LayoutItem]) -> Size {
    HStackLayout
      .init(alignment: verticalAlignment, spacing: horizontalSpacing)
      .naturalSize(for: items)
  }

  public func size(fitting items: [LayoutItem], within proposal: Size) -> Size {
    let rects = items.map { Rectangle(origin: .zero, size: $0.intrinsicSize) }
    let layout = layout(of: rects, in: .init(origin: .zero, size: proposal))
    return .init(width: proposal.width, height: layout.fittingHeight)
  }

  public func frames(for items: [LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    let rects = items.map { Rectangle(origin: .zero, size: $0.intrinsicSize) }
    return layout(of: rects, in: bounds).frames
  }
}
