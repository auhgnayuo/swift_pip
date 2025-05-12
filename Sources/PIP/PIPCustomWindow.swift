//
//  PIPCustomWindow.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/14.
//

import UIKit

/// Window is a custom UIWindow subclass used for displaying Picture-in-Picture (PiP) content.
/// It manages the root container view controller and handles window-level configuration.
@objcMembers
public final class PIPCustomWindow: UIWindow {
    /// Initializes the window with a frame and sets up the root view controller and window level.
    override init(frame: CGRect) {
        super.init(frame: frame)
        rootViewController = PIPCustomContainerViewController()
        windowLevel = UIWindow.Level(min(UIWindow.Level.alert.rawValue, UIWindow.Level.statusBar.rawValue) - 1.0)
    }

    /// Initializes the window with a UIWindowScene (iOS 13+), sets up the root view controller and window level.
    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        rootViewController = PIPCustomContainerViewController()
        windowLevel = UIWindow.Level(min(UIWindow.Level.alert.rawValue, UIWindow.Level.statusBar.rawValue) - 1.0)
    }

    /// Unavailable initializer for decoding from a storyboard or nib.
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Singleton instance of the PiP window. Creates and shows the window if needed.
    static var singleton: PIPCustomWindow {
        if instance == nil {
            if #available(iOS 13.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    instance = PIPCustomWindow(windowScene: scene)
                } else {
                    instance = PIPCustomWindow(frame: UIScreen.main.bounds)
                }
            } else {
                instance = PIPCustomWindow(frame: UIScreen.main.bounds)
            }
            instance?.makeKeyAndVisible()
        }
        return instance!
    }

    /// The current instance of the PiP window, if any.
    static var instance: PIPCustomWindow?
    /// The root container view controller managing PiP content.
    var containerViewController: PIPCustomContainerViewController {
        return rootViewController as! PIPCustomContainerViewController
    }

    /// Custom hit testing to only allow touches within the PiP content view.
    /// - Parameters:
    ///   - point: The point to test.
    ///   - event: The event associated with the touch.
    /// - Returns: The view that should receive the touch, or nil if outside PiP content.
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if containerViewController.contentSource?.contentViewController.view.frame.contains(point) == true {
            return super.hitTest(point, with: event)
        }
        return nil
    }
}
