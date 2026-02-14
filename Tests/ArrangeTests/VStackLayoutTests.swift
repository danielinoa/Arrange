import Testing
@testable import Arrange

@MainActor
final class VStackLayoutTests {

  @Test
  func `test size with no items`() {
    let layout = VStackLayout()
    let size = layout.naturalSize(for: [])
    #expect(size == .zero)
  }

  @Test
  func `test size with no items and with non zero spacing`() {
    var layout = VStackLayout()
    layout.spacing = 10
    let size = layout.naturalSize(for: [])
    #expect(size == .zero)
  }

  @Test
  func `test size with one item and with non zero spacing`() {
    struct FixedItem: LayoutItem {
      var intrinsicSize: Size { .square(100) }
      func sizeThatFits(_ size: Size) -> Size { intrinsicSize }
    }
    var layout = VStackLayout()
    layout.spacing = 10
    let item1 = FixedItem()
    let size = layout.naturalSize(for: [item1])
    let expected = Size.square(100)
    #expect(size == expected)
  }

  @Test
  func `test size with 2 flexible items`() {
    let bounds = Size.square(100)
    let item1 = Spacer()
    let item2 = Spacer()
    let layout = VStackLayout()
    let size = layout.size(fitting: [item1, item2], within: bounds)
    let expected = Size.square(100)
    #expect(size == expected)
  }

  @Test
  func `test size with 2 flexible items and spacing`() {
    let bounds = Size.square(100)
    let item1 = Spacer()
    let item2 = Spacer()
    let layout = VStackLayout.init(spacing: 10)
    let size = layout.size(fitting: [item1, item2], within: bounds)
    let expected = Size.square(100)
    #expect(size == expected)
  }

  @Test
  func `test size with 1 fixed item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 50) }
    }
    let bounds = Size.square(100)
    let item1 = FixedItem()
    let layout = VStackLayout()
    let size = layout.size(fitting: [item1], within: bounds)
    let expected = Size.init(width: 100, height: 50)
    #expect(size == expected)
  }

  @Test
  func `test size with 1 fixed item with spacing`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 50) }
    }
    let bounds = Size.square(100)
    let item1 = FixedItem()
    let layout = VStackLayout(spacing: 10)
    let size = layout.size(fitting: [item1], within: bounds)
    let expected = Size.init(width: 100, height: 50)
    #expect(size == expected)
  }

  @Test
  func `test size with 2 fixed items and spacing`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 20) }
    }
    let bounds = Size.square(100)
    let item1 = FixedItem()
    let item2 = FixedItem()
    let layout = VStackLayout(spacing: 10)
    let size = layout.size(fitting: [item1, item2], within: bounds)
    let expected = Size.init(width: 100, height: 50)
    #expect(size == expected)
  }

  @Test
  func `test frames of 2 fixed items and spacing`() throws {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .square(20) }
    }
    let item1 = FixedItem()
    let item2 = FixedItem()
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = VStackLayout(spacing: 10)
    let frames = layout.frames(for: [item1, item2], within: bounds)

    #expect(frames.first!.x == 40)
    #expect(frames.first!.y == 0)
    #expect(frames.last!.x == 40)
    #expect(frames.last!.y == 30)
  }

  @Test
  func `test frames with fixed and flexible item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 25) }
    }
    struct FlexibleItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { size }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = VStackLayout()
    let items: [any LayoutItem] = [FixedItem(), FlexibleItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames.first!.y == 0)
    #expect(frames.first!.height == 25)
    #expect(frames.last!.y == 25)
    #expect(frames.last!.height == 75)
  }

  @Test
  func `test frames with flexible and fixed item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 25) }
    }
    struct FlexibleItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { size }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = VStackLayout()
    let items: [any LayoutItem] = [FlexibleItem(), FixedItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames.first!.y == 0)
    #expect(frames.first!.height == 75)
    #expect(frames.last!.y == 75)
    #expect(frames.last!.height == 25)
  }

  @Test
  func `test frames with fixed item between flexible items`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .init(width: size.width, height: 30) }
    }
    struct FlexibleItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { size }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = VStackLayout()
    let items: [any LayoutItem] = [FlexibleItem(), FixedItem(), FlexibleItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].y == 0)
    #expect(frames[0].height == 35)
    #expect(frames[1].y == 35)
    #expect(frames[1].height == 30)
    #expect(frames[2].y == 65)
    #expect(frames[2].height == 35)
  }

  @Test
  func `test frames where flexible item has higher priority than fixed item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size { .init(width: 30, height: 30) }
    }
    struct FlexibleItem: LayoutItem {
      var priority: Int { 1 }
      func sizeThatFits(_ size: Size) -> Size { size }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = VStackLayout()
    let items: [any LayoutItem] = [FlexibleItem(), FixedItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].y == 0)
    #expect(frames[0].width == 100)
    #expect(frames[0].height == 100)
    #expect(frames[1].y == 100)
    #expect(frames[1].width == 30)
    #expect(frames[1].height == 30)
  }

  @Test
  func `test fixed item overlapped frames with negative spacing`() {
    struct FixedItem: LayoutItem {
      var intrinsicSize: Size { .init(width: 10, height: 10) }
      func sizeThatFits(_ size: Size) -> Size { intrinsicSize }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = VStackLayout(spacing: -5)
    let items: [any LayoutItem] = [FixedItem(), FixedItem(), FixedItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].y == 0)
    #expect(frames[0].height == 10)
    #expect(frames[1].y == 5)
    #expect(frames[1].height == 10)
    #expect(frames[2].y == 10)
    #expect(frames[2].height == 10)
  }

  @Test
  func `test flexible item with minimum width is given layout priority over spacer`() {
    struct FlexItem: LayoutItem {
      func sizeThatFits(_ size: Size) -> Size {
        let minimumHeight = max(70, size.height)
        let fittingSize = Size(width: size.width, height: minimumHeight)
        return fittingSize
      }
    }
    let spacer = Spacer()
    let minWidthItem = FlexItem()
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = VStackLayout()
    let items: [any LayoutItem] = [spacer, minWidthItem]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].y == 0)
    #expect(frames[0].height == 30)
    #expect(frames[1].y == 30)
    #expect(frames[1].height == 70)
  }
}
