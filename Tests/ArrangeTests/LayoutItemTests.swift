import Testing
@testable import Arrange

@Suite
struct LayoutItemTests {

  @Test
  func `test value item can conform without main actor isolation`() {
    struct ValueItem: LayoutItem {
      func sizeThatFits(_ proposal: SizeProposal) -> Size { .init(width: 10, height: 20) }
    }

    let item: any LayoutItem = ValueItem()
    #expect(item.sizeThatFits(.unspecified) == .init(width: 10, height: 20))
  }

  @MainActor
  @Test
  func `test ui layout item refines layout item on the main actor`() {
    @MainActor
    final class MainActorItem: UILayoutItem {
      func mainActorSizeThatFits(_ proposal: SizeProposal) -> Size { .init(width: 30, height: 40) }
    }

    let uiItem: any UILayoutItem = MainActorItem()
    let item: any LayoutItem = uiItem
    #expect(item.sizeThatFits(.unspecified) == .init(width: 30, height: 40))
  }

  @MainActor
  @Test
  func `test ui layout item bridges priority and intrinsic size`() {
    @MainActor
    final class MainActorItem: UILayoutItem {
      var mainActorPriority: LayoutPriority { 7 }
      var mainActorIntrinsicSize: Size { .init(width: 11, height: 13) }
      func mainActorSizeThatFits(_ proposal: SizeProposal) -> Size { .init(width: 30, height: 40) }
    }

    let item: any LayoutItem = MainActorItem()
    #expect(item.priority == 7)
    #expect(item.intrinsicSize == .init(width: 11, height: 13))
  }

  @MainActor
  @Test
  func `test mixed layout items preserve bridged priority and intrinsic size in hstack`() {
    struct ValueItem: LayoutItem {
      var intrinsicSize: Size { .init(width: 10, height: 20) }
      func sizeThatFits(_ proposal: SizeProposal) -> Size { intrinsicSize }
    }

    @MainActor
    final class MainActorItem: UILayoutItem {
      var mainActorPriority: LayoutPriority { 5 }
      var mainActorIntrinsicSize: Size { .init(width: 30, height: 40) }

      func mainActorSizeThatFits(_ proposal: SizeProposal) -> Size {
        let width: Double = switch proposal.width {
          case .fixed(let value): value
          case .collapsed: .zero
          case .expanded: .infinity
          case .unspecified: mainActorIntrinsicSize.width
        }
        return .init(width: width, height: mainActorIntrinsicSize.height)
      }
    }

    let items: [any LayoutItem] = [ValueItem(), MainActorItem()]
    let layout = HStackLayout(spacing: 5)

    #expect(layout.naturalSize(for: items) == .init(width: 45, height: 40))

    let frames = layout.frames(for: items, within: .init(origin: .zero, size: .init(width: 100, height: 40)))
    #expect(frames[1].width == 95)
  }
}
