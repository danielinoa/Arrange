//
//  Created by Daniel Inoa on 2/15/26.
//

import Testing
@testable import Arrange

@MainActor
@Suite struct PaddingLayoutTests {

  // MARK: - Origin Handling

  @Test func `test frames respects non-zero bounds origin`() {
    let item = ResponsiveItem(width: 40)
    let layout = PaddingLayout(insets: .init(top: 10, bottom: 10, left: 20, right: 20))
    let bounds = Rectangle(x: 100, y: 200, width: 100, height: 100)
    let frames = layout.frames(for: [item], within: bounds)
    #expect(frames[0].x == 120) // bounds.x + left inset
    #expect(frames[0].y == 210) // bounds.y + top inset
  }

  @Test func `test frames with zero origin matches insets`() {
    let item = ResponsiveItem(width: 40)
    let layout = PaddingLayout(insets: .init(top: 5, bottom: 5, left: 10, right: 10))
    let bounds = Rectangle(x: 0, y: 0, width: 100, height: 100)
    let frames = layout.frames(for: [item], within: bounds)
    #expect(frames[0].x == 10)
    #expect(frames[0].y == 5)
  }

  // MARK: - Natural Size

  @Test func `test natural size includes insets`() {
    let item = ResponsiveItem(width: 40)
    let layout = PaddingLayout(insets: .init(top: 10, bottom: 20, left: 5, right: 15))
    let size = layout.naturalSize(for: [item])
    #expect(size.width == 40 + 5 + 15) // child + left + right
    #expect(size.height == 1 + 10 + 20) // child + top + bottom
  }

  // MARK: - Size Fitting

  @Test func `test size fitting subtracts insets from proposal`() {
    let item = ResponsiveItem(width: 40)
    let layout = PaddingLayout(insets: .init(top: 10, bottom: 10, left: 20, right: 20))
    let size = layout.size(fitting: [item], within: .size(width: 200, height: 200))
    #expect(size.width == 40 + 20 + 20) // child fits naturally + insets
    #expect(size.height == 1 + 10 + 10) // child fits naturally + insets
  }
}
