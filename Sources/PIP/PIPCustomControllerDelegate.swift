//
//  PIPCustomControllerDelegate.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/14.
//

import Foundation

/// Protocol for receiving Picture-in-Picture (PiP) controller lifecycle events and error handling.
@objc public protocol PIPCustomControllerDelegate: NSObjectProtocol {
    /// Called before PiP starts.
    /// - Parameter pictureInPictureController: The controller managing PiP.
    @objc optional func customPictureInPictureControllerWillStartPictureInPicture(pictureInPictureController: PIPCustomController)
    /// Called after PiP has started.
    /// - Parameter pictureInPictureController: The controller managing PiP.
    @objc optional func customPictureInPictureControllerDidStartPictureInPicture(pictureInPictureController: PIPCustomController)
    /// Called before PiP stops.
    /// - Parameter pictureInPictureController: The controller managing PiP.
    @objc optional func customPictureInPictureControllerWillStopPictureInPicture(pictureInPictureController: PIPCustomController)
    /// Called after PiP has stopped.
    /// - Parameter pictureInPictureController: The controller managing PiP.
    @objc optional func customPictureInPictureControllerDidStopPictureInPicture(pictureInPictureController: PIPCustomController)
    /// Called if PiP fails to start.
    /// - Parameters:
    ///   - pictureInPictureController: The controller managing PiP.
    ///   - error: The error that occurred.
    @objc optional func customPictureInPictureController(_ pictureInPictureController: PIPCustomController, failedToStartPictureInPictureWithError error: Error)
    /// Called to request restoration of the user interface when PiP stops.
    /// - Parameters:
    ///   - pictureInPictureController: The controller managing PiP.
    ///   - completionHandler: Completion handler to call with true if restoration succeeded.
    @objc optional func customPictureInPictureController(_ pictureInPictureController: PIPCustomController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void)
}
