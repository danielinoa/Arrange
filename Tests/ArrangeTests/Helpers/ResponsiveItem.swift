//
//  Created by Daniel Inoa on 7/4/24.
//

import Arrange

struct ResponsiveItem: LayoutItem {

  // NOTES
  // intrinsic height is 1
  // item naturally spans horizontally but gains height if its width is shrunk.

  let width: Double
  private let height: Double = 1
  private var area: Double { width * height }

  init(width: Double) {
    self.width = width
  }

  // MARK: - LayoutItem

  /// The layout item's natural size, considering only properties of the item itself.
  var intrinsicSize: Size {
    .init(width: width, height: height)
  }

  func sizeThatFits(_ proposal: Size) -> Size {
    if proposal.width >= width {
      return intrinsicSize
    } else {
      let fittingHeight = area / proposal.width
      return .init(width: proposal.width, height: fittingHeight)
    }
  }
}
