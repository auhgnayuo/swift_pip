//
//  PIPCustomContentView.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/19.
//

import UIKit

/// PIPCustomContentView is the main view for displaying Picture-in-Picture (PiP) content.
/// It manages layout, snapping, collapsing, and adapts its position and constraints based on user interaction and container state.
@objcMembers
public final class PIPCustomContentView: UIView {
    /// Called when the view is added to a superview. Sets up layout and container properties.
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        NSLayoutConstraint.deactivate(customConstraints ?? [])
        customConstraints = nil
        if let containerView {
            containerView.snapEdges = snapEdges
            containerView.snapEdgeInsets = snapEdgeInsets
            containerView.collapseEdges = collapseEdges
            containerView.collapseEdgeInsets = collapseEdgeInsets
            doLayout()
        }
    }
    
    /// The current layout for the content view. Setting this triggers a layout update.
    var layout: PIPCustomLayout? {
        didSet {
            doLayout()
        }
    }
    
    /// The edges to which the content view can snap.
    var snapEdges: UIRectEdge = [] {
        didSet {
            containerView?.snapEdges = snapEdges
        }
    }
    
    /// Insets for snap edges.
    var snapEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            containerView?.snapEdgeInsets = snapEdgeInsets
        }
    }
    
    /// The edges to which the content view can collapse.
    var collapseEdges: UIRectEdge = [] {
        didSet {
            containerView?.collapseEdges = collapseEdges
        }
    }
    
    /// Insets for collapse edges.
    var collapseEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            containerView?.collapseEdgeInsets = collapseEdgeInsets
        }
    }
    
    /// The container view that holds this content view, if any.
    public var containerView: PIPCustomContainerView? {
        return superview as? PIPCustomContainerView
    }
    
    /// Generates a layout based on the current frame and configuration.
    /// - Parameters:
    ///   - contentFrame: The frame to use for layout calculations (defaults to current frame).
    ///   - snap: If true, forces snapping; if false, disables snapping; if nil, uses current state.
    ///   - collapse: If true, forces collapse; if false, disables collapse; if nil, uses current state.
    /// - Returns: The calculated layout, or nil if no container is present.
    func adaptiveLayout(contentFrame: CGRect? = nil, snap: Bool? = nil, collapse: Bool? = nil) -> PIPCustomLayout? {
        guard let containerView else {
            return nil
        }
        let content = contentFrame ?? frame
        let snapContainer = containerView.snapContainer
        let collapseContainer = containerView.collapseContainer
        var top: CGFloat?
        var leading: CGFloat?
        var bottom: CGFloat?
        var trailing: CGFloat?
        var collapseEdge: UIRectEdge?
        // Vertical positioning logic
        if content.midY < snapContainer.midY {
            // Top half
            if collapse == true && collapseEdges.contains(.top) {
                collapseEdge = .top
            } else if collapse == false && collapseEdges.contains(.top) {
                top = 0.0
            } else if snap == true && snapEdges.contains(.top) {
                top = 0.0
            } else if snap == false && snapEdges.contains(.top) {
                top = (content.minY - snapContainer.minY).clamp(0, snapContainer.height - content.height)/snapContainer.height
            } else if content.midY < collapseContainer.minY && collapseEdges.contains(.top) {
                collapseEdge = .top
            } else if content.midY < snapContainer.midY && snapEdges.contains(.top) {
                top = 0.0
            } else {
                top = (content.minY - snapContainer.minY).clamp(0, snapContainer.height - content.height)/snapContainer.height
            }
        } else {
            // Bottom half
            if collapse == true && collapseEdges.contains(.bottom) {
                collapseEdge = .bottom
            } else if collapse == false && collapseEdges.contains(.bottom) {
                bottom = 0.0
            } else if snap == true && snapEdges.contains(.bottom) {
                bottom = 0.0
            } else if snap == false && snapEdges.contains(.bottom) {
                bottom = (snapContainer.maxY - content.maxY).clamp(0, snapContainer.height - content.height)/snapContainer.height
            } else if content.midY > collapseContainer.maxY && collapseEdges.contains(.bottom) {
                collapseEdge = .bottom
            } else if content.midY >= snapContainer.midY && snapEdges.contains(.bottom) {
                bottom = 0.0
            } else {
                bottom = (snapContainer.maxY - content.maxY).clamp(0, snapContainer.height - content.height)/snapContainer.height
            }
        }
        // Horizontal positioning logic
        if content.midX < snapContainer.midX {
            // Left half
            if collapse == true && collapseEdges.contains(.left) {
                collapseEdge = .left
            } else if collapse == false && collapseEdges.contains(.left) {
                leading = 0.0
            } else if snap == true && snapEdges.contains(.left) {
                leading = 0.0
            } else if snap == false && snapEdges.contains(.left) {
                leading = (content.minX - snapContainer.minX).clamp(0, snapContainer.width - content.width)/snapContainer.width
            } else if content.midX < collapseContainer.minX && collapseEdges.contains(.left) {
                collapseEdge = .left
            } else if content.midX >= snapContainer.midX && snapEdges.contains(.left) {
                leading = 0.0
            } else {
                leading = (content.minX - snapContainer.minX).clamp(0, snapContainer.width - content.width)/snapContainer.width
            }
        } else {
            // Right half
            if collapse == true && collapseEdges.contains(.right) {
                collapseEdge = .right
            } else if collapse == false && collapseEdges.contains(.right) {
                trailing = 0.0
            } else if snap == true && snapEdges.contains(.right) {
                trailing = 0.0
            } else if snap == false && snapEdges.contains(.right) {
                trailing = (snapContainer.maxX - content.maxX).clamp(0, snapContainer.width - content.width)/snapContainer.width
            } else if content.midX > collapseContainer.maxX && collapseEdges.contains(.right) {
                collapseEdge = .right
            } else if content.midX >= snapContainer.midX && snapEdges.contains(.right) {
                trailing = 0.0
            } else {
                trailing = (snapContainer.maxX - content.maxX).clamp(0, snapContainer.width - content.width)/snapContainer.width
            }
        }
        
        let layout: PIPCustomLayout = .init(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing,
            collapseEdge: collapseEdge,
        )
        
        return layout
    }
    
    /// Custom constraints currently applied to the content view.
    private var customConstraints: [NSLayoutConstraint]?
    
    /// Applies the current layout to the content view, updating constraints as needed.
    private func doLayout() {
        NSLayoutConstraint.deactivate(customConstraints ?? [])
        customConstraints = nil
        guard let layout, let containerView else {
            translatesAutoresizingMaskIntoConstraints = true
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        containerView.layout = layout
        var constraints = [NSLayoutConstraint]()
        if let collapseEdge = layout.collapseEdge {
            switch collapseEdge {
            case .top:
                constraints.append(bottomAnchor.constraint(equalTo: containerView.collapseLayoutGuide.topAnchor))
            case .left:
                constraints.append(trailingAnchor.constraint(equalTo: containerView.collapseLayoutGuide.leadingAnchor))
            case .bottom:
                constraints.append(topAnchor.constraint(equalTo: containerView.collapseLayoutGuide.bottomAnchor))
            case .right:
                constraints.append(leadingAnchor.constraint(equalTo: containerView.collapseLayoutGuide.trailingAnchor))
            default:
                break
            }
        }
        if layout.top != nil {
            constraints.append(topAnchor.constraint(equalTo: containerView.heightLayoutGuide.topAnchor))
        }
        if layout.leading != nil {
            constraints.append(leadingAnchor.constraint(equalTo: containerView.widthLayoutGuide.leadingAnchor))
        }
        
        if layout.bottom != nil {
            constraints.append(bottomAnchor.constraint(equalTo: containerView.heightLayoutGuide.bottomAnchor))
        }
        if layout.trailing != nil {
            constraints.append(trailingAnchor.constraint(equalTo: containerView.widthLayoutGuide.trailingAnchor))
        }
        NSLayoutConstraint.activate(constraints)
        customConstraints = constraints
    }
}
