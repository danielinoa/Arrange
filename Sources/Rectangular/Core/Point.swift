//
//  Created by Daniel Inoa on 12/30/23.
//

public struct Point: Hashable {

  public var x: Double
  public var y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  public static var zero: Point { .init(x: .zero, y: .zero) }
}
