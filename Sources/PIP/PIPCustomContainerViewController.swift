// PIPCustomContainerViewController.swift
// PIP
//
// Created by auhgnayuo on 2025/4/14.
//

import UIKit

/// PIPCustomContainerViewController manages the lifecycle and user interactions of a custom PiP container.
/// It is responsible for adding, removing, and replacing content sources, handling gestures, and managing layout transitions.
@objcMembers
class PIPCustomContainerViewController: UIViewController {
    /// Sets up the main view as a ContainerView and enables user interaction.
    override func loadView() {
        let v = PIPCustomContainerView()
        v.isUserInteractionEnabled = true
        view = v
    }
    
    /// Adds gesture recognizers and performs additional setup after the view is loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    /// Handles layout and animator reset when the device orientation or size class changes.
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let contentView = contentSource?.contentViewController.contentView, contentSource?.controller != nil else {
            return
        }
        let containerView = contentView.containerView
        let layout = contentView.adaptiveLayout()
        animator?.removeAllBehaviors()
        animator = nil
        contentView.layout = layout
        contentView.setNeedsLayout()
        containerView?.layoutIfNeeded()
    }
    
    /// The current content source being managed by the container. Setting this property triggers the appropriate add, remove, or replace logic.
    var contentSource: PIPCustomContentSource? {
        didSet {
            let oldContentSource = oldValue
            let newContentSource = contentSource
            let isAddition = oldContentSource == nil && newContentSource != nil
            let isRemovment = oldContentSource != nil && newContentSource == nil
            let isReplacement = oldContentSource != nil && newContentSource != nil && oldContentSource != newContentSource
            // Determine the type of content source change and call the corresponding handler.
            if isAddition {
                let shouldMove = newContentSource!.sourceView != nil
                if shouldMove {
                    addWithMovement(newContentSource!)
                } else {
                    add(newContentSource!)
                }
            } else if isRemovment {
                let shouldMove = oldContentSource!.sourceView != nil
                if shouldMove && oldContentSource!.shouldRestoreUserInterface {
                    removeWithMovement(oldContentSource!)
                } else {
                    remove(oldContentSource!)
                }
            } else if isReplacement {
                replace(oldContentSource!, newContentSource!)
            }
        }
    }
    
    /// Expands the PiP window to its full size and saves the layout state.
    func expand() {
        guard let contentView = contentSource?.contentViewController.contentView else {
            return
        }
        let layout = contentView.adaptiveLayout(collapse: false)
        if let layout {
            PIPCustomLayout.save(layout: layout)
        }
        animator?.removeAllBehaviors()
        animator = nil
        contentView.layout = layout
        contentView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }
    
    /// Collapses the PiP window to its minimized state and saves the layout state.
    func collapse() {
        guard let contentView = contentSource?.contentViewController.contentView else {
            return
        }
        let layout = contentView.adaptiveLayout(collapse: true)
        if let layout {
            PIPCustomLayout.save(layout: layout)
        }
        animator?.removeAllBehaviors()
        animator = nil
        contentView.layout = layout
        contentView.setNeedsLayout()
        containerView.layoutIfNeeded()
    }
    
    /// Returns the main container view casted to ContainerView.
    var containerView: PIPCustomContainerView {
        return view as! PIPCustomContainerView
    }
    
    /// Pan gesture recognizer for handling drag and move gestures on the PiP window.
    private lazy var panGestureRecognizer = {
        let v = UIPanGestureRecognizer()
        v.delegate = self
        v.addTarget(self, action: #selector(updatePan(_:)))
        return v
    }()
    
    /// Animator for handling dynamic behaviors and animations.
    private var animator: DynamicAnimator?
    
    /// Handles the state changes of the pan gesture recognizer and delegates to the appropriate handler.
    @objc private func updatePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            onPanGestureRecognizedBegin(recognizer)
        case .changed:
            onPanGestureRecognizedChange(recognizer)
        case .cancelled:
            fallthrough
        case .failed:
            fallthrough
        case .ended:
            onPanGestureRecognizerEnded(recognizer)
        default:
            break
        }
    }
}

