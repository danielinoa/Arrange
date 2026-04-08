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
}
