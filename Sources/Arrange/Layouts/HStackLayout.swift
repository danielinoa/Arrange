//
//  Created by Daniel Inoa on 12/30/23.
//

/// A layout that arranges its items along the horizontal axis.
public struct HStackLayout: Sendable, Layout {

  private typealias Priority = Int
  private typealias SizedItem = (size: Size, item: any LayoutItem)
  private typealias IndexedItem = (index: Int, item: any LayoutItem)

  /// The horizontal distance between adjacent items within the stack.
  public var spacing: Double

  public var alignment: VerticalAlignment

  public init(alignment: VerticalAlignment = .center, spacing: Double = .zero) {
    self.alignment = alignment
    self.spacing = spacing
  }

  public func naturalSize(for items: [any LayoutItem]) -> Size {
    let totalInteritemSpacing = totalInteritemSpacing(for: items)
    let itemsWidth = items.map(\.intrinsicSize.width).reduce(.zero, +)
    let totalWidth = itemsWidth + totalInteritemSpacing
    let maxHeight = items.map(\.intrinsicSize.height).max() ?? .zero
    return .init(width: totalWidth, height: maxHeight)
  }

  public func size(fitting items: [any LayoutItem], within size: Size) -> Size {
    let totalInteritemSpacing = totalInteritemSpacing(for: items)
    let sizes = sizes(for: items, within: size).map(\.size)
    let width = totalInteritemSpacing + sizes.map(\.width).reduce(.zero, +)
    let height = sizes.map(\.height).max() ?? .zero
    return .init(width: width, height: height)
  }

  public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    var leadingOffset = bounds.leadingX
    let itemSizePairs = sizes(for: items, within: bounds.size)
    let frames = itemSizePairs.map { pair in
      let x = leadingOffset
      let y = Self.topOffset(for: pair.size, aligned: alignment, within: bounds)
      let frame = Rectangle(x: x, y: y, size: pair.size)
      leadingOffset += pair.size.width + spacing
      return frame
    }
    return frames
  }

  /// Returns the array of items with their corresponding ideal size, in the same order they were passed in.
  /// - note: The size of any particular item is dependent on the specified bounding size and the item's own layout
  /// priority relative to its neighboring items.
  private func sizes(for items: [any LayoutItem], within size: Size) -> [SizedItem] {
    let pairs: [IndexedItem] = items.enumerated().map { ($0, $1) }
    var availableWidth = size.width - totalInteritemSpacing(for: items)
    var sizeTable: [Int: SizedItem] = [:]
    let priorityGroups: [Priority: [IndexedItem]] = Dictionary(grouping: pairs, by: \.item.priority)
    for index in priorityGroups.keys.sorted(by: >) {
      let group = priorityGroups[index]!
      let availableSize = Size(width: availableWidth, height: size.height)
      let (groupSizeTable, remainingWidth) = fittingSizes(for: group, within: availableSize)
      sizeTable.merge(groupSizeTable) { current, new in current }  // No duplicate values are expected.
      availableWidth = remainingWidth
    }
    return
      sizeTable
      .sorted { $0.key < $1.key }  // ensures that items are in the order they were received.
      .map { ($0.value.size, $0.value.item) }
  }

  private func fittingSizes(
    for pairs: [IndexedItem], within size: Size
  ) -> (sizeTable: [Priority: SizedItem], remainingWidth: Double) {
    var sizeTable: [Priority: SizedItem] = .init()

    // The space that remains as items occupy the proposed size.
    var sharedAvailableWidth = size.width

    // FIXME: Elasticity instead of scalability!

    // Scalability in this context refers to the ability of an item to be resized over a larger range of values.
    let group: [(index: Int, item: any LayoutItem, scalability: Double)] = pairs.map {
      index, item in
      let shrunkProbingSize = Size(width: .zero, height: size.height)
      let expandedProbingSize = size
      let minimumWidth = item.sizeThatFits(shrunkProbingSize).width
      let maximumWidth = item.sizeThatFits(expandedProbingSize).width
      let scalability = maximumWidth - minimumWidth
      return (index, item, scalability)
    }

    // Least scalable item first.
    var scaleAscendingGroups = group.sorted { $0.scalability < $1.scalability }

    // When calculating sizes all views start with an equal amount space within the "shared available space".
    // Any remaining space unused by a view is then returned to the "shared available space" for other views to use.
    // In order to ensure no space is wasted in the aforementioned step, the algorithm starts with the least
    // scalable item and works itself towards the more scalable item.
    while !scaleAscendingGroups.isEmpty {
      // An equal amount of space for views yet to be added to the size-table.
      let equalAllotmentWidth = sharedAvailableWidth / Double(scaleAscendingGroups.count)
      let group = scaleAscendingGroups.removeFirst()
      let sizeProposal = Size(width: equalAllotmentWidth, height: size.height)
      let fittingSize = group.item.sizeThatFits(sizeProposal)
      sizeTable[group.index] = (fittingSize, group.item)
      sharedAvailableWidth = max(sharedAvailableWidth - fittingSize.width, .zero)
    }
    return (sizeTable, sharedAvailableWidth)
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

  private func totalInteritemSpacing(for items: [any LayoutItem]) -> Double {
    !items.isEmpty ? spacing * Double(items.count - 1) : .zero
  }
}
