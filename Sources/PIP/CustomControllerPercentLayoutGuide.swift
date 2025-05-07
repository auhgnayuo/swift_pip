//
//  PercentLayoutGuide.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/21.
//

import UIKit

extension PIP.CustomController {
    /// PercentLayoutGuide is a UILayoutGuide that supports percentage-based sizing relative to a parent layout guide.
    /// It is used for positioning and sizing PiP content as a percentage of its container.
    class PercentLayoutGuide: UILayoutGuide {
        /// The dimension (width or height) that this guide controls.
        enum Dimension {
            case width
            case height
        }

        /// Initializes a new PercentLayoutGuide for the specified dimension.
        /// - Parameter dimension: The dimension to control (width or height).
        init(dimension: Dimension) {
            self.dimension = dimension
            super.init()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// The parent layout guide to which this guide is relative.
        var parent: UILayoutGuide! {
            didSet {
                NSLayoutConstraint.deactivate(constraints ?? [])
                constraints = [
                    centerXAnchor.constraint(equalTo: parent.centerXAnchor),
                    centerYAnchor.constraint(equalTo: parent.centerYAnchor),
                    widthAnchor.constraint(equalTo: parent.widthAnchor),
                    heightAnchor.constraint(equalTo: parent.heightAnchor),
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }

        /// The dimension (width or height) being controlled.
        private let dimension: Dimension
        /// The constraints currently applied to this guide.
        private var constraints: [NSLayoutConstraint]!
        /// The percentage (0.0 to 1.0) of the parent dimension to use for sizing.
        var percent: CGFloat = 0.0 {
            didSet {
                if oldValue == percent {
                    return
                }
                assert(percent >= 0 && percent <= 1)
                switch dimension {
                case .width:
                    NSLayoutConstraint.deactivate([constraints[2]])
                    constraints[2] = widthAnchor.constraint(equalTo: parent.widthAnchor, multiplier: 1-percent*2)
                    NSLayoutConstraint.activate([constraints[2]])
                case .height:
                    NSLayoutConstraint.deactivate([constraints[3]])
                    constraints[3] = heightAnchor.constraint(equalTo: parent.heightAnchor, multiplier: 1-percent*2)
                    NSLayoutConstraint.activate([constraints[3]])
                }
            }
        }
    }
}
