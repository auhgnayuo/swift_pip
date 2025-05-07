//
//  CustomControllerContentSource.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/14.
//

import UIKit

extension PIP.CustomController {
    /// ContentSource represents the source of content for Picture-in-Picture (PiP) mode.
    /// It holds references to the content view controller and the originating source view, and manages PiP state.
    @objcMembers
    open class ContentSource: NSObject {
        /// The view controller that provides the content for PiP.
        public let contentViewController: ContentViewController
        /// The view from which the PiP window originates, if any.
        public let sourceView: UIView?
        /// The controller managing this content source. Setting this updates the controller reference in the content view controller.
        @MainActor
        public internal(set) weak var controller: PIP.CustomController? {
            didSet {
                contentViewController.controller = controller
            }
        }

        /// Initializes a new ContentSource.
        /// - Parameters:
        ///   - contentViewController: The view controller providing PiP content.
        ///   - sourceView: The originating view for PiP (optional).
        public init(contentViewController: ContentViewController, sourceView: UIView? = nil) {
            self.sourceView = sourceView
            self.contentViewController = contentViewController
        }

        /// Indicates whether PiP is currently active for this content source.
        var isPictureInPictureActive: Bool = false
        /// Indicates whether PiP is currently suspended for this content source.
        var isPictureInPictureSuspended: Bool = false
        /// Indicates whether the user interface should be restored when PiP stops.
        var shouldRestoreUserInterface = false
        /// Task identifier for async operations and state tracking.
        var taskId: NSObject?
    }
}
