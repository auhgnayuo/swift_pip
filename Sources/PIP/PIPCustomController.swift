//
//  PIPCustomController.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/14.
//

import AVKit
import UIKit

/// CustomController is the main entry point for managing Picture-in-Picture (PiP) functionality.
/// It provides APIs to start, stop, expand, collapse, and restore PiP, and manages the content source and delegate callbacks.
@objcMembers
@MainActor
open class PIPCustomController: NSObject {
    /// The content source associated with this controller. Setting this will update the controller reference and may trigger PiP start.
    open var contentSource: PIPCustomContentSource? {
        didSet {
            contentSource?.controller = self
            if contentSource != nil && contentSource != oldValue && oldValue?.isPictureInPictureActive == true {
                startPictureInPicture()
            }
        }
    }
    
    /// The delegate for PiP controller events.
    /// Note: When Picture-in-Picture is active, this delegate will be strongly retained to ensure it remains available during PiP lifecycle events.
    open weak var delegate: PIPCustomControllerDelegate?
    
    /// The default layout used when PiP is first displayed, positioned at 45% from bottom and 0% from trailing edge.
    /// Note: Once the user moves the PiP window, the new layout will be persisted and used for subsequent restorations.
    open var placeholderLayout: PIPCustomLayout = .init(bottom: 0.45, trailing: 0.0)
    
    /// Indicates whether PiP is currently possible on this device.
    open internal(set) dynamic var isPictureInPicturePossible: Bool = true
    
    /// Returns true if PiP is currently active.
    public var isPictureInPictureActive: Bool {
        return contentSource?.isPictureInPictureActive ?? false
    }
    
    /// Returns true if PiP is currently suspended.
    public var isPictureInPictureSuspended: Bool {
        return contentSource?.isPictureInPictureSuspended ?? true
    }
    
    /// Initializes a new CustomController with an optional content source.
    /// - Parameter contentSource: The initial content source to manage.
    public init(contentSource: PIPCustomContentSource? = nil) {
        self.contentSource = contentSource
        super.init()
        contentSource?.controller = self
    }
    
    /// Returns true if PiP is supported on this device.
    open class func isPictureInPictureSupported() -> Bool { return true }
    
    /// Starts Picture-in-Picture mode for the current content source.
    open func startPictureInPicture() {
        assert(contentSource != nil)
        PIPCustomWindow.singleton.containerViewController.contentSource = contentSource
    }
    
    /// Stops Picture-in-Picture mode and optionally restores the user interface.
    open func stopPictureInPicture() {
        contentSource?.shouldRestoreUserInterface = false
        if PIPCustomWindow.instance?.containerViewController.contentSource?.controller == self {
            PIPCustomWindow.instance?.containerViewController.contentSource = nil
        }
    }
    
    /// Requests restoration of the user interface after PiP stops.
    open func restoreUserInterface() {
        contentSource?.shouldRestoreUserInterface = true
        if PIPCustomWindow.instance?.containerViewController.contentSource?.controller == self {
            PIPCustomWindow.instance?.containerViewController.contentSource = nil
        }
    }
    
    /// Expands the PiP window to its full size if this controller is active.
    open func expand() {
        if PIPCustomWindow.instance?.containerViewController.contentSource?.controller == self {
            PIPCustomWindow.instance?.containerViewController.expand()
        }
    }
    
    /// Collapses the PiP window to its minimized state if this controller is active.
    open func collapse() {
        if PIPCustomWindow.instance?.containerViewController.contentSource?.controller == self {
            PIPCustomWindow.instance?.containerViewController.collapse()
        }
    }
    
    /// Performs an animated transition for PiP-related UI changes.
    /// - Parameters:
    ///   - withDuration: The duration of the animation.
    ///   - options: Animation options.
    ///   - animations: The animation block.
    ///   - completion: Completion handler called when the animation finishes.
    open func animate(_ withDuration: TimeInterval = 0.65, options: UIView.AnimationOptions = [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction], animations: @escaping () -> Void, completion: ((_ finished: Bool) -> Void)? = nil) {
        UIView.animate(withDuration: withDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: options, animations: animations, completion: completion)
    }
    
    /// Strong reference to the delegate to ensure it is retained during PiP lifecycle events.
    private var strongDelegate: PIPCustomControllerDelegate?
    /// Strong reference to the PIP delegate for internal use.
    private var strongPipDelegate: PIPDelegate?
    /// Weak reference to the parent PIP instance.
    weak var pip: PIP?
}

extension PIPCustomController {
    /// Called before PiP starts. Retains delegates and notifies the delegate.
    func willStartPictureInPicture() {
        strongDelegate = delegate
        strongPipDelegate = pip?.delegate
        delegate?.customPictureInPictureControllerWillStartPictureInPicture?(pictureInPictureController: self)
    }

    /// Called after PiP has started. Notifies the delegate.
    func didStartPictureInPicture() {
        delegate?.customPictureInPictureControllerDidStartPictureInPicture?(pictureInPictureController: self)
    }

    /// Called before PiP stops. Notifies the delegate.
    func willStopPictureInPicture() {
        delegate?.customPictureInPictureControllerWillStopPictureInPicture?(pictureInPictureController: self)
    }

    /// Called after PiP has stopped. Notifies the delegate and releases strong references.
    func didStopPictureInPicture() {
        delegate?.customPictureInPictureControllerDidStopPictureInPicture?(pictureInPictureController: self)
        strongDelegate = nil
        strongPipDelegate = nil
    }

    /// Called if PiP fails to start. Notifies the delegate and releases strong references.
    /// - Parameter error: The error that occurred.
    func failedToStartPictureInPictureWithError(_ error: Error) {
        delegate?.customPictureInPictureController?(self, failedToStartPictureInPictureWithError: error)
        strongDelegate = nil
        strongPipDelegate = nil
    }

    /// Requests the delegate to restore the user interface when PiP stops.
    /// - Parameter completionHandler: Called with true if restoration succeeded.
    func restoreUserInterfaceStopWithCompletionHandler(_ completionHandler: @escaping (Bool) -> Void) {
        if delegate?.responds(to: #selector(PIPCustomControllerDelegate.customPictureInPictureController(_:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:))) == true {
            delegate?.customPictureInPictureController?(self, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler)
        } else {
            completionHandler(true)
        }
    }
}
