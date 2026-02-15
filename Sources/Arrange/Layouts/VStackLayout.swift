//
//  Created by Daniel Inoa on 1/4/24.
//

/// A layout that arranges its items along the vertical axis.
public struct VStackLayout: Sendable, Layout {

  private typealias Priority = Int
  private typealias SizedItem = (size: Size, item: any LayoutItem)
  private typealias IndexedItem = (index: Int, item: any LayoutItem)

  /// The vertical distance between adjacent items within the stack.
  public var spacing: Double

  public var alignment: HorizontalAlignment

  public init(alignment: HorizontalAlignment = .center, spacing: Double = .zero) {
    self.alignment = alignment
    self.spacing = spacing
  }

  public func naturalSize(for items: [any LayoutItem]) -> Size {
    let totalInteritemSpacing = totalInteritemSpacing(for: items)
    let itemsHeight = items.map(\.intrinsicSize.height).reduce(.zero, +)
    let totalHeight = itemsHeight + totalInteritemSpacing
    let maxWidth = items.map(\.intrinsicSize.width).max() ?? .zero
    return .init(width: maxWidth, height: totalHeight)
  }

  public func size(fitting items: [any LayoutItem], within size: Size) -> Size {
    let totalInteritemSpacing = totalInteritemSpacing(for: items)
    let sizes = sizes(for: items, within: size).map(\.size)
    let width = sizes.map(\.width).max() ?? .zero
    let height = totalInteritemSpacing + sizes.map(\.height).reduce(.zero, +)
    return .init(width: width, height: height)
  }

  public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    var topOffset = bounds.topY
    let itemSizePairs = sizes(for: items, within: bounds.size)
    let frames = itemSizePairs.map { pair in
      let x = Self.leadingOffset(for: pair.size, aligned: alignment, within: bounds)
      let y = topOffset
      let frame = Rectangle(x: x, y: y, size: pair.size)
      topOffset += pair.size.height + spacing
      return frame
    }
    return frames
  }

  /// Returns the array of items with their corresponding ideal size, in the same order they were passed in.
  /// - note: The size of any particular item is dependent on the specified bounding size and the item's own layout
  /// priority relative to its neighboring items.
  private func sizes(for items: [any LayoutItem], within size: Size) -> [SizedItem] {
    let pairs: [IndexedItem] = items.enumerated().map { ($0, $1) }
    var availableHeight = size.height - totalInteritemSpacing(for: items)
    var sizeTable: [Int: SizedItem] = [:]
    let priorityGroups: [Priority: [VStackLayout.IndexedItem]] = Dictionary(
      grouping: pairs, by: \.item.priority)
    for index in priorityGroups.keys.sorted(by: >) {
      let group = priorityGroups[index]!
      let availableSize = Size(width: size.width, height: availableHeight)
      let (groupSizeTable, remainingHeight) = fittingSizes(for: group, within: availableSize)
      sizeTable.merge(groupSizeTable) { current, new in current }  // No duplicate values are expected.
      availableHeight = remainingHeight
    }
    return
      sizeTable
      .sorted { $0.key < $1.key }  // ensures that items are in the order they were received.
      .map { ($0.value.size, $0.value.item) }
  }

  private func fittingSizes(
    for pairs: [IndexedItem], within size: Size
  ) -> (sizeTable: [Priority: SizedItem], remainingHeight: Double) {
    var sizeTable: [Priority: SizedItem] = .init()

    // The space that remains as items occupy the proposed size.
    var sharedAvailableHeight = size.height

    // Scalability in this context refers to the ability of an item to be resized over a larger range of values.
    let group: [(index: Int, item: any LayoutItem, scalability: Double)] = pairs.map {
      index, item in
      let shrunkProbingSize = Size(width: size.width, height: .zero)
      let expandedProbingSize = size
      let minimumHeight = item.sizeThatFits(shrunkProbingSize).height
      let maximumHeight = item.sizeThatFits(expandedProbingSize).height
      let scalability = maximumHeight - minimumHeight
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
      let equalAllotmentHeight = sharedAvailableHeight / Double(scaleAscendingGroups.count)
      let group = scaleAscendingGroups.removeFirst()
      let sizeProposal = Size(width: size.width, height: equalAllotmentHeight)
      let fittingSize = group.item.sizeThatFits(sizeProposal)
      sizeTable[group.index] = (fittingSize, group.item)
      sharedAvailableHeight = max(sharedAvailableHeight - fittingSize.height, .zero)
    }
    return (sizeTable, sharedAvailableHeight)
  }

  private static func leadingOffset(
    for size: Size, aligned: HorizontalAlignment, within bounds: Rectangle
  ) -> Double {
    let shift: Double
    switch aligned {
    case .leading: shift = .zero
    case .center: shift = (bounds.width - size.width) / 2
    case .trailing: shift = bounds.width - size.width
    }
    return bounds.leadingX + shift
  }

  private func totalInteritemSpacing(for items: [any LayoutItem]) -> Double {
    !items.isEmpty ? spacing * Double(items.count - 1) : .zero
  }
}
