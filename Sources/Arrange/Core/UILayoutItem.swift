//
//  Created by Daniel Inoa on 1/1/24.
//

/// A `LayoutItem` whose sizing queries must run on the main actor.
///
/// Swift 6 does not allow a main-actor-isolated type to satisfy actor-neutral protocol requirements directly,
/// so `UILayoutItem` exposes separate main-actor requirements and provides nonisolated bridge implementations
/// for `LayoutItem`.
@MainActor
public protocol UILayoutItem: AnyObject, LayoutItem {

  var mainActorPriority: LayoutPriority { get }
  var mainActorIntrinsicSize: Size { get }
  func mainActorSizeThatFits(_ proposal: SizeProposal) -> Size
}

extension UILayoutItem {

  public var mainActorPriority: LayoutPriority { .zero }
  public var mainActorIntrinsicSize: Size { .zero }

  public nonisolated var priority: LayoutPriority {
    nonisolated(unsafe) let unsafeSelf = self
    if #available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *) {
      return MainActor.assumeIsolated { unsafeSelf.mainActorPriority }
    } else {
      fatalError("UILayoutItem requires concurrency runtime support")
    }
  }

  public nonisolated var intrinsicSize: Size {
    nonisolated(unsafe) let unsafeSelf = self
    if #available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *) {
      return MainActor.assumeIsolated { unsafeSelf.mainActorIntrinsicSize }
    } else {
      fatalError("UILayoutItem requires concurrency runtime support")
    }
  }

  public nonisolated func sizeThatFits(_ proposal: SizeProposal) -> Size {
    nonisolated(unsafe) let unsafeSelf = self
    if #available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *) {
      return MainActor.assumeIsolated { unsafeSelf.mainActorSizeThatFits(proposal) }
    } else {
      fatalError("UILayoutItem requires concurrency runtime support")
    }
  }
}
