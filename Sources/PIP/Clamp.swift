//
//  Clamp.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/20.
//

extension Comparable {
    /// Clamps the value to the closed range defined by the two bounds.
    /// - Parameters:
    ///   - l: One bound of the range.
    ///   - r: The other bound of the range.
    /// - Returns: The value clamped to the range [min(l, r), max(l, r)].
    func clamp(_ l: Self, _ r: Self) -> Self {
        return max(min(self, max(l, r)), min(l, r))
    }
}
