//
//  Created by Daniel Inoa on 1/4/24.
//

/// A layout that arranges its items along the vertical axis.
public struct VStackLayout: Sendable, Layout {

  private struct IndexedItem {
    let index: Int
    let item: any LayoutItem
  }

  private typealias IndexedMeasuredSize = (index: Int, size: Size)
  private typealias AllocationResult = (measurements: [IndexedMeasuredSize], remainingHeight: Double)

  /// The vertical distance between adjacent items within the stack.
  public var spacing: Double

  public var alignment: HorizontalAlignment

  public init(alignment: HorizontalAlignment = .center, spacing: Double = .zero) {
    self.alignment = alignment
    self.spacing = spacing
  }

  public func naturalSize(for items: [any LayoutItem]) -> Size {
    let totalSpacing = totalInteritemSpacing(itemCount: items.count)
    let totalHeight = items.map(\.intrinsicSize.height).reduce(.zero, +) + totalSpacing
    let maxWidth = items.map(\.intrinsicSize.width).max() ?? .zero
    return .init(width: maxWidth, height: totalHeight)
  }

  public func size(fitting items: [any LayoutItem], within proposal: SizeProposal) -> Size {
    let totalSpacing = totalInteritemSpacing(itemCount: items.count)
    let measuredSizes = measuredSizes(for: items, within: proposal)
    let width = measuredSizes.map(\.width).max() ?? .zero
    let height = measuredSizes.reduce(totalSpacing) { $0 + $1.height }
    return .init(width: width, height: height)
  }

  public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
    var topOffset = bounds.topY
    let measuredSizes = measuredSizes(for: items, within: .size(bounds.size))
    let frames = measuredSizes.map { size in
      let x = Self.leadingOffset(for: size, aligned: alignment, within: bounds)
      let y = topOffset
      let frame = Rectangle(x: x, y: y, size: size)
      topOffset += size.height + spacing
      return frame
    }
    return frames
  }

  // MARK: - Measurement

  /// Returns the fitting sizes of the items, in input order.
  ///
  /// The height-sharing path only runs when `proposal.height.finiteValue` exists. Otherwise the height proposal
  /// is treated as unbounded and each child is measured directly with the original proposal.
  private func measuredSizes(for items: [any LayoutItem], within proposal: SizeProposal) -> [Size] {
    guard let availableHeight = proposal.height.finiteValue else {
      return items.map { $0.sizeThatFits(proposal) }
    }

    let indexedItems = items.enumerated().map { IndexedItem(index: $0.offset, item: $0.element) }
    let totalSpacing = totalInteritemSpacing(itemCount: items.count)
    var remainingHeight = remainingSpace(
      afterConsuming: totalSpacing,
      from: distributableHeight(from: availableHeight)
    )
    var orderedSizes = Array<Size?>(repeating: nil, count: items.count)
    let priorityGroups = Dictionary(grouping: indexedItems, by: \.item.priority)

    // Higher-priority groups are resolved first so they can claim space before lower-priority siblings.
    for priority in priorityGroups.keys.sorted(by: >) {
      let group = priorityGroups[priority]!
      let groupProposal = SizeProposal(width: proposal.width, height: .fixed(remainingHeight))
      let allocation = fittingSizes(for: group, within: groupProposal)
      for measurement in allocation.measurements {
        orderedSizes[measurement.index] = measurement.size
      }
      remainingHeight = allocation.remainingHeight
    }

    precondition(orderedSizes.allSatisfy { $0 != nil })
    return orderedSizes.map { $0! }
  }

  // MARK: - Allocation

  private func fittingSizes(
    for items: [IndexedItem], within proposal: SizeProposal
  ) -> AllocationResult {
    let availableHeight = distributableHeight(from: proposal.height.finiteValue ?? .zero)

    guard !items.isEmpty else { return (measurements: [], remainingHeight: availableHeight) }
    if items.count == 1 {
      // A single item does not need resizability ranking or height redistribution.
      let item = items[0]
      let fittingSize = item.item.sizeThatFits(proposal)
      let remainingHeight = remainingSpace(afterConsuming: fittingSize.height, from: availableHeight)
      return (measurements: [(index: item.index, size: fittingSize)], remainingHeight: remainingHeight)
    }

    var remainingHeight = availableHeight

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
      let equalAllotmentHeight = remainingHeight / Double(remainingItemCount)
      let itemProposal = SizeProposal(width: proposal.width, height: .fixed(equalAllotmentHeight))
      let fittingSize = rankedItem.indexedItem.item.sizeThatFits(itemProposal)
      measurements.append(
        (index: rankedItem.indexedItem.index, size: fittingSize)
      )
      remainingHeight = remainingSpace(afterConsuming: fittingSize.height, from: remainingHeight)
    }

    return (measurements: measurements, remainingHeight: remainingHeight)
  }

  // MARK: - Resizability

  // Resizability is the difference between an item's minimum and maximum fitting height.
  private func resizability(of item: any LayoutItem, within proposal: SizeProposal) -> Double {
    let availableHeight = distributableHeight(from: proposal.height.finiteValue ?? .zero)
    let minimumProbe = SizeProposal(width: proposal.width, height: .collapsed)
    let maximumProbe = SizeProposal(width: proposal.width, height: .fixed(availableHeight))
    let minimumHeight = item.sizeThatFits(minimumProbe).height
    let maximumHeight = item.sizeThatFits(maximumProbe).height
    return maximumHeight - minimumHeight
  }

  // MARK: - Positioning

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

  // MARK: - Utilities

  private func totalInteritemSpacing(itemCount: Int) -> Double {
    itemCount > 0 ? spacing * Double(itemCount - 1) : .zero
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
