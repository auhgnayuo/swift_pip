//
//  DynamicAnimator.swift
//  PIP
//
//  Created by auhgnayuo on 2025/4/20.
//

import UIKit

/// DynamicAnimator is a custom UIDynamicAnimator with delegate callbacks for pause and resume events.
class DynamicAnimator: UIDynamicAnimator, UIDynamicAnimatorDelegate {
    /// Called when the animator is about to resume.
    var willResume: ((DynamicAnimator)->Void)?
    /// Called when the animator has paused.
    var didPause: ((DynamicAnimator)->Void)?
    /// Initializes the animator with a reference view and sets itself as delegate.
    /// - Parameter view: The reference view for dynamic behaviors.
    override init(referenceView view: UIView) {
        super.init(referenceView: view)
        delegate = self
    }

    /// Delegate method called when the animator will resume.
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        willResume?(self)
    }

    /// Delegate method called when the animator did pause.
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        didPause?(self)
    }
}
