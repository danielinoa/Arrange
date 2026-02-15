//
//  Created by Daniel Inoa on 12/30/23.
//

public struct Rectangle: Hashable {

  public var origin: Point
  public var size: Size

  // MARK: -

  public var x: Double {
    get { origin.x }
    set { origin.x = newValue }
  }

  public var y: Double {
    get { origin.y }
    set { origin.y = newValue }
  }

  public var width: Double {
    get { size.width }
    set { size.width = newValue }
  }

  public var height: Double {
    get { size.height }
    set { size.height = newValue }
  }

  // MARK: -

  public init(origin: Point, size: Size) {
    self.origin = origin
    self.size = size
  }

  public init(x: Double, y: Double, width: Double, height: Double) {
    self.origin = .init(x: x, y: y)
    self.size = .init(width: width, height: height)
  }

  public init(x: Double, y: Double, size: Size) {
    self.origin = .init(x: x, y: y)
    self.size = size
  }

  public init(origin: Point, width: Double, height: Double) {
    self.origin = origin
    self.size = .init(width: width, height: height)
  }

  public static var zero: Rectangle { .init(origin: .zero, size: .zero) }
}

extension Rectangle {

  // MARK: - Y-Coordinate

  public var topY: Double {
    get { y }
    set { y = newValue }
  }

  public var centerY: Double {
    get { y + (height / 2) }
    set { y = newValue - (height / 2) }
  }

  public var bottomY: Double {
    get { y + height }
    set { y = newValue - height }
  }

  // MARK: - X-Coordinate

  public var leadingX: Double {
    get { x }
    set { x = newValue }
  }

  public var centerX: Double {
    get { x + (width / 2) }
    set { x = newValue - (width / 2) }
  }

  public var trailingX: Double {
    get { x + width }
    set { x = newValue - width }
  }
}

extension Rectangle {

  // MARK: - Anchor Points

  public var topLeading: Point {
    get { .init(x: leadingX, y: topY) }
    set {
      var rect = self
      rect.leadingX = newValue.x
      rect.topY = newValue.y
      self = rect
    }
  }

  public var top: Point {
    get { .init(x: centerX, y: topY) }
    set {
      var rect = self
      rect.centerX = newValue.x
      rect.topY = newValue.y
      self = rect
    }
  }

  public var topTrailing: Point {
    get { .init(x: trailingX, y: topY) }
    set {
      var rect = self
      rect.trailingX = newValue.x
      rect.topY = newValue.y
      self = rect
    }
  }

  public var leading: Point {
    get { .init(x: leadingX, y: centerY) }
    set {
      var rect = self
      rect.leadingX = newValue.x
      rect.centerY = newValue.y
      self = rect
    }
  }

  public var center: Point {
    get { .init(x: centerX, y: centerY) }
    set {
      var rect = self
      rect.centerX = newValue.x
      rect.centerY = newValue.y
      self = rect
    }
  }

  public var trailing: Point {
    get { .init(x: trailingX, y: centerY) }
    set {
      var rect = self
      rect.trailingX = newValue.x
      rect.centerY = newValue.y
      self = rect
    }
  }

  public var bottomLeading: Point {
    get { .init(x: leadingX, y: bottomY) }
    set {
      var rect = self
      rect.leadingX = newValue.x
      rect.bottomY = newValue.y
      self = rect
    }
  }

  public var bottom: Point {
    get { .init(x: centerX, y: bottomY) }
    set {
      var rect = self
      rect.centerX = newValue.x
      rect.bottomY = newValue.y
      self = rect
    }
  }

  public var bottomTrailing: Point {
    get { .init(x: trailingX, y: bottomY) }
    set {
      var rect = self
      rect.trailingX = newValue.x
      rect.bottomY = newValue.y
      self = rect
    }
  }
}
