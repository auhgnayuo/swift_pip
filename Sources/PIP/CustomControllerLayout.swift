//
//  CustomControllerLayout.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/18.
//

import UIKit

public extension PIP.CustomController {
    /// Layout represents the position and collapse state for PiP content within its container.
    /// It supports serialization and deserialization for persistence.
    @objc
    final class Layout: NSObject, Codable, Sendable {
        /// CollapseStatus indicates which edge the content is collapsed to.
        @objc
        public enum CollapseStatus: Int, Codable {
            case top
            case left
            case bottom
            case right
        }

        /// The normalized distance from the top edge (0.0 to 1.0), or nil if not used.
        public let top: CGFloat?
        /// The normalized distance from the leading edge (0.0 to 1.0), or nil if not used.
        public let leading: CGFloat?
        /// The normalized distance from the bottom edge (0.0 to 1.0), or nil if not used.
        public let bottom: CGFloat?
        /// The normalized distance from the trailing edge (0.0 to 1.0), or nil if not used.
        public let trailing: CGFloat?
        /// The edge to which the content is collapsed, if any.
        public let collapseEdge: UIRectEdge?
        /// Initializes a new Layout.
        /// - Parameters:
        ///   - top: Normalized top distance.
        ///   - leading: Normalized leading distance.
        ///   - bottom: Normalized bottom distance.
        ///   - trailing: Normalized trailing distance.
        ///   - collapseEdge: The edge to collapse to.
        public init(
            top: CGFloat? = nil,
            leading: CGFloat? = nil,
            bottom: CGFloat? = nil,
            trailing: CGFloat? = nil,
            collapseEdge: UIRectEdge? = nil,
        ) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
            self.collapseEdge = collapseEdge
            // Assert only one edge is used for collapse, and only one of each axis is set
            if let collapseEdge {
                assert(collapseEdge.rawValue != 1 && collapseEdge.rawValue & (collapseEdge.rawValue - 1) == 0)
                assert(
                    (top != nil && top! >= 0 && top! <= 1 && leading == nil && bottom == nil && trailing == nil) ||
                        (top == nil && leading != nil && leading! >= 0 && leading! <= 1 && bottom == nil && trailing == nil) ||
                        (top == nil && leading == nil && bottom != nil && bottom! >= 0 && bottom! <= 1 && trailing == nil) ||
                        (top == nil && leading == nil && bottom == nil && trailing != nil && trailing! >= 0 && trailing! <= 1)
                )
            } else {
                assert((top == nil && bottom != nil) || (top != nil && bottom == nil))
                assert((leading == nil && trailing != nil) || (leading != nil && trailing == nil))
            }
        }

        /// The key used for persisting layout in UserDefaults.
        private static let userDefaultsKey = "PIP.CustomController.Layout"
        /// Saves the layout to UserDefaults.
        /// - Parameter layout: The layout to save.
        static func save(layout: Layout) {
            guard let data = try? JSONEncoder().encode(layout) else {
                return
            }
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }

        /// Restores the layout from UserDefaults, or returns a default layout if not found or invalid.
        /// - Returns: The restored or default layout.
        static func restore(_ placeholder: Layout? = nil) -> Layout {
            guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
                return placeholder ?? .init(bottom: 0.0, trailing: 0.0)
            }
            do {
                return try JSONDecoder().decode(Layout.self, from: data)
            } catch _ {
                UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
                return placeholder ?? .init(bottom: 0.0, trailing: 0.0)
            }
        }
    }
}
