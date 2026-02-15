import Testing
@testable import Arrange

@Suite struct DimensionProposalTests {

  // MARK: - Pattern Matching

  @Test func `test fixed case carries its value`() {
    guard case .fixed(let value) = DimensionProposal.fixed(42) else {
      Issue.record("Expected .fixed")
      return
    }
    #expect(value == 42)
  }

  @Test func `test collapsed is distinct from value zero`() {
    #expect(DimensionProposal.collapsed != .fixed(0))
  }

  @Test func `test expanded is distinct from value infinity`() {
    #expect(DimensionProposal.expanded != .fixed(.infinity))
  }

  @Test func `test unspecified is distinct from collapsed`() {
    #expect(DimensionProposal.unspecified != .collapsed)
  }

  // MARK: - Equatable

  @Test func `test equality between identical cases`() {
    #expect(DimensionProposal.fixed(10) == .fixed(10))
    #expect(DimensionProposal.collapsed == .collapsed)
    #expect(DimensionProposal.expanded == .expanded)
    #expect(DimensionProposal.unspecified == .unspecified)
  }

  @Test func `test inequality between different cases`() {
    #expect(DimensionProposal.fixed(10) != .fixed(20))
    #expect(DimensionProposal.collapsed != .expanded)
    #expect(DimensionProposal.unspecified != .fixed(0))
  }
}

@Suite struct SizeProposalTests {

  // MARK: - Initializers

  @Test func `test init with dimension proposals`() {
    let proposal = SizeProposal(width: .collapsed, height: .expanded)
    #expect(proposal.width == .collapsed)
    #expect(proposal.height == .expanded)
  }

  @Test func `test init with doubles defaults to value case`() {
    let proposal = SizeProposal(width: 100, height: 200)
    #expect(proposal.width == .fixed(100))
    #expect(proposal.height == .fixed(200))
  }

  // MARK: - Static factories

  @Test func `test collapsed has collapsed on both axes`() {
    #expect(SizeProposal.collapsed.width == .collapsed)
    #expect(SizeProposal.collapsed.height == .collapsed)
  }

  @Test func `test expanded has expanded on both axes`() {
    #expect(SizeProposal.expanded.width == .expanded)
    #expect(SizeProposal.expanded.height == .expanded)
  }

  @Test func `test unspecified has unspecified on both axes`() {
    #expect(SizeProposal.unspecified.width == .unspecified)
    #expect(SizeProposal.unspecified.height == .unspecified)
  }

  @Test func `test size from Size wraps both dimensions`() {
    let proposal = SizeProposal.size(Size(width: 40, height: 60))
    #expect(proposal.width == .fixed(40))
    #expect(proposal.height == .fixed(60))
  }

  @Test func `test size from doubles wraps both dimensions`() {
    let proposal = SizeProposal.size(width: 40, height: 60)
    #expect(proposal.width == .fixed(40))
    #expect(proposal.height == .fixed(60))
  }

  // MARK: - Mixed axes

  @Test func `test mixed axes preserve individual cases`() {
    let proposal = SizeProposal(width: .fixed(50), height: .collapsed)
    #expect(proposal.width == .fixed(50))
    #expect(proposal.height == .collapsed)
  }

  @Test func `test mixed unspecified and value`() {
    let proposal = SizeProposal(width: .fixed(10), height: .unspecified)
    #expect(proposal.width == .fixed(10))
    #expect(proposal.height == .unspecified)
  }

  // MARK: - Equatable

  @Test func `test equality`() {
    #expect(SizeProposal(width: 10, height: 20) == SizeProposal.size(width: 10, height: 20))
    #expect(SizeProposal.collapsed == SizeProposal(width: .collapsed, height: .collapsed))
  }

  @Test func `test inequality`() {
    #expect(SizeProposal(width: 10, height: 20) != SizeProposal(width: 10, height: 21))
    #expect(SizeProposal.collapsed != .expanded)
  }

  // MARK: - Mutability

  @Test func `test width and height are mutable`() {
    var proposal = SizeProposal(width: 10, height: 20)
    proposal.width = .expanded
    proposal.height = .collapsed
    #expect(proposal.width == .expanded)
    #expect(proposal.height == .collapsed)
  }
}
