//
//  Created by Daniel Inoa on 12/30/23.
//

/// A layout that arranges its items along the horizontal axis.
public struct HStackLayout: Sendable, Layout {

  private struct IndexedItem {
    let index: Int
    let item: any LayoutItem
  }

  private typealias IndexedMeasuredSize = (index: Int, size: Size)
  private typealias AllocationResult = (measurements: [IndexedMeasuredSize], remainingWidth: Double)

  /// The horizontal distance between adjacent items within the stack.
  public var spacing: Double

  public var alignment: VerticalAlignment

  public init(alignment: VerticalAlignment = .center, spacing: Double = .zero) {
    self.alignment = alignment
    self.spacing = spacing
  }

  public func naturalSize(for items: [any LayoutItem]) -> Size {
    let totalSpacing = totalInteritemSpacing(itemCount: items.count)
    let totalWidth = items.map(\.intrinsicSize.width).reduce(.zero, +) + totalSpacing
    let maxHeight = items.map(\.intrinsicSize.height).max() ?? .zero
    return .init(width: totalWidth, height: maxHeight)
  }

  public func size(fitting items: [any LayoutItem], within proposal: SizeProposal) -> Size {
    let totalSpacing = totalInteritemSpacing(itemCount: items.count)
    let measuredSizes = measuredSizes(for: items, within: proposal)
    let width = measuredSizes.reduce(totalSpacing) { $0 + $1.width }
    let height = measuredSizes.map(\.height).max() ?? .zero
    return .init(width: width, height: height)
  }

  public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    var leadingOffset = bounds.leadingX
    let measuredSizes = measuredSizes(for: items, within: .size(bounds.size))
    let frames = measuredSizes.map { size in
      let x = leadingOffset
      let y = Self.topOffset(for: size, aligned: alignment, within: bounds)
      let frame = Rectangle(x: x, y: y, size: size)
      leadingOffset += size.width + spacing
      return frame
    }
    return frames
  }

  // MARK: - Measurement

  /// Returns the fitting sizes of the items, in input order.
  ///
  /// The width-sharing path only runs when `proposal.width.finiteValue` exists. Otherwise the width proposal
  /// is treated as unbounded and each child is measured directly with the original proposal.
  private func measuredSizes(for items: [any LayoutItem], within proposal: SizeProposal) -> [Size] {
    guard let availableWidth = proposal.width.finiteValue else {
      return items.map { $0.sizeThatFits(proposal) }
    }

    let indexedItems = items.enumerated().map { IndexedItem(index: $0.offset, item: $0.element) }
    let totalSpacing = totalInteritemSpacing(itemCount: items.count)
    var remainingWidth = remainingSpace(
      afterConsuming: totalSpacing,
      from: distributableWidth(from: availableWidth)
    )
    var orderedSizes = Array<Size?>(repeating: nil, count: items.count)
    let priorityGroups = Dictionary(grouping: indexedItems, by: \.item.priority)

    // Higher-priority groups are resolved first so they can claim space before lower-priority siblings.
    for priority in priorityGroups.keys.sorted(by: >) {
      let group = priorityGroups[priority]!
      let groupProposal = SizeProposal(width: .fixed(remainingWidth), height: proposal.height)
      let allocation = fittingSizes(for: group, within: groupProposal)
      for measurement in allocation.measurements {
        orderedSizes[measurement.index] = measurement.size
      }
      remainingWidth = allocation.remainingWidth
    }

    precondition(orderedSizes.allSatisfy { $0 != nil })
    return orderedSizes.map { $0! }
  }

  // MARK: - Allocation

  private func fittingSizes(
    for items: [IndexedItem], within proposal: SizeProposal
  ) -> AllocationResult {
    let availableWidth = distributableWidth(from: proposal.width.finiteValue ?? .zero)

    guard !items.isEmpty else { return (measurements: [], remainingWidth: availableWidth) }
    if items.count == 1 {
      let item = items[0]
      let fittingSize = item.item.sizeThatFits(proposal)
      let remainingWidth = remainingSpace(afterConsuming: fittingSize.width, from: availableWidth)
      return (measurements: [(index: item.index, size: fittingSize)], remainingWidth: remainingWidth)
    }

    var remainingWidth = availableWidth

    // Items are sized from least to most resizable. Rigid items are resolved first so they can
    // claim the space they need before more adaptable items absorb the remainder.
    // After each item is measured, any unused space is returned to the shared pool.
    let rankedItems: [(indexedItem: IndexedItem, resizability: Double)] = items
      .map { indexedItem in
        (indexedItem, resizability(of: indexedItem.item, within: proposal))
      }
      .sorted {
        if $0.resizability == $1.resizability {
          return $0.indexedItem.index < $1.indexedItem.index
        }
        return $0.resizability < $1.resizability
      }
    var measurements: [IndexedMeasuredSize] = []

    for (offset, rankedItem) in rankedItems.enumerated() {
      let remainingItemCount = rankedItems.count - offset
      let equalAllotmentWidth = remainingWidth / Double(remainingItemCount)
      let itemProposal = SizeProposal(width: .fixed(equalAllotmentWidth), height: proposal.height)
      let fittingSize = rankedItem.indexedItem.item.sizeThatFits(itemProposal)
      measurements.append(
        (index: rankedItem.indexedItem.index, size: fittingSize)
      )
      remainingWidth = remainingSpace(afterConsuming: fittingSize.width, from: remainingWidth)
    }

    return (measurements: measurements, remainingWidth: remainingWidth)
  }

  // MARK: - Resizability

  // Resizability is the difference between an item's minimum and maximum fitting width.
  private func resizability(of item: any LayoutItem, within proposal: SizeProposal) -> Double {
    let availableWidth = distributableWidth(from: proposal.width.finiteValue ?? .zero)
    let minimumProbe = SizeProposal(width: .collapsed, height: proposal.height)
    let maximumProbe = SizeProposal(width: .fixed(availableWidth), height: proposal.height)
    let minimumWidth = item.sizeThatFits(minimumProbe).width
    let maximumWidth = item.sizeThatFits(maximumProbe).width
    return maximumWidth - minimumWidth
  }

  // MARK: - Positioning

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

  // MARK: - Utilities

  private func totalInteritemSpacing(itemCount: Int) -> Double {
    itemCount > 0 ? spacing * Double(itemCount - 1) : .zero
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
