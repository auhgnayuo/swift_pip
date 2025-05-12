//
//  CustomControllerContentViewController.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/14.
//

import UIKit

/// ContentViewController manages the view hierarchy for Picture-in-Picture (PiP) content.
/// It configures the ContentView and exposes properties for snap and collapse behavior.
@objcMembers
open class PIPCustomContentViewController: UIViewController {
    /// Sets up the main view as a ContentView and applies snap/collapse configuration.
    override open func loadView() {
        let v = PIPCustomContentView()
        v.snapEdges = snapEdges
        v.snapEdgeInsets = snapEdgeInsets
        v.collapseEdges = collapseEdges
        v.collapseEdgeInsets = collapseEdgeInsets
        v.autoresizingMask = []
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        view = v
    }

    /// Called before the view lays out its subviews.
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    /// Called after the view lays out its subviews.
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    /// The edges to which the content view can snap.
    open var snapEdges: UIRectEdge = [.left, .right] {
        didSet {
            contentView.snapEdges = snapEdges
        }
    }

    /// Insets for snap edges.
    open var snapEdgeInsets: UIEdgeInsets = .init(top: 0, left: 14, bottom: 0, right: 14) {
        didSet {
            contentView.snapEdgeInsets = snapEdgeInsets
        }
    }

    /// The edges to which the content view can collapse.
    open var collapseEdges: UIRectEdge = [.left, .right] {
        didSet {
            contentView.collapseEdges = collapseEdges
        }
    }

    /// Insets for collapse edges.
    open var collapseEdgeInsets: UIEdgeInsets = .init(top: 0, left: 24, bottom: 0, right: 24) {
        didSet {
            contentView.collapseEdgeInsets = collapseEdgeInsets
        }
    }

    /// The controller managing this content view controller.
    open internal(set) weak var controller: PIPCustomController?
    /// The main content view managed by this controller.
    public var contentView: PIPCustomContentView {
        return view as! PIPCustomContentView
    }
}
