//
//  Created by Daniel Inoa on 4/8/26.
//

/// A relative priority used by layouts when distributing limited space.
public struct LayoutPriority: Sendable, Hashable, Comparable, ExpressibleByIntegerLiteral, RawRepresentable {

  public static let zero: LayoutPriority = .init(rawValue: .zero)

  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public init(integerLiteral value: Int) {
    self.init(rawValue: value)
  }

  // MARK: - Comparable

  public static func < (lhs: LayoutPriority, rhs: LayoutPriority) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}
