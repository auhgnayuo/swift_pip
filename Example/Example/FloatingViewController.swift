//
//  FloatingViewController.swift
//  Example
//
//  Created by auhgnayuo on 2025/4/15.
//

import PIP
import UIKit

class FloatingViewController: PIP.CustomController.ContentViewController {
    lazy var blurEffect = {
        let v = UIBlurEffect(style: .dark)
        return v
    }()

    lazy var effectView = {
        let v = UIVisualEffectView(effect: blurEffect)
        v.isUserInteractionEnabled = false
        return v
    }()
    
    lazy var rectangle = {
        let v = UIView()
        v.backgroundColor = .red
        v.clipsToBounds = true
        return v
    }()
    
    lazy var closeButton = {
        let v = UIButton()
        v.setTitle("Close", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.rx.controlEvent(.touchUpInside).subscribe { [weak self] _ in
            guard let self, let controller, let delegate = controller.delegate as? PIPDelegate else {
                return
            }
            delegate.pipRequestStop(with: { result in
                if result {
                    controller.stopPictureInPicture()
                }
            })
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var restoreButton = {
        let v = UIButton()
        v.setTitle("Restore", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.rx.controlEvent(.touchUpInside).subscribe { [weak self] _ in
            self?.controller?.restoreUserInterface()
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var expandButton = {
        let v = UIButton()
        v.backgroundColor = .yellow
        v.alpha = 0
        v.rx.controlEvent(.touchUpInside).subscribe { [weak self] _ in
            self?.controller?.animate(animations: {
                self?.controller?.expand()
            })
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    private var isRestoring: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
    
    private func resetInsets() {
        guard let containerView = contentView.containerView else {
            return
        }
        let safeAreaInsets = containerView.safeAreaInsets
        snapEdgeInsets = .init(top: safeAreaInsets.top > 0 ? 0 : 14, left: safeAreaInsets.left > 0 ? 0 : 14, bottom: safeAreaInsets.bottom > 0 ? 0 : 14, right: safeAreaInsets.right > 0 ? 0 : 14)
        collapseEdgeInsets = .init(top: 0, left: safeAreaInsets.left > 0 ? 0 : 24, bottom: 0, right: safeAreaInsets.right > 0 ? 0 : 24)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async { [weak self] in
            self?.controller?.animate { [weak self] in
                self?.resetInsets()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.addSubview(rectangle)
        view.addSubview(closeButton)
        view.addSubview(restoreButton)
        view.addSubview(expandButton)
        view.addSubview(effectView)
        
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rectangle.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(CGSizeMake(160, 90)).priority(.high)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(14)
        }
        restoreButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-14)
        }
        expandButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func layout() {
        guard let superview = view.superview else {
            return
        }
        let snapContainer = superview.frame.inset(by: UIEdgeInsets(top: superview.safeAreaInsets.top + snapEdgeInsets.top, left: superview.safeAreaInsets.left + snapEdgeInsets.left, bottom: superview.safeAreaInsets.bottom + snapEdgeInsets.bottom, right: superview.safeAreaInsets.right + snapEdgeInsets.right))
        let collapseContainer = superview.frame.inset(by: UIEdgeInsets(top: superview.safeAreaInsets.top + collapseEdgeInsets.top, left: superview.safeAreaInsets.left + collapseEdgeInsets.left, bottom: superview.safeAreaInsets.bottom + collapseEdgeInsets.bottom, right: superview.safeAreaInsets.right + collapseEdgeInsets.right))
        
        let minX = min(snapContainer.minX, collapseContainer.minX)
        let maxX = max(snapContainer.maxX, collapseContainer.maxX)
        let content = view.frame
        if content.minX < minX {
            effectView.alpha = (minX - content.minX) / content.width
            expandButton.alpha = (minX - content.minX) / content.width
        } else if content.maxX > collapseContainer.maxX {
            effectView.alpha = (content.maxX - maxX) / content.width
            expandButton.alpha = (content.maxX - maxX) / content.width
        } else {
            effectView.alpha = 0
            expandButton.alpha = 0
        }
    }
    
    func willStart() {
        let _ = view
        controller?.animate {
            self.closeButton.alpha = 1
            self.restoreButton.alpha = 1
            self.view.layer.cornerRadius = 16
        }
    }
    
    func didStop() {
        if isRestoring {
            isRestoring = false
        }
    }
    
    func restore() {
        isRestoring = true
        controller?.animate {
            self.expandButton.alpha = 0
            self.closeButton.alpha = 0
            self.restoreButton.alpha = 0
            self.view.layer.cornerRadius = 0
        }
    }
}
