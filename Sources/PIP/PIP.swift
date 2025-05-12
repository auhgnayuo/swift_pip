// The Swift Programming Language
// https://docs.swift.org/swift-book

import AVKit

/// PIP is the main entry point for managing Picture-in-Picture (PiP) functionality in the application.
/// It coordinates custom and system PiP controllers, manages the delegate, and provides APIs for PiP lifecycle control.
@objcMembers
@MainActor
open class PIP: NSObject, @unchecked Sendable {

    /// Initializes a new PIP instance with an optional delegate.
    /// - Parameter delegate: The delegate providing PiP controllers.
    public init(delegate: PIPDelegate? = nil) {
        self.delegate = delegate
    }
    
    /// The current active PIP instance (global singleton).
    public internal(set) nonisolated(unsafe) weak static var current: PIP?
    
    /// The delegate providing PiP controllers.
    /// Note: When Picture-in-Picture is active, this delegate will be strongly retained to ensure it remains available during PiP lifecycle events.
    open weak var delegate: PIPDelegate?
    
    /// Strong reference to the delegate to ensure it is retained during PiP lifecycle events.
    private var strongDelegate: PIPDelegate?
    
    /// Returns true if either the custom or system PiP controller is currently active.
    open var isPictureInPictureActive: Bool {
        return customController?.isPictureInPictureActive == true || systemController?.isPictureInPictureActive == true
    }
    
    /// Prepares the PIP instance for use, handling controller switching and state restoration.
    open func prepare() {
        let current = PIP.current
        if self == current {
            /// Controller unchanged, restore UI
            restoreUserInterface()
            return
        }
        /// Controller changed
        if #available(iOS 14.2, *) {
            /// Disable auto-play for old system controller
            current?.systemController?.realCanStartPictureInPictureAutomaticallyFromInline = false
            if let systemController {
                /// Re-assign auto-play for new system controller
                systemController.realCanStartPictureInPictureAutomaticallyFromInline = systemController.canStartPictureInPictureAutomaticallyFromInline
            }
        }
        /// Stop PiP for old controller
        current?.stopPictureInPicture()
        /// Set current controller
        PIP.current = self
    }
    
    /// Starts Picture-in-Picture mode using the custom or system controller.
    open func startPictureInPicture() {
        if self != PIP.current {
            return
        }
        if let customController {
            customController.startPictureInPicture()
        } else if let systemController {
            if systemController.isPictureInPicturePossible {
                systemController.startPictureInPicture()
            }
        }
    }
    
    /// Stops Picture-in-Picture mode for both custom and system controllers.
    open func stopPictureInPicture() {
        customController?.stopPictureInPicture()
        systemController?.stopPictureInPicture()
    }
    
    /// Requests restoration of the user interface after PiP stops.
    open func restoreUserInterface() {
        customController?.restoreUserInterface()
    }
        
    /// The custom PiP controller provided by the delegate, if any. Sets the pip property for back-reference.
    open var customController: PIPCustomController? {
        if let customController = delegate?.pipCustomController {
            customController?.pip = self
            return customController
        }
        return nil
    }
    
    /// The system PiP controller provided by the delegate, if any. Sets the pip property for back-reference.
    open var systemController: PIPSystemController? {
        if let systemController = delegate?.pipSystemController {
            systemController?.pip = self
            return systemController
        }
        return nil
    }
}
