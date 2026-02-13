//
//  Created by Daniel Inoa on 1/2/24.
//

public protocol Layout {

  /// The layout's ideal size, considering its properties and the specified items.
  /// - note: This function should utilize the items' intrinsic size to calculate the resulting size.
  func naturalSize(for items: [any LayoutItem]) -> Size

  /// Returns the size needed to fit the items within the proposed size.
  /// - note: This function queries items' best fitting size, through `sizeThatFits(_:)`,
  ///         to calculate the resulting size.
  /// - note: The resulting size can be larger than the proposed size when the items can not be accomodated within the
  ///         proposed size. Prevent clamping as to respect the items' ideal size.
  func size(fitting items: [any LayoutItem], within bounds: Size) -> Size

  /// Returns each items' corresponding frame, in the same order they were passed in.
  /// - note: The frame of any particular item is dependent on the specified bounds and the item's own layout priority
  /// relative to its neighboring items.
  /// - note: Items with higher priority will be granted as much size as they require.
  /// - note: When multiple items have the same priority, those requiring less space are given precedence.
  func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle]
}
