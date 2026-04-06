//
//  Created by Daniel Inoa on 1/4/24.
//

/// A layout that arranges its items along the vertical axis.
public struct VStackLayout: Sendable, Layout {

  private typealias Priority = Int
  private typealias ItemIndex = Int
  private typealias SizedItem = (size: Size, item: any LayoutItem)
  private typealias IndexedItem = (index: ItemIndex, item: any LayoutItem)
  private typealias SizedItemsByIndex = [ItemIndex: SizedItem]

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

  public func size(fitting items: [any LayoutItem], within proposal: SizeProposal) -> Size {
    let totalInteritemSpacing = totalInteritemSpacing(for: items)
    let sizes = sizes(for: items, within: proposal).map(\.size)
    let width = sizes.map(\.width).max() ?? .zero
    let height = totalInteritemSpacing + sizes.map(\.height).reduce(.zero, +)
    return .init(width: width, height: height)
  }

  public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    var topOffset = bounds.topY
    let itemSizePairs = sizes(for: items, within: .size(bounds.size))
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
  /// - note: The height-sharing path only runs when `proposal.height.finiteValue` exists. Otherwise the height
  ///         proposal is treated as unbounded and each child is measured directly with the original proposal.
  /// - note: Negative finite heights are clamped to zero before being used as distributable sibling space.
  private func sizes(for items: [any LayoutItem], within proposal: SizeProposal) -> [SizedItem] {
    guard let availableHeight = proposal.height.finiteValue else {
      return items.map { ($0.sizeThatFits(proposal), $0) }
    }

    let pairs: [IndexedItem] = items.enumerated().map { ($0, $1) }
    var remainingHeight = remainingSpace(
      afterConsuming: totalInteritemSpacing(for: items),
      from: distributableHeight(from: availableHeight)
    )
    var sizeTable: SizedItemsByIndex = [:]
    let priorityGroups: [Priority: [VStackLayout.IndexedItem]] = Dictionary(
      grouping: pairs, by: \.item.priority)
    for priority in priorityGroups.keys.sorted(by: >) {
      let group = priorityGroups[priority]!
      let availableProposal = SizeProposal(width: proposal.width, height: .fixed(remainingHeight))
      let (groupSizeTable, unusedHeight) = fittingSizes(for: group, within: availableProposal)
      sizeTable.merge(groupSizeTable) { current, new in current }  // No duplicate values are expected.
      remainingHeight = unusedHeight
    }
    return
      sizeTable
      .sorted { $0.key < $1.key }  // ensures that items are in the order they were received.
      .map { ($0.value.size, $0.value.item) }
  }

  private func fittingSizes(
    for pairs: [IndexedItem], within proposal: SizeProposal
  ) -> (sizeTable: SizedItemsByIndex, remainingHeight: Double) {
    var sizeTable: SizedItemsByIndex = .init()

    // The amount of height this priority group is allowed to divide among its remaining siblings.
    let availableHeight = distributableHeight(from: proposal.height.finiteValue ?? .zero)
    var sharedAvailableHeight = availableHeight

    // Resizability is the difference between an item's minimum and maximum fitting height.
    let group: [(index: Int, item: any LayoutItem, resizability: Double)] = pairs.map {
      index, item in
      let shrunkProposal = SizeProposal(width: proposal.width, height: .collapsed)
      let expandedProposal = SizeProposal(width: proposal.width, height: .fixed(availableHeight))
      let minimumHeight = item.sizeThatFits(shrunkProposal).height
      let maximumHeight = item.sizeThatFits(expandedProposal).height
      let resizability = maximumHeight - minimumHeight
      return (index, item, resizability)
    }

    // Least resizable item first.
    var resizabilityAscendingGroups = group.sorted {
      if $0.resizability == $1.resizability {
        return $0.index < $1.index
      }
      return $0.resizability < $1.resizability
    }

    // When calculating sizes all views start with an equal amount space within the "shared available space".
    // Any remaining space unused by a view is then returned to the "shared available space" for other views to use.
    // In order to ensure no space is wasted in the aforementioned step, the algorithm starts with the least
    // resizable item and works itself towards the more resizable item.
    while !resizabilityAscendingGroups.isEmpty {
      // An equal amount of space for views yet to be added to the size-table.
      let equalAllotmentHeight = sharedAvailableHeight / Double(resizabilityAscendingGroups.count)
      let group = resizabilityAscendingGroups.removeFirst()
      let itemProposal = SizeProposal(width: proposal.width, height: .fixed(equalAllotmentHeight))
      let fittingSize = group.item.sizeThatFits(itemProposal)
      sizeTable[group.index] = (fittingSize, group.item)
      sharedAvailableHeight = remainingSpace(afterConsuming: fittingSize.height, from: sharedAvailableHeight)
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

  /// Converts a finite proposed height into height that can actually be distributed among siblings.
  ///
  /// Negative fixed heights are treated as zero during stack allocation.
  private func distributableHeight(from finiteHeight: Double) -> Double {
    max(finiteHeight, .zero)
  }

  /// Subtracts consumed height from a finite budget while keeping the result in a safe range.
  ///
  /// This prevents negative remaining space and collapses non-finite consumption to zero remaining height,
  /// which avoids propagating `nan` through later sibling proposals.
  private func remainingSpace(afterConsuming consumed: Double, from available: Double) -> Double {
    guard available.isFinite else { return available }
    guard consumed.isFinite else { return .zero }
    return max(available - max(consumed, .zero), .zero)
  }
}
