//
//  Created by Daniel Inoa on 7/1/24.
//

import SwiftPlus

public struct FrameLayout: Layout {

    // TODO: Add idealWidth and idealHeight along with SizeProposal enum (value, .zero, .unspecified, and .infinity)

    private var layout: ZStackLayout

    public var alignment: Alignment {
        get { layout.alignment }
        set { layout.alignment = newValue }
    }

    public let minimumWidth: Double?
    public let maximumWidth: Double?
    public let minimumHeight: Double?
    public let maximumHeight: Double?

    public init(
        minimumWidth: Double? = nil,
        maximumWidth: Double? = nil,
        minimumHeight: Double? = nil,
        maximumHeight: Double? = nil,
        alignment: Alignment = .center
    ) {
        self.minimumWidth = minimumWidth
        self.maximumWidth = maximumWidth
        self.minimumHeight = minimumHeight
        self.maximumHeight = maximumHeight
        self.layout = .init(alignment: alignment)
    }

    public init(
        width: Double? = nil,
        height: Double? = nil,
        alignment: Alignment = .center
    ) {
        self.minimumWidth = width
        self.maximumWidth = width
        self.minimumHeight = height
        self.maximumHeight = height
        self.layout = .init(alignment: alignment)
    }

    public func naturalSize(for items: [any LayoutItem]) -> Size {
        // TODO: NEEDS REVIEW
        let fallbackSize = layout.naturalSize(for: items)
        let width: Double = 
            if let minimumWidth, let maximumWidth {
                max(minimumWidth, maximumWidth)
            } else if let minimumWidth {
                minimumWidth
            } else if let maximumWidth {
                maximumWidth
            } else {
                fallbackSize.width
            }
        let height: Double =
            if let minimumHeight, let maximumHeight {
                max(minimumHeight, maximumHeight)
            } else if let minimumHeight {
                minimumHeight
            } else if let maximumHeight {
                maximumHeight
            } else {
                fallbackSize.height
            }
        return .init(width: width, height: height)
    }

    public func size(fitting items: [any LayoutItem], within bounds: Size) -> Size {




        let childProposalWidth = maximumWidth?.clamped(upTo: bounds.width) ?? bounds.width
        let childProposalHeight = maximumHeight?.clamped(upTo: bounds.height) ?? bounds.height
        let childSize = layout.size(
            fitting: items, within: .init(width: childProposalWidth, height: childProposalHeight)
        )

        let preferredWidth: Double =
            if let minimumWidth, let maximumWidth {
                if minimumWidth >= maximumWidth {
                    max(minimumWidth, childSize.width)
                } else {
                    maximumWidth.clamped(upTo: bounds.width)
                }
            } else if let minimumWidth {
                max(minimumWidth, childSize.width)
            } else if let maximumWidth {
                maximumWidth.clamped(upTo: bounds.width)
            } else {
                childSize.width.clamped(upTo: bounds.width)
            }

        let preferredHeight: Double =
            if let minimumHeight, let maximumHeight {
                if minimumHeight >= maximumHeight {
                    max(minimumHeight, childSize.height)
                } else {
                    maximumHeight.clamped(upTo: bounds.height)
                }
            } else if let minimumHeight {
                max(minimumHeight, childSize.height)
            } else if let maximumHeight {
                maximumHeight.clamped(upTo: bounds.height)
            } else {
                childSize.height.clamped(upTo: bounds.height)
            }
        return .init(width: preferredWidth, height: preferredHeight)
    }

    public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        layout.frames(for: items, within: bounds) // TODO: NEEDS TO BE RETHOUGHT
    }
}
