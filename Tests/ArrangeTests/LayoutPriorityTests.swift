import Testing
@testable import Arrange

@Suite struct LayoutPriorityTests {

  @Test func `test integer literal init`() {
    let priority: LayoutPriority = 3
    #expect(priority.rawValue == 3)
  }

  @Test func `test zero`() {
    #expect(LayoutPriority.zero.rawValue == 0)
  }

  @Test func `test comparable orders by raw value`() {
    #expect(LayoutPriority(rawValue: 1) < LayoutPriority(rawValue: 2))
  }
}
