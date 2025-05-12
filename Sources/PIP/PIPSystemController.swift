//
//  PIPSystemController.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/14.
//

import AVKit

/// SystemController is a wrapper around AVPictureInPictureController for system-level PiP management.
/// It manages delegate forwarding, PiP state, and compatibility with different iOS versions.
@objcMembers
open class PIPSystemController: AVPictureInPictureController {
    /// Initializes the system PiP controller with a content source (iOS 15+).
    /// - Parameter contentSource: The AVKit content source for PiP.
    @available(iOS 15.0, *)
    override public init(contentSource: AVPictureInPictureController.ContentSource) {
        super.init(contentSource: contentSource)
        super.delegate = self
    }

    /// The delegate for PiP controller events. This property is overridden to allow custom forwarding.
    /// Note: When Picture-in-Picture is active, this delegate will be strongly retained to ensure it remains available during PiP lifecycle events.
    override open weak var delegate: AVPictureInPictureControllerDelegate? {
        get {
            return realDelegate
        }
        set {
            realDelegate = newValue
        }
    }

    /// Whether PiP can start automatically from inline (iOS 14.2+).
    @available(iOS 14.2, *)
    override open var canStartPictureInPictureAutomaticallyFromInline: Bool {
        get {
            return _canStartPictureInPictureAutomaticallyFromInline
        }
        set {
            _canStartPictureInPictureAutomaticallyFromInline = newValue
        }
    }

    /// The real system property for automatic PiP start (iOS 14.2+).
    @available(iOS 14.2, *)
    var realCanStartPictureInPictureAutomaticallyFromInline: Bool {
        set {
            super.canStartPictureInPictureAutomaticallyFromInline = true
        }
        get {
            return super.canStartPictureInPictureAutomaticallyFromInline
        }
    }

    /// Strong reference to the delegate to ensure it is retained during PiP lifecycle events.
    fileprivate var strongDelegate: AVPictureInPictureControllerDelegate?
    /// Internal property for tracking automatic PiP start.
    private var _canStartPictureInPictureAutomaticallyFromInline = false
    /// The real delegate for PiP events.
    private weak var realDelegate: AVPictureInPictureControllerDelegate?
    /// Strong reference to the PIP delegate for internal use.
    private var strongPIPDelegate: PIPDelegate?
    /// Weak reference to the parent PIP instance.
    weak var pip: PIP?
}

/// AVPictureInPictureControllerDelegate conformance for SystemController.
extension PIPSystemController: @preconcurrency AVPictureInPictureControllerDelegate {
    /// Called before PiP starts. Retains delegates and notifies the real delegate.
    @MainActor
    open func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        strongDelegate = delegate
        strongPIPDelegate = pip?.delegate
        realDelegate?.pictureInPictureControllerWillStartPictureInPicture?(pictureInPictureController)
    }

    /// Called after PiP has started. Notifies the real delegate.
    open func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        realDelegate?.pictureInPictureControllerDidStartPictureInPicture?(pictureInPictureController)
    }

    /// Called before PiP stops. Notifies the real delegate.
    open func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        realDelegate?.pictureInPictureControllerWillStopPictureInPicture?(pictureInPictureController)
    }

    /// Called after PiP has stopped. Releases strong references and notifies the real delegate.
    open func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        strongDelegate = nil
        strongPIPDelegate = nil
        realDelegate?.pictureInPictureControllerDidStopPictureInPicture?(pictureInPictureController)
    }

    /// Called if PiP fails to start. Releases strong references and notifies the real delegate.
    /// - Parameters:
    ///   - pictureInPictureController: The controller managing PiP.
    ///   - error: The error that occurred.
    open func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: any Error) {
        strongDelegate = nil
        strongPIPDelegate = nil
        realDelegate?.pictureInPictureController?(pictureInPictureController, failedToStartPictureInPictureWithError: error)
    }

    /// Requests the delegate to restore the user interface when PiP stops.
    /// - Parameters:
    ///   - pictureInPictureController: The controller managing PiP.
    ///   - completionHandler: Completion handler to call with true if restoration succeeded.
    open func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        if delegate?.responds(to: #selector(AVPictureInPictureControllerDelegate.pictureInPictureController(_:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:))) == true {
            delegate?.pictureInPictureController?(pictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler)
        } else {
            completionHandler(true)
        }
    }
}
