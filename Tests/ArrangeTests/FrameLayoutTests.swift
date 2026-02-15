import Testing
@testable import Arrange

@MainActor
final class FrameLayoutTests {

  @Test
  func `test responsive item spans entire width within a larger frame`() {
    let bounds = SizeProposal.size(width: 100, height: 100)
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
    let bounds = SizeProposal.size(width: 100, height: 100)
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
    let bounds = SizeProposal.size(width: 100, height: 100)
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
    let bounds = SizeProposal.size(width: 100, height: 100)
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
    let bounds = SizeProposal.size(width: 100, height: 100)
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
    let bounds = SizeProposal.size(width: 100, height: 100)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(minimumWidth: 20)
    let size = layout.size(fitting: [item], within: bounds)

    let expectedLayoutWidth: Double = 40  // This comes from the item's width forcing the layout's width to expand
    let expectedLayoutHeight: Double = 1  // This comes from the item's height

    #expect(size.width == expectedLayoutWidth)
    #expect(size.height == expectedLayoutHeight)
  }

  @Test
  func `test layout fixed size is not influenced by item size`() {
    let bounds = SizeProposal.size(width: 100, height: 100)
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
    let bounds = SizeProposal.size(width: 100, height: 100)
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
    let bounds = SizeProposal.size(width: 100, height: 100)
    let item = ResponsiveItem(width: 200)
    let layout = FrameLayout()
    let size = layout.size(fitting: [item], within: bounds)

    let expectedLayoutWidth: Double = 100
    let expectedLayoutHeight: Double = 2

    #expect(size.width == expectedLayoutWidth)
    #expect(size.height == expectedLayoutHeight)
  }

  // MARK: - frames tests

  @Test
  func `test frames with fixed size constrains child within frame bounds`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(width: 50, height: 50)
    let frames = layout.frames(for: [item], within: bounds)

