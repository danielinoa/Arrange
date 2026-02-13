import Testing
@testable import Arrange

final class FrameLayoutTests {

  @Test
  func `test responsive item spans entire width within a larger frame`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(width: 30)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedWidth: Double = 30  // This comes from the layout's specified width
    let expectedHeight: Double = 1  // This comes from the item's height

    #expect(size.width == expectedWidth)
    #expect(size.height == expectedHeight)
  }

  @Test
  func `test item height increases as frame shrinks item width`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(width: 10)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedWidth: Double = 10  // This comes from the layout's specified width
    let expectedHeight: Double = 2  // This comes from the item's height

    #expect(size.width == expectedWidth)
    #expect(size.height == expectedHeight)
  }

  @Test
  func `test max width is clamped up to bounds width`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(maximumWidth: .infinity)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedWidth: Double = 100  // This comes from the layout clamping the width up to the bounds
    let expectedHeight: Double = 1  // This comes from the item's height

    #expect(size.width == expectedWidth)
    #expect(size.height == expectedHeight)
  }

  @Test
  func `test max width at infinity matches bounds`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(maximumWidth: .infinity, maximumHeight: .infinity)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedLayoutWidth: Double = 100
    let expectedLayoutHeight: Double = 100

    #expect(size.width == expectedLayoutWidth)
    #expect(size.height == expectedLayoutHeight)
  }

  @Test
  func `test overflowing min width is clamped up to bounds width`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(minimumWidth: .infinity)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedWidth: Double = 100  // This comes from the layout clamping the width up to the bounds
    let expectedHeight: Double = 1  // This comes from the item's height

    #expect(size.width == expectedWidth)
    #expect(size.height == expectedHeight)
  }

  @Test
  func
    `test item with width larger than layout minwidth forces layout width to expand beyond minwidth`()
  {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(minimumWidth: 20)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedLayoutWidth: Double = 40  // Thsi comes from the item's width forcing the layout's width to expand
    let expectedLayoutHeight: Double = 1  // This comes from the item's height

    #expect(size.width == expectedLayoutWidth)
    #expect(size.height == expectedLayoutHeight)
  }

  @Test
  func `test layout fixed size is not influenced by item size`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 200)
    let layout = FrameLayout(width: 50, height: 50)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedLayoutWidth: Double = 50
    let expectedLayoutHeight: Double = 50

    #expect(size.width == expectedLayoutWidth)
    #expect(size.height == expectedLayoutHeight)
  }

  @Test
  func `test layout with no arguments adopts item size`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 50)
    let layout = FrameLayout()
    let size = layout.size(fitting: [item], within: bounds)

    let expectedLayoutWidth: Double = 50
    let expectedLayoutHeight: Double = 1

    #expect(size.width == expectedLayoutWidth)
    #expect(size.height == expectedLayoutHeight)
  }

  @Test
  func `test layout with no arguments adopts item size clamped to bounds`() {
    let bounds = Size(width: 100, height: 100)
    let item = ResponsiveItem(width: 200)
    let layout = FrameLayout()
    let size = layout.size(fitting: [item], within: bounds)

    let expectedLayoutWidth: Double = 100
    let expectedLayoutHeight: Double = 2

    #expect(size.width == expectedLayoutWidth)
    #expect(size.height == expectedLayoutHeight)
  }
}
