//
//  Created by Daniel Inoa on 12/30/23.
//

public struct Size: Hashable {

    public var width: Double
    public var height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    public static var zero: Size { .init(width: .zero, height: .zero) }
}

public extension Size {

    static func square(_ dimension: Double) -> Size {
        .init(width: dimension, height: dimension)
    }
}