extension PIPCustomContainerViewController {
    /// Adds a new content source to the container. Handles the initial setup and animation for PiP activation.
    /// Ensures that the content source is valid and not replaced/removed during async operations.
    private func add(_ contentSource: PIPCustomContentSource) {
        let taskId = NSObject()
        contentSource.taskId = taskId
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            guard let controller = contentSource.controller else {
                return
            }
            guard contentSource == controller.contentSource else {
                return
            }
            guard self.contentSource == contentSource else {
                return
            }
            guard contentSource.taskId == taskId else {
                return
            }
            animator?.removeAllBehaviors()
            animator = nil
            contentSource.isPictureInPictureActive = true
            controller.willStartPictureInPicture()
            let contentVC = contentSource.contentViewController
            let contentView = contentVC.contentView
            let containerView = containerView
            addChild(contentVC)
            contentView.alpha = 0
            containerView.addSubview(contentView)
            contentView.layout = PIPCustomLayout.restore(controller.placeholderLayout)
            containerView.layoutIfNeeded()
            contentView.layout = contentView.adaptiveLayout()
            contentView.setNeedsLayout()
            containerView.layoutIfNeeded()
            controller.animate {
                contentView.alpha = 1
            } completion: { _ in
                if contentSource.taskId == taskId {
                    contentVC.didMove(toParent: self)
                    controller.didStartPictureInPicture()
                }
            }
        }
    }
    
    /// Adds a new content source to the container with a movement animation from a source view.
    /// This is used when the PiP window should appear to move from a specific UI element.
    private func addWithMovement(_ contentSource: PIPCustomContentSource) {
        let taskId = NSObject()
        contentSource.taskId = taskId
        let source = contentSource.sourceView!.convert(contentSource.sourceView!.bounds, to: view)
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            guard let controller = contentSource.controller else {
                return
            }
            guard contentSource == controller.contentSource else {
                return
            }
            guard self.contentSource == contentSource else {
                return
            }
            guard contentSource.taskId == taskId else {
                return
            }
            animator?.removeAllBehaviors()
            animator = nil
            contentSource.isPictureInPictureActive = true
            controller.willStartPictureInPicture()
            let contentVC = contentSource.contentViewController
            let contentView = contentVC.contentView
            let containerView = containerView
            self.addChild(contentVC)
            containerView.addSubview(contentView)
            contentView.alpha = 1
            contentView.layout = nil
            contentView.frame = source
            containerView.layoutIfNeeded()
            DispatchQueue.main.async {
                controller.animate {
                    contentView.layout = PIPCustomLayout.restore(controller.placeholderLayout)
                    containerView.layoutIfNeeded()
                    contentView.layout = contentView.adaptiveLayout()
                    contentView.setNeedsLayout()
                    containerView.layoutIfNeeded()
                } completion: { _ in
                    if contentSource.taskId == taskId {
                        contentVC.didMove(toParent: self)
                        controller.didStartPictureInPicture()
                    }
                }
            }
        }
    }
    
    /// Removes the current content source from the container, handling cleanup and animation.
    /// If the content source requires UI restoration, it waits for the restoration to complete before removal.
    private func remove(_ contentSource: PIPCustomContentSource) {
        guard let controller = contentSource.controller else {
            return
        }
        let taskId = NSObject()
        contentSource.taskId = taskId
        contentSource.isPictureInPictureActive = false
        let group = DispatchGroup()
        if contentSource.shouldRestoreUserInterface {
            group.enter()
            controller.restoreUserInterfaceStopWithCompletionHandler { _ in
                group.leave()
            }
        }
        contentSource.shouldRestoreUserInterface = false
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            guard let controller = contentSource.controller else {
                return
            }
            guard contentSource == controller.contentSource else {
                return
            }
            guard contentSource.taskId == taskId else {
                return
            }
            let contentVC = contentSource.contentViewController
            let contentView = contentVC.contentView
            guard children.contains(contentVC) && contentView.superview == containerView else {
                return
            }
            controller.willStopPictureInPicture()
            let containerView = containerView
            let layout = contentVC.contentView.adaptiveLayout()
            if let layout {
                PIPCustomLayout.save(layout: layout)
            }
            animator?.removeAllBehaviors()
            animator = nil
            contentView.layout = layout
            contentView.setNeedsLayout()
            containerView.layoutIfNeeded()
            contentVC.willMove(toParent: nil)
            group.enter()
            controller.animate {
                contentView.alpha = 0
            } completion: { _ in
                group.leave()
            }
            group.notify(queue: .main) {
                if contentSource.taskId == taskId {
                    contentView.removeFromSuperview()
                    contentVC.removeFromParent()
                    controller.didStopPictureInPicture()
                }
                var window = PIPCustomWindow.instance
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0/Double(UIScreen.main.maximumFramesPerSecond)) {
                    let _ = window
                    window = nil
                }
                if PIPCustomWindow.instance?.containerViewController.contentSource == nil {
                    PIPCustomWindow.instance = nil
                }
            }
        }
    }
    
    /// Removes the current content source from the container with a movement animation back to the source view.
    /// This is used when the PiP window should appear to return to a specific UI element. Handles UI restoration if needed.
    private func removeWithMovement(_ contentSource: PIPCustomContentSource) {
        guard let controller = contentSource.controller else {
            return
        }
        let taskId = NSObject()
        contentSource.taskId = taskId
        contentSource.isPictureInPictureActive = false
        let group = DispatchGroup()
        if contentSource.shouldRestoreUserInterface {
            group.enter()
            controller.restoreUserInterfaceStopWithCompletionHandler { _ in
                group.leave()
            }
        }
        contentSource.shouldRestoreUserInterface = false
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            guard let controller = contentSource.controller else {
                return
            }
            guard contentSource == controller.contentSource else {
                return
            }
            guard contentSource.taskId == taskId else {
                return
            }
            let contentVC = contentSource.contentViewController
            let contentView = contentVC.contentView
            guard children.contains(contentVC) && contentView.superview == containerView else {
                return
            }
            controller.willStopPictureInPicture()
            let containerView = containerView
            let sourceView = contentSource.sourceView
            let layout = contentVC.contentView.adaptiveLayout()
            if let layout {
                PIPCustomLayout.save(layout: layout)
            }
            animator?.removeAllBehaviors()
            animator = nil
            contentView.layout = layout
            contentView.setNeedsLayout()
            containerView.layoutIfNeeded()
            sourceView?.superview?.layoutIfNeeded()
            let source = sourceView?.convert(sourceView!.bounds, to: containerView)
            contentVC.willMove(toParent: nil)
            group.enter()
            controller.animate {
                if let source {
                    contentView.layout = nil
                    contentView.frame = source
                    contentView.setNeedsLayout()
                    containerView.layoutIfNeeded()
                } else {
                    contentView.alpha = 0
                }
            } completion: { _ in
                group.leave()
            }
            group.notify(queue: .main) {
                if contentSource.taskId == taskId {
                    contentView.removeFromSuperview()
                    contentVC.removeFromParent()
                    controller.didStopPictureInPicture()
                }
                var window = PIPCustomWindow.instance
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0/Double(UIScreen.main.maximumFramesPerSecond)) {
                    let _ = window
                    window = nil
                }
                if PIPCustomWindow.instance?.containerViewController.contentSource == nil {
                    PIPCustomWindow.instance = nil
                }
            }
        }
    }
    
    /// Replaces the current content source with a new one, animating the transition between the two.
    /// Ensures both sources share the same controller and synchronizes their layout during the transition.
    private func replace(_ oldContentSource: PIPCustomContentSource, _ newContentSource: PIPCustomContentSource) {
        guard let controller = oldContentSource.controller, controller == newContentSource.controller else {
            return
        }
        let taskId = NSObject()
        oldContentSource.taskId = taskId
        newContentSource.taskId = taskId
        let containerView = view as! PIPCustomContainerView
        let oldContentViewController = oldContentSource.contentViewController
        let newContentViewController = newContentSource.contentViewController
        oldContentViewController.willMove(toParent: nil)
        addChild(newContentViewController)
        containerView.addSubview(newContentViewController.view)
        controller.animate {
            newContentViewController.contentView.layout = oldContentViewController.contentView.layout
            newContentViewController.contentView.setNeedsLayout()
            containerView.layoutIfNeeded()
        } completion: { _ in
            if oldContentSource.taskId == taskId {
                oldContentViewController.view.removeFromSuperview()
            }
            if newContentSource.taskId == taskId {
                newContentViewController.didMove(toParent: self)
            }
            if oldContentSource.taskId == taskId {
                oldContentViewController.removeFromParent()
            }
        }
    }
}

