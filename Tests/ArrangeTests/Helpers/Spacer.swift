//
//  Created by Daniel Inoa on 7/4/24.
//

import Arrange

struct Spacer: LayoutItem {
  func sizeThatFits(_ proposal: SizeProposal) -> Size {
    let width: Double = switch proposal.width {
    case .fixed(let value): value
    case .collapsed, .unspecified: .zero
    case .expanded: .infinity
    }
    let height: Double = switch proposal.height {
    case .fixed(let value): value
    case .collapsed, .unspecified: .zero
    case .expanded: .infinity
    }
    return Size(width: width, height: height)
  }
}
