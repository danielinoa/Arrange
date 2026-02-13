//
//  Created by Daniel Inoa on 1/28/24.
//

public struct EdgeInsets: Sendable {

  public var top, bottom, left, right: Double

  public init(
    top: Double = .zero,
    bottom: Double = .zero,
    left: Double = .zero,
    right: Double = .zero
  ) {
    self.top = top
    self.bottom = bottom
    self.left = left
    self.right = right
  }

  public static let zero: EdgeInsets = .init(top: .zero, bottom: .zero, left: .zero, right: .zero)
}