// MARK: - Gesture Handling

extension PIPCustomContainerViewController: UIGestureRecognizerDelegate {
    /// Called when a pan gesture begins. Prepares the content view for movement by removing any layout constraints and stopping animations.
    private func onPanGestureRecognizedBegin(_ recognizer: UIPanGestureRecognizer) {
        let contentView = contentSource?.contentViewController.contentView
        if let contentView {
            let frame = contentView.frame
            animator?.removeAllBehaviors()
            animator = nil
            contentView.layout = nil
            contentView.frame = frame
            contentView.setNeedsLayout()
            containerView.layoutIfNeeded()
        } else {
            animator?.removeAllBehaviors()
            animator = nil
        }
    }
    
    /// Called when a pan gesture changes. Updates the position of the content view based on the user's drag.
    private func onPanGestureRecognizedChange(_ recognizer: UIPanGestureRecognizer) {
        guard let contentViewController = contentSource?.contentViewController else {
            return
        }
        let contentView = contentViewController.view as! PIPCustomContentView
        let translation = recognizer.translation(in: recognizer.view)
        let center = contentView.center
        contentView.center = CGPointMake(center.x + translation.x, center.y + translation.y)
        contentView.setNeedsLayout()
        recognizer.setTranslation(.zero, in: recognizer.view)
    }
    
