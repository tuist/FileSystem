//
//  File.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 07/12/2025.
//

extension Int {
    public init(
        _ bool: Bool
    ) {
        self = bool ? 1 : 0
    }
}
