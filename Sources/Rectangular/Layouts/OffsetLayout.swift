//
//  Created by Daniel Inoa on 1/29/24.
//

// TODO: Add tests

public struct OffsetLayout: Layout {

    public var x, y: Double

    private let layout: ZStackLayout = .init()

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public func naturalSize(for items: [LayoutItem]) -> Size {
        layout.naturalSize(for: items)
    }

    public func size(fitting items: [LayoutItem], within: Size) -> Size {
        layout.size(fitting: items, within: within)
    }

    public func frames(for items: [LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        layout
            .frames(for: items, within: bounds)
            .map { rect in
                var rect = rect
                rect.topY += y
                rect.leadingX += x
                return rect
            }
    }
}