    /// Called when a pan gesture ends. Calculates the final position and animates the content view to snap or collapse points based on velocity and boundaries.
    /// This method uses dynamic behaviors to simulate realistic movement and snapping.
    private func onPanGestureRecognizerEnded(_ recognizer: UIPanGestureRecognizer) {
        guard let contentSource else {
            return
        }
        let velocity = recognizer.velocity(in: recognizer.view)
        let containerView = containerView
        let snapEdges = containerView.snapEdges
        let collapseEdges = containerView.collapseEdges
        let snapContainer = containerView.snapContainer
        let collapseContainer = containerView.collapseContainer
        let contentView = contentSource.contentViewController.contentView
        let content = contentView.frame
        // Constants for dynamic animation
        let vSnap = 1000.0
        let vMax = 2000.0
        let resistance = 13.0
        let strength = 90.0
        let elasticity = 0.0
        let density = 1.0
        // Limit velocity to avoid excessive speed
        let (vx, vy) = limitV(vx: velocity.x, vy: velocity.y, vMax: vMax)
        // Calculate the snap or collapse point based on gesture velocity and boundaries
        let snapPoint = {
            let stopPoint = calculateStopPoint(vx: vx, vy: vy, vSnap: vSnap, content: content, snapEdges: snapEdges, snapContainer: snapContainer)
            return calculateSnapOrCollapsePoint(stopPoint: stopPoint, content: content, snapEdges: snapEdges, collapseEdges: collapseEdges, snapContainer: snapContainer, collapseContainer: collapseContainer)
        }();
        
        // Set up dynamic animator for realistic movement
        animator = {
            let v = DynamicAnimator(referenceView: containerView)
            v.didPause = { [weak self] _ in
                guard let self, let layout = contentView.adaptiveLayout() else {
                    return
                }
                animator?.removeAllBehaviors()
                animator = nil
                contentView.layout = layout
                contentView.setNeedsLayout()
                containerView.layoutIfNeeded()
            }
            return v
        }();
        {
            let v = UIDynamicItemBehavior(items: [contentView])
            v.allowsRotation = false
            v.elasticity = elasticity
            v.density = density
            v.resistance = resistance
            v.action = { [weak contentView] in
                contentView?.setNeedsLayout()
            }
            v.addLinearVelocity(CGPoint(x: vx, y: vy), for: contentView)
            animator?.addBehavior(v)
        }();
        {
            let v = UIFieldBehavior.springField()
            v.position = snapPoint
            v.strength = strength
            v.addItem(contentView)
            animator!.addBehavior(v)
        }()
    }
    
