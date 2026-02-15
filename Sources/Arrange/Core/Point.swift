//
//  Created by Daniel Inoa on 12/30/23.
//

public struct Point: Sendable, Hashable {

  public var x: Double
  public var y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  public static let zero: Point = .init(x: .zero, y: .zero)
}
