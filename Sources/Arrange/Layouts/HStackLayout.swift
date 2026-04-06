//
//  Created by Daniel Inoa on 12/30/23.
//

/// A layout that arranges its items along the horizontal axis.
public struct HStackLayout: Sendable, Layout {

  private typealias Priority = Int
  private typealias ItemIndex = Int
  private typealias SizedItem = (size: Size, item: any LayoutItem)
  private typealias IndexedItem = (index: ItemIndex, item: any LayoutItem)
  private typealias SizedItemsByIndex = [ItemIndex: SizedItem]

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

  public func size(fitting items: [any LayoutItem], within proposal: SizeProposal) -> Size {
    let totalInteritemSpacing = totalInteritemSpacing(for: items)
    let sizes = sizes(for: items, within: proposal).map(\.size)
    let width = totalInteritemSpacing + sizes.map(\.width).reduce(.zero, +)
    let height = sizes.map(\.height).max() ?? .zero
    return .init(width: width, height: height)
  }

  public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    var leadingOffset = bounds.leadingX
    let itemSizePairs = sizes(for: items, within: .size(bounds.size))
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
  /// - note: The width-sharing path only runs when `proposal.width.finiteValue` exists. Otherwise the width proposal
  ///         is treated as unbounded and each child is measured directly with the original proposal.
  /// - note: Negative finite widths are clamped to zero before being used as distributable sibling space.
  private func sizes(for items: [any LayoutItem], within proposal: SizeProposal) -> [SizedItem] {
    guard let availableWidth = proposal.width.finiteValue else {
      return items.map { ($0.sizeThatFits(proposal), $0) }
    }

    let pairs: [IndexedItem] = items.enumerated().map { ($0, $1) }
    var remainingWidth = remainingSpace(
      afterConsuming: totalInteritemSpacing(for: items),
      from: distributableWidth(from: availableWidth)
    )
    var sizeTable: SizedItemsByIndex = [:]
    let priorityGroups: [Priority: [IndexedItem]] = Dictionary(grouping: pairs, by: \.item.priority)
    for priority in priorityGroups.keys.sorted(by: >) {
      let group = priorityGroups[priority]!
      let availableProposal = SizeProposal(width: .fixed(remainingWidth), height: proposal.height)
      let (groupSizeTable, unusedWidth) = fittingSizes(for: group, within: availableProposal)
      sizeTable.merge(groupSizeTable) { current, new in current }  // No duplicate values are expected.
      remainingWidth = unusedWidth
    }
    return
      sizeTable
      .sorted { $0.key < $1.key }  // ensures that items are in the order they were received.
      .map { ($0.value.size, $0.value.item) }
  }

  private func fittingSizes(
    for pairs: [IndexedItem], within proposal: SizeProposal
  ) -> (sizeTable: SizedItemsByIndex, remainingWidth: Double) {
    var sizeTable: SizedItemsByIndex = .init()

    // The amount of width this priority group is allowed to divide among its remaining siblings.
    let availableWidth = distributableWidth(from: proposal.width.finiteValue ?? .zero)
    var sharedAvailableWidth = availableWidth

    // Resizability is the difference between an item's minimum and maximum fitting width.
    let group: [(index: Int, item: any LayoutItem, resizability: Double)] = pairs.map {
      index, item in
      let shrunkProposal = SizeProposal(width: .collapsed, height: proposal.height)
      let expandedProposal = SizeProposal(width: .fixed(availableWidth), height: proposal.height)
      let minimumWidth = item.sizeThatFits(shrunkProposal).width
      let maximumWidth = item.sizeThatFits(expandedProposal).width
      let resizability = maximumWidth - minimumWidth
      return (index, item, resizability)
    }

    // Items are sized from least to most resizable. Rigid items are resolved first so they can
    // claim the space they need before more adaptable items absorb the remainder.
    // After each item is measured, any unused space is returned to the shared pool.
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
      let equalAllotmentWidth = sharedAvailableWidth / Double(resizabilityAscendingGroups.count)
      let group = resizabilityAscendingGroups.removeFirst()
      let itemProposal = SizeProposal(width: .fixed(equalAllotmentWidth), height: proposal.height)
      let fittingSize = group.item.sizeThatFits(itemProposal)
      sizeTable[group.index] = (fittingSize, group.item)
      sharedAvailableWidth = remainingSpace(afterConsuming: fittingSize.width, from: sharedAvailableWidth)
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

  /// Converts a finite proposed width into width that can actually be distributed among siblings.
  ///
  /// Negative fixed widths are treated as zero during stack allocation.
  private func distributableWidth(from finiteWidth: Double) -> Double {
    max(finiteWidth, .zero)
  }

  /// Subtracts consumed width from a finite budget while keeping the result in a safe range.
  ///
  /// This prevents negative remaining space and collapses non-finite consumption to zero remaining width,
  /// which avoids propagating `nan` through later sibling proposals.
  private func remainingSpace(afterConsuming consumed: Double, from available: Double) -> Double {
    guard available.isFinite else { return available }
    guard consumed.isFinite else { return .zero }
    return max(available - max(consumed, .zero), .zero)
  }
}