    /// Calculates the stop point for the content view based on the initial velocity and snap rules.
    /// This method determines how far the view should travel before coming to rest, considering resistance and snap edges.
    private func calculateStopPoint(vx: CGFloat, vy: CGFloat, vSnap: CGFloat, content: CGRect, snapEdges: UIRectEdge, snapContainer: CGRect) -> CGPoint {
        let dx = snapContainer.width/2.0 - content.width/2.0
        let dy = snapContainer.height/2.0 - content.height/2.0
        let rx = (vSnap - 1)/dx
        let ry = (vSnap - 1)/dy
        let rMax = max(rx, ry)
        var x, y: CGFloat
        if snapEdges.contains(.left) || snapEdges.contains(.right) {
            x = rx
        } else {
            x = rMax
        }
        
        if snapEdges.contains(.top) || snapEdges.contains(.bottom) {
            y = ry
        } else {
            y = rMax
        }
        let sx = vx/x
        let sy = vy/y
        return CGPoint(x: content.midX + sx, y: content.midY + sy)
    }
    
    /// Determines the final snap or collapse point for the content view after a pan gesture.
    /// This method checks if the view should snap to an edge, collapse, or remain free, based on its position and the allowed edges.
    private func calculateSnapOrCollapsePoint(stopPoint: CGPoint, content: CGRect, snapEdges: UIRectEdge, collapseEdges: UIRectEdge, snapContainer: CGRect, collapseContainer: CGRect) -> CGPoint {
        var x, y: CGFloat
        let frame = CGRect(x: stopPoint.x - content.width/2.0, y: stopPoint.y - content.height/2.0, width: content.width, height: content.height)
        if frame.midY < collapseContainer.minY && collapseEdges.contains(.top) {
            y = collapseContainer.minY - content.height/2.0
        } else if frame.midY > collapseContainer.maxY && collapseEdges.contains(.bottom) {
            y = collapseContainer.maxY + content.height/2.0
        } else if stopPoint.y < snapContainer.midY && snapEdges.contains(.top) {
            y = snapContainer.minY + content.height/2.0
        } else if stopPoint.y >= snapContainer.midY && snapEdges.contains(.bottom) {
            y = snapContainer.maxY - content.height/2.0
        } else if frame.minY <= snapContainer.minY {
            y = snapContainer.minY + content.height/2.0
        } else if frame.maxY > snapContainer.maxY {
            y = snapContainer.maxY - content.height/2.0
        } else {
            y = stopPoint.y.clamp(snapContainer.minY + content.height/2.0, snapContainer.maxY - content.height/2.0)
        }
        if frame.midX < collapseContainer.minX && collapseEdges.contains(.left) {
            x = collapseContainer.minX - content.width/2.0
        } else if frame.midX > collapseContainer.maxX && collapseEdges.contains(.right) {
            x = collapseContainer.maxX + content.width/2.0
        } else if stopPoint.x < snapContainer.midX && snapEdges.contains(.left) {
            x = snapContainer.minX + content.width/2.0
        } else if stopPoint.x >= snapContainer.midX && snapEdges.contains(.right) {
            x = snapContainer.maxX - content.width/2.0
        } else if frame.minX <= snapContainer.minX {
            x = snapContainer.minY + content.width/2.0
        } else if frame.maxX > snapContainer.maxX {
            x = snapContainer.maxX - content.width/2.0
        } else {
            x = stopPoint.x.clamp(snapContainer.minX + content.width/2.0, snapContainer.maxX - content.width/2.0)
        }
        return CGPoint(x: x, y: y)
    }
    
    /// Limits the velocity to a maximum value, preserving the direction.
    /// This prevents the content view from moving too quickly after a pan gesture ends.
    private func limitV(vx: CGFloat, vy: CGFloat, vMax: CGFloat) -> (vx: CGFloat, vy: CGFloat) {
        var vx = vx
        var vy = vy
        let m = max(abs(vx), abs(vy))
        if m > vMax {
            let scale = vMax/m
            vx *= scale
            vy *= scale
        }
        return (vx, vy)
    }
}
