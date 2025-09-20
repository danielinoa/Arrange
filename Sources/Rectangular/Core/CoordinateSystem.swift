//
//  Created by Daniel Inoa on 12/30/23.
//

// TODO: Handle different coordinates systems

nonisolated(unsafe) var coordinateSystem: CoordinateSystem = .topLeft

enum CoordinateSystem {

    /// The origin is in the upper-left corner of the rectangle and y-values extend downward.
    case topLeft

    /// The origin is in the lower-left corner of the rectangle and positive y-values extend upward.
    case bottomLeft
}
