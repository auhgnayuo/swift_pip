//
//  PIPCustomContainerView.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/19.
//

import UIKit

/// PIPCustomContainerView is the main container for Picture-in-Picture (PiP) content.
/// It manages snap/collapse regions, layout guides, and provides geometry for PiP positioning.
@objcMembers
public final class PIPCustomContainerView: UIView {
    /// The edges to which content can snap.
    var snapEdges: UIRectEdge = []
    /// The edges to which content can collapse.
    var collapseEdges: UIRectEdge = []
    /// Insets for snap edges, affecting the snap region.
    var snapEdgeInsets: UIEdgeInsets {
        set {
            snapEdgesConstraints[0].constant = newValue.top
            snapEdgesConstraints[1].constant = newValue.left
            snapEdgesConstraints[2].constant = -newValue.bottom
            snapEdgesConstraints[3].constant = -newValue.right
        }
        get {
            return UIEdgeInsets(top: snapEdgesConstraints[0].constant, left: snapEdgesConstraints[1].constant, bottom: -snapEdgesConstraints[2].constant, right: -snapEdgesConstraints[3].constant)
        }
    }

    /// Insets for collapse edges, affecting the collapse region.
    var collapseEdgeInsets: UIEdgeInsets {
        set {
            collapseEdgesConstraints[0].constant = newValue.top
            collapseEdgesConstraints[1].constant = newValue.left
            collapseEdgesConstraints[2].constant = -newValue.bottom
            collapseEdgesConstraints[3].constant = -newValue.right
        }
        get {
            return UIEdgeInsets(top: collapseEdgesConstraints[0].constant, left: collapseEdgesConstraints[1].constant, bottom: -collapseEdgesConstraints[2].constant, right: -collapseEdgesConstraints[3].constant)
        }
    }

    /// The safe area container rect for PiP content.
    public var safeAreaContainer: CGRect {
        return frame.inset(by: safeAreaInsets)
    }

    /// The snap region for PiP content, considering safe area and snap insets.
    public var snapContainer: CGRect {
        return frame.inset(by: UIEdgeInsets(top: safeAreaInsets.top + snapEdgeInsets.top, left: safeAreaInsets.left + snapEdgeInsets.left, bottom: safeAreaInsets.bottom + snapEdgeInsets.bottom, right: safeAreaInsets.right + snapEdgeInsets.right))
    }

    /// The collapse region for PiP content, considering safe area and collapse insets.
    public var collapseContainer: CGRect {
        return frame.inset(by: UIEdgeInsets(top: safeAreaInsets.top + collapseEdgeInsets.top, left: safeAreaInsets.left + collapseEdgeInsets.left, bottom: safeAreaInsets.bottom + collapseEdgeInsets.bottom, right: safeAreaInsets.right + collapseEdgeInsets.right))
    }

    /// Layout guide for the snap region.
    lazy var snapLayoutGuide = {
        let v = UILayoutGuide()
        v.identifier = "Snap"
        addLayoutGuide(v)
        return v
    }()

    /// Layout guide for the collapse region.
    lazy var collapseLayoutGuide = {
        let v = UILayoutGuide()
        v.identifier = "Collapse"
        addLayoutGuide(v)
        return v
    }()

    /// Layout guide for width percentage-based layout.
    lazy var widthLayoutGuide: PIPCustomPercentLayoutGuide = {
        let v = PIPCustomPercentLayoutGuide(dimension: .width)
        v.identifier = "Width"
        addLayoutGuide(v)
        v.parent = snapLayoutGuide
        return v
    }()

    /// Layout guide for height percentage-based layout.
    lazy var heightLayoutGuide: PIPCustomPercentLayoutGuide = {
        let v = PIPCustomPercentLayoutGuide(dimension: .height)
        v.identifier = "Height"
        addLayoutGuide(v)
        v.parent = snapLayoutGuide
        return v
    }()

    /// The current layout for the container. Setting this updates the width/height guides.
    var layout: PIPCustomLayout? {
        didSet {
            if let v = layout?.top ?? layout?.bottom {
                heightLayoutGuide.percent = v
            }
            if let v = layout?.leading ?? layout?.trailing {
                widthLayoutGuide.percent = v
            }
        }
    }

    /// Constraints for snap edges.
    private lazy var snapEdgesConstraints = {
        let v = [
            snapLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            snapLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            snapLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            snapLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ]
        NSLayoutConstraint.activate(v)
        return v
    }()

    /// Constraints for collapse edges.
    private lazy var collapseEdgesConstraints = {
        let v = [
            collapseLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collapseLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collapseLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            collapseLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ]
        NSLayoutConstraint.activate(v)
        return v
    }()
}