    // Child (20x1) should be centered within the 50x50 frame region.
    // Frame region starts at (0,0) with size 50x50.
    #expect(frames.count == 1)
    #expect(frames[0].width == 20)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 15)  // centered: (50 - 20) / 2
    #expect(frames[0].y == 24.5)  // centered: (50 - 1) / 2
  }

  @Test
  func `test frames with fixed size and trailing alignment`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(width: 80, height: 60, alignment: .trailing)
    let frames = layout.frames(for: [item], within: bounds)

    // Child (20x1) should be trailing-center aligned within the 80x60 frame region.
    #expect(frames.count == 1)
    #expect(frames[0].width == 20)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 60)  // trailing: 80 - 20
    #expect(frames[0].y == 29.5)  // centered vertically: (60 - 1) / 2
  }

  @Test
  func `test frames with max width constrains child to clamped bounds`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let item = ResponsiveItem(width: 60)
    let layout = FrameLayout(maximumWidth: 80)
    let frames = layout.frames(for: [item], within: bounds)

    // Frame size: maxWidth=80 clamped to bounds → 80. Child fits at 60x1.
    // Frame region is 80x1 (child-driven height). Child centered in 80-wide region.
    #expect(frames.count == 1)
    #expect(frames[0].width == 60)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 10)  // centered: (80 - 60) / 2
  }

  @Test
  func `test frames with min width expands frame when child is smaller`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(minimumWidth: 60)
    let frames = layout.frames(for: [item], within: bounds)

    // Frame size: max(60, childWidth=20) → 60. Child (20x1) centered in 60-wide region.
    #expect(frames.count == 1)
    #expect(frames[0].width == 20)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 20)  // centered: (60 - 20) / 2
  }

  @Test
  func `test frames respects non-zero bounds origin`() {
    let bounds = Rectangle(x: 10, y: 20, width: 200, height: 200)
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(width: 50, height: 50)
    let frames = layout.frames(for: [item], within: bounds)

    // Frame region starts at bounds origin (10, 20) with size 50x50.
    // Child (30x1) centered within that region.
    #expect(frames.count == 1)
    #expect(frames[0].width == 30)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 20)  // 10 + (50 - 30) / 2
    #expect(frames[0].y == 44.5)  // 20 + (50 - 1) / 2
  }

  @Test
  func `test frames does not let child exceed constrained bounds`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let item = ResponsiveItem(width: 100)
    let layout = FrameLayout(width: 40, height: 40)
    let frames = layout.frames(for: [item], within: bounds)

    // Child is proposed 40 wide. ResponsiveItem(width:100) at proposal 40 → 40x2.5.
    // Child (40x2.5) centered in 40x40 frame.
    #expect(frames.count == 1)
    #expect(frames[0].width == 40)
    #expect(frames[0].height == 2.5)
    #expect(frames[0].x == 0)  // centered: (40 - 40) / 2
    #expect(frames[0].y == 18.75)  // centered: (40 - 2.5) / 2
  }

  // MARK: - naturalSize tests

  @Test
  func `test naturalSize with no constraints returns child intrinsic size`() {
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout()
    let natural = layout.naturalSize(for: [item])

    #expect(natural.width == 30)
    #expect(natural.height == 1)
  }

  @Test
  func `test naturalSize with min width floors child size`() {
    let item = ResponsiveItem(width: 20)
    let layout = FrameLayout(minimumWidth: 50)
    let natural = layout.naturalSize(for: [item])

    // min acts as floor: max(50, 20) = 50
    #expect(natural.width == 50)
    #expect(natural.height == 1)
  }

  @Test
  func `test naturalSize with min width smaller than child uses child size`() {
    let item = ResponsiveItem(width: 80)
    let layout = FrameLayout(minimumWidth: 50)
    let natural = layout.naturalSize(for: [item])

    // min acts as floor: max(50, 80) = 80
    #expect(natural.width == 80)
    #expect(natural.height == 1)
  }

  @Test
  func `test naturalSize with max width caps child size`() {
    let item = ResponsiveItem(width: 80)
    let layout = FrameLayout(maximumWidth: 50)
    let natural = layout.naturalSize(for: [item])

    // max acts as cap: min(50, 80) = 50
    #expect(natural.width == 50)
    #expect(natural.height == 1)
  }

  @Test
  func `test naturalSize with max width larger than child uses child size`() {
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(maximumWidth: 50)
    let natural = layout.naturalSize(for: [item])

    // max acts as cap: min(50, 30) = 30
    #expect(natural.width == 30)
    #expect(natural.height == 1)
  }

  @Test
  func `test naturalSize with fixed size ignores child`() {
    let item = ResponsiveItem(width: 80)
    let layout = FrameLayout(width: 40, height: 40)
    let natural = layout.naturalSize(for: [item])

    #expect(natural.width == 40)
    #expect(natural.height == 40)
  }

  @Test
  func `test naturalSize with infinity minimum returns infinity`() {
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(minimumWidth: .infinity)
    let natural = layout.naturalSize(for: [item])

    // naturalSize does not resolve infinity — that happens in size(fitting:within:).
    #expect(natural.width == .infinity)
    #expect(natural.height == 1)
  }

  @Test
  func `test naturalSize with infinity maximum returns child size`() {
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(maximumWidth: .infinity)
    let natural = layout.naturalSize(for: [item])

    // max acts as cap: min(.infinity, 30) = 30
    #expect(natural.width == 30)
    #expect(natural.height == 1)
  }

  // MARK: - frames with infinity tests

  @Test
  func `test frames with max width infinity resolves to bounds width`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 100)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(maximumWidth: .infinity)
    let frames = layout.frames(for: [item], within: bounds)

    // size resolves maxWidth .infinity → bounds.width (200). Child (40x1) centered in 200-wide region.
    #expect(frames.count == 1)
    #expect(frames[0].width == 40)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 80)  // centered: (200 - 40) / 2
  }

  @Test
  func `test frames with min width infinity resolves to bounds width`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 100)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(minimumWidth: .infinity)
    let frames = layout.frames(for: [item], within: bounds)

    // size resolves minWidth .infinity → bounds.width (200). Child (40x1) centered in 200-wide region.
    #expect(frames.count == 1)
    #expect(frames[0].width == 40)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 80)  // centered: (200 - 40) / 2
  }

  // MARK: - frames with multiple items tests

  @Test
  func `test frames with multiple items aligns all within constrained bounds`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let small = ResponsiveItem(width: 20)
    let large = ResponsiveItem(width: 40)
    let layout = FrameLayout(width: 60, height: 60)
    let frames = layout.frames(for: [small, large], within: bounds)

    // Both items centered in 60x60 frame (ZStack behavior).
    #expect(frames.count == 2)
    // small (20x1): centered in 60x60
    #expect(frames[0].width == 20)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 20)  // (60 - 20) / 2
    #expect(frames[0].y == 29.5)  // (60 - 1) / 2
    // large (40x1): centered in 60x60
    #expect(frames[1].width == 40)
    #expect(frames[1].height == 1)
    #expect(frames[1].x == 10)  // (60 - 40) / 2
    #expect(frames[1].y == 29.5)  // (60 - 1) / 2
  }

  @Test
  func `test frames with multiple items and top leading alignment`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let small = ResponsiveItem(width: 20)
    let large = ResponsiveItem(width: 40)
    let layout = FrameLayout(width: 60, height: 60, alignment: .topLeading)
    let frames = layout.frames(for: [small, large], within: bounds)

    #expect(frames.count == 2)
    // small (20x1): top-leading in 60x60
    #expect(frames[0].x == 0)
    #expect(frames[0].y == 0)
    // large (40x1): top-leading in 60x60
    #expect(frames[1].x == 0)
    #expect(frames[1].y == 0)
  }

  // MARK: - min/max range clamping tests

  @Test
  func `test size clamps child to min max range when child fits within`() {
    let bounds = SizeProposal.size(width: 200, height: 200)
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(minimumWidth: 20, maximumWidth: 80)
    let size = layout.size(fitting: [item], within: bounds)

    // Child wants 30, which is within 20...80 → 30
    #expect(size.width == 30)
    #expect(size.height == 1)
  }

  @Test
  func `test size clamps child up to max when child exceeds range`() {
    let bounds = SizeProposal.size(width: 200, height: 200)
    let item = ResponsiveItem(width: 100)
    let layout = FrameLayout(minimumWidth: 20, maximumWidth: 80)
    let size = layout.size(fitting: [item], within: bounds)

    // Child proposed 80 (maxWidth), responds 80x1.25. Clamped to 20...80 → 80.
    #expect(size.width == 80)
  }

  @Test
  func `test size clamps child up to min when child is below range`() {
    let bounds = SizeProposal.size(width: 200, height: 200)
    let item = ResponsiveItem(width: 10)
    let layout = FrameLayout(minimumWidth: 20, maximumWidth: 80)
    let size = layout.size(fitting: [item], within: bounds)

    // Child wants 10, below min → clamped to 20.
    #expect(size.width == 20)
  }

  @Test
  func `test size with inverted min max uses min as floor`() {
    let bounds = SizeProposal.size(width: 200, height: 200)
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(minimumWidth: 80, maximumWidth: 20)
    let size = layout.size(fitting: [item], within: bounds)

    // Inverted: min(80) > max(20). Range becomes 80...80. Child clamped to 80.
    #expect(size.width == 80)
  }

  @Test
  func `test naturalSize clamps child to min max range`() {
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(minimumWidth: 20, maximumWidth: 80)
    let natural = layout.naturalSize(for: [item])

    // Child intrinsic 30, within 20...80 → 30
    #expect(natural.width == 30)
    #expect(natural.height == 1)
  }

  @Test
  func `test naturalSize clamps child above range to max`() {
    let item = ResponsiveItem(width: 100)
    let layout = FrameLayout(minimumWidth: 20, maximumWidth: 80)
    let natural = layout.naturalSize(for: [item])

    // Child intrinsic 100, above max → 80
    #expect(natural.width == 80)
  }

  @Test
  func `test naturalSize clamps child below range to min`() {
    let item = ResponsiveItem(width: 10)
    let layout = FrameLayout(minimumWidth: 20, maximumWidth: 80)
    let natural = layout.naturalSize(for: [item])

    // Child intrinsic 10, below min → 20
    #expect(natural.width == 20)
  }

  // MARK: - height-only and mixed constraint tests

  @Test
  func `test size with height only constraint`() {
    let bounds = SizeProposal.size(width: 200, height: 200)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(height: 30)
    let size = layout.size(fitting: [item], within: bounds)

    // Width unconstrained → child width (40). Height fixed at 30.
    #expect(size.width == 40)
    #expect(size.height == 30)
  }

  @Test
  func `test size with fixed width and min max height`() {
    let bounds = SizeProposal.size(width: 200, height: 200)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(
      minimumWidth: 50, maximumWidth: 50,
      minimumHeight: 10, maximumHeight: 60
    )
    let size = layout.size(fitting: [item], within: bounds)

    // Width: fixed at 50. Child proposed 50, responds 40x1 → clamped to 50.
    // Height: child wants 1, clamped to 10...60 → 10.
    #expect(size.width == 50)
    #expect(size.height == 10)
  }

  @Test
  func `test frames with height only aligns child in constrained height`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let item = ResponsiveItem(width: 40)
    let layout = FrameLayout(height: 60)
    let frames = layout.frames(for: [item], within: bounds)

    // Frame size: width=40 (child-driven), height=60 (fixed).
    // Child (40x1) centered in 40x60 region.
    #expect(frames.count == 1)
    #expect(frames[0].width == 40)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 0)  // (40 - 40) / 2
    #expect(frames[0].y == 29.5)  // (60 - 1) / 2
  }

  @Test
  func `test frames with min max range constrains region`() {
    let bounds = Rectangle(x: 0, y: 0, width: 200, height: 200)
    let item = ResponsiveItem(width: 30)
    let layout = FrameLayout(minimumWidth: 20, maximumWidth: 80, minimumHeight: 10, maximumHeight: 50)
    let frames = layout.frames(for: [item], within: bounds)

    // Size: width clamped 30 to 20...80 → 30. Height clamped 1 to 10...50 → 10.
    // Child (30x1) centered in 30x10 frame.
    #expect(frames.count == 1)
    #expect(frames[0].width == 30)
    #expect(frames[0].height == 1)
    #expect(frames[0].x == 0)  // (30 - 30) / 2
    #expect(frames[0].y == 4.5)  // (10 - 1) / 2
  }
}
