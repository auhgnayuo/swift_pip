//
//  NavigationController.swift
//  Example
//
//  Created by auhgnayuo on 2025/4/15.
//

import PIP
import UIKit

class NavigationController: UINavigationController {
    func superPushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard let targetDelegate = viewController as? PIPDelegate, let currentDelegate = PIP.current?.delegate as? PIPDelegate, let currentViewController = currentDelegate as? UIViewController else {
            super.pushViewController(viewController, animated: animated)
            return
        }
        
        guard targetDelegate.pipReusableIdentifier != nil && targetDelegate.pipReusableIdentifier == currentDelegate.pipReusableIdentifier else {
            currentDelegate.pipRequestStop { [weak self] result in
                guard let self else {
                    return
                }
                if result {
                    superPushViewController(viewController, animated: animated)
                }
            }
            return
        }

        var viewControllers = viewControllers
        if viewControllers.contains(currentViewController) {
            viewControllers.removeAll { e in
                e == currentViewController
            }
            viewControllers.append(currentViewController)
            super.setViewControllers(viewControllers, animated: true)
            return
        }
        super.pushViewController(currentViewController, animated: animated)
    }
    
    @discardableResult
    func superPopViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        guard let currentDelegate = viewControllers.last as? PIPDelegate else {
            return super.popViewController(animated: animated)
        }
        currentDelegate.pipRequestStop {[weak self] result in
            guard let self, result else {
                return
            }
            superPopViewController(animated: animated)
        }
        return nil
    }
}
