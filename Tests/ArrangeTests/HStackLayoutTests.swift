import Testing
@testable import Arrange

@MainActor
final class HStackLayoutTests {

  @Test
  func `test size with no items`() {
    let layout = HStackLayout()
    let size = layout.naturalSize(for: [])
    #expect(size == .zero)
  }

  @Test
  func `test size with no items and with non zero spacing`() {
    var layout = HStackLayout()
    layout.spacing = 10
    let size = layout.naturalSize(for: [])
    #expect(size == .zero)
  }

  @Test
  func `test size with one item and with non zero spacing`() {
    struct FixedItem: LayoutItem {
      var intrinsicSize: Size { .square(100) }
      func sizeThatFits(_ proposal: SizeProposal) -> Size { intrinsicSize }
    }
    var layout = HStackLayout()
    layout.spacing = 10
    let item1 = FixedItem()
    let size = layout.naturalSize(for: [item1])
    let expected = Size.square(100)
    #expect(size == expected)
  }

  @Test
  func `test size with 2 flexible items`() {
    let bounds = SizeProposal.size(Size.square(100))
    let item1 = Spacer()
    let item2 = Spacer()
    let layout = HStackLayout()
    let size = layout.size(fitting: [item1, item2], within: bounds)
    let expected = Size.init(width: 100, height: 100)
    #expect(size == expected)
  }

  @Test
  func `test size with 2 flexible items and spacing`() {
    let bounds = SizeProposal.size(Size.square(100))
    let item1 = Spacer()
    let item2 = Spacer()
    let layout = HStackLayout.init(spacing: 10)
    let size = layout.size(fitting: [item1, item2], within: bounds)
    let expected = Size.init(width: 100, height: 100)
    #expect(size == expected)
  }

  @Test
  func `test size with 1 fixed item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return .init(width: 50, height: height)
      }
    }
    let bounds = SizeProposal.size(Size.square(100))
    let item1 = FixedItem()
    let layout = HStackLayout()
    let size = layout.size(fitting: [item1], within: bounds)
    let expected = Size.init(width: 50, height: 100)
    #expect(size == expected)
  }

  @Test
  func `test size with 1 fixed item with spacing`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return .init(width: 50, height: height)
      }
    }
    let bounds = SizeProposal.size(Size.square(100))
    let item1 = FixedItem()
    let layout = HStackLayout(spacing: 10)
    let size = layout.size(fitting: [item1], within: bounds)
    let expected = Size.init(width: 50, height: 100)
    #expect(size == expected)
  }

  @Test
  func `test size with 2 fixed items and spacing`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return .init(width: 20, height: height)
      }
    }
    let bounds = SizeProposal.size(Size.square(100))
    let item1 = FixedItem()
    let item2 = FixedItem()
    let layout = HStackLayout(spacing: 10)
    let size = layout.size(fitting: [item1, item2], within: bounds)
    let expected = Size.init(width: 50, height: 100)
    #expect(size == expected)
  }

  @Test
  func `test frames of 2 fixed items and spacing`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size { .square(20) }
    }
    let item1 = FixedItem()
    let item2 = FixedItem()
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = HStackLayout(spacing: 10)
    let frames = layout.frames(for: [item1, item2], within: bounds)

    #expect(frames.first!.x == 0)
    #expect(frames.first!.y == 40)
    #expect(frames.last!.x == 30)
    #expect(frames.last!.y == 40)
  }

  @Test
  func `test frames with fixed and flexible item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return .init(width: 25, height: height)
      }
    }
    struct FlexibleItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let width: Double = switch proposal.width {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return Size(width: width, height: height)
      }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = HStackLayout()
    let items: [any LayoutItem] = [FixedItem(), FlexibleItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames.first!.x == 0)
    #expect(frames.first!.width == 25)
    #expect(frames.last!.x == 25)
    #expect(frames.last!.width == 75)
  }

  @Test
  func `test frames with flexible and fixed item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return .init(width: 25, height: height)
      }
    }
    struct FlexibleItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let width: Double = switch proposal.width {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return Size(width: width, height: height)
      }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = HStackLayout()
    let items: [any LayoutItem] = [FlexibleItem(), FixedItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames.first!.x == 0)
    #expect(frames.first!.width == 75)
    #expect(frames.last!.x == 75)
    #expect(frames.last!.width == 25)
  }

  @Test
  func `test frames with fixed item between flexible items`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return .init(width: 30, height: height)
      }
    }
    struct FlexibleItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let width: Double = switch proposal.width {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return Size(width: width, height: height)
      }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = HStackLayout()
    let items: [any LayoutItem] = [FlexibleItem(), FixedItem(), FlexibleItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].x == 0)
    #expect(frames[0].width == 35)
    #expect(frames[1].x == 35)
    #expect(frames[1].width == 30)
    #expect(frames[2].x == 65)
    #expect(frames[2].width == 35)
  }

  @Test
  func `test frames where flexible item has higher priority than fixed item`() {
    struct FixedItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size { .init(width: 30, height: 30) }
    }
    struct FlexibleItem: LayoutItem {
      var priority: Int { 1 }
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let width: Double = switch proposal.width {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        return Size(width: width, height: height)
      }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = HStackLayout()
    let items: [any LayoutItem] = [FlexibleItem(), FixedItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].x == 0)
    #expect(frames[0].width == 100)
    #expect(frames[0].height == 100)
    #expect(frames[1].x == 100)
    #expect(frames[1].width == 30)
    #expect(frames[1].height == 30)
  }

  @Test
  func `test fixed item overlapped frames with negative spacing`() {
    struct FixedItem: LayoutItem {
      var intrinsicSize: Size { .init(width: 10, height: 10) }
      func sizeThatFits(_ proposal: SizeProposal) -> Size { intrinsicSize }
    }
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = HStackLayout(spacing: -5)
    let items: [any LayoutItem] = [FixedItem(), FixedItem(), FixedItem()]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].x == 0)
    #expect(frames[0].width == 10)
    #expect(frames[1].x == 5)
    #expect(frames[1].width == 10)
    #expect(frames[2].x == 10)
    #expect(frames[2].width == 10)
  }

  @Test
  func `test flexible item with minimum width is given layout priority over spacer`() {
    struct FlexItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size {
        let width: Double = switch proposal.width {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        let height: Double = switch proposal.height {
        case .fixed(let value): value
        case .collapsed, .unspecified: .zero
        case .expanded: .infinity
        }
        let minimumWidth = max(70, width)
        let fittingSize = Size(width: minimumWidth, height: height)
        return fittingSize
      }
    }
    let spacer = Spacer()
    let minWidthItem = FlexItem()
    let bounds = Rectangle(origin: .zero, size: .square(100))
    let layout = HStackLayout()
    let items: [any LayoutItem] = [spacer, minWidthItem]
    let frames = layout.frames(for: items, within: bounds)

    #expect(frames[0].x == 0)
    #expect(frames[0].width == 30)
    #expect(frames[1].x == 30)
    #expect(frames[1].width == 70)
  }
}
