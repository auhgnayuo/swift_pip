//
//  PIPDelegate.swift
//  PIP
//
//  Created by auhgnayuo on 2025/5/12.
//

import Foundation

/// Delegate protocol for providing custom and system PiP controllers.
@objc public protocol PIPDelegate: NSObjectProtocol {
    /// The custom PiP controller, if any.
    @objc optional var pipCustomController: PIPCustomController? { get }
    /// The system PiP controller, if any.
    @objc optional var pipSystemController: PIPSystemController? { get }
}
