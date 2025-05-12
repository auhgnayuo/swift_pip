//
//  MediaViewController.swift
//  Example
//
//  Created by auhgnayuo on 2025/4/15.
//

import NSObject_Rx
import PIP
import RxCocoa
import RxSwift
import UIKit
import WebKit

protocol PIPDelegateEx: PIPDelegate {
    var pipReusableIdentifier: String? { get }
    func pipRequestStop(with handler: @escaping (Bool) -> Void)
}

class MediaView: UIView {
    //    override func willMove(toWindow newWindow: UIWindow?) {
    //        super.willMove(toWindow: newWindow)
    //        debugPrint("----- \(#function) \(newWindow?.description ?? "nil")")
    //    }
    //    override func didMoveToWindow() {
    //        super.didMoveToWindow()
    //        debugPrint("----- \(#function) \(window?.description ?? "nil")")
    //    }
}

class MediaViewController: UIViewController {
    override func loadView() {
        view = MediaView()
    }
    
    convenience init(pipReusableIdentifier: String) {
        self.init()
        self.pipReusableIdentifier = pipReusableIdentifier
    }
    
    var rejectionMessage: String? {
        return isRecording ? "This action will stop your speech in \(title ?? "")" : nil
    }
    
    lazy var pip: PIP? = PIP(delegate: self)
    
    lazy var pipCustomController: PIPCustomController? = {
        let v = PIPCustomController(contentSource: .init(contentViewController: FloatingViewController(), sourceView: sourceView))
        v.delegate = self
        return v
    }()
    
    var pipReusableIdentifier: String?
    
    @objc dynamic var isRecording: Bool = false
    
    @objc dynamic var isPlaying: Bool = true
    
    lazy var sourceView = {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }()
    
    lazy var pushButtonList = {
        let v = UIButton()
        v.setTitle("List", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.rx.controlEvent(.touchUpInside).subscribe {[weak self] _ in
            self?.navigationController?.pushViewController(ListViewController(), animated: true)
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var pushButton0 = {
        let v = UIButton()
        v.setTitle("Audio", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.rx.controlEvent(.touchUpInside).subscribe { [weak self] _ in
            self?.navigationController?.pushViewController(MediaViewController(pipReusableIdentifier: "Audio"), animated: true)
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var pushButton1 = {
        let v = UIButton()
        v.setTitle("Video", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.rx.controlEvent(.touchUpInside).subscribe { [weak self] _ in
            self?.navigationController?.pushViewController(MediaViewController(pipReusableIdentifier: "Video"), animated: true)
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var recordButton = {
        let v = UIButton()
        v.setTitleColor(.blue, for: .normal)
        rx.observe(\.isRecording).subscribe { x in
            v.setTitle(x ? "Stop speak" : "Speak", for: .normal)
        }.disposed(by: rx.disposeBag)
        v.rx.controlEvent(.touchUpInside).subscribe { [weak self] _ in
            guard let self else {
                return
            }
            isRecording = !isRecording
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var playButton = {
        let v = UIButton()
        v.setTitleColor(.blue, for: .normal)
        rx.observe(\.isPlaying).subscribe { x in
            v.setTitle(x ? "Stop play" : "Play", for: .normal)
        }.disposed(by: rx.disposeBag)
        v.rx.controlEvent(.touchUpInside).subscribe { [weak self] _ in
            guard let self else {
                return
            }
            isPlaying = !isPlaying
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var stackView = {
        let v = UIStackView(arrangedSubviews: [pushButtonList, pushButton0, pushButton1, recordButton, playButton])
        v.axis = .horizontal
        v.distribution = .fillEqually
        return v
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = pipReusableIdentifier
        nc = navigationController
        pip?.prepare()
        isPlaying = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isPlaying {
            pip?.startPictureInPicture()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(sourceView)
        view.addSubview(stackView)
        sourceView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-28)
            make.height.equalTo(sourceView.snp.width).multipliedBy(9.0/16.0)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(sourceView)
            make.top.equalTo(sourceView.snp.bottom).offset(20)
            make.width.equalTo(sourceView)
        }
    }
    
    var isRestoring: Bool = false
    
    weak var nc: UINavigationController?
    
    func alert(_ handler: @escaping (_ result: Bool) -> Void) {
        let alertController = UIAlertController(title: "Alert", message: rejectionMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Comfirm", style: .destructive, handler: { _ in
            handler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            handler(false)
        }))
        nc?.present(alertController, animated: true)
    }
}

extension MediaViewController: PIPDelegateEx {
    func pipRequestStop(with handler: @escaping (Bool) -> Void) {
        if !isRecording {
            handler(true)
            return
        }
        alert { result in
            handler(result)
        }
     
    }
}

extension MediaViewController: PIPCustomControllerDelegate {
    func customPictureInPictureControllerWillStartPictureInPicture(pictureInPictureController: PIPCustomController) {
        (pipCustomController?.contentSource?.contentViewController as? FloatingViewController)?.willStart()
        sourceView.isHidden = true
    }
    
    func customPictureInPictureController(_ pictureInPictureController: PIPCustomController, failedToStartPictureInPictureWithError error: any Error) {
        sourceView.isHidden = false
    }
    
    func customPictureInPictureControllerWillStopPictureInPicture(pictureInPictureController: PIPCustomController) {
        if !isRestoring {
            isPlaying = false
        }
        isRestoring = false
    }
    
    func customPictureInPictureControllerDidStopPictureInPicture(pictureInPictureController: PIPCustomController) {
        sourceView.isHidden = false
        (pipCustomController?.contentSource?.contentViewController as? FloatingViewController)?.didStop()
    }
    
    func customPictureInPictureController(_ pictureInPictureController: PIPCustomController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        isRestoring = true
        if let nc = nc {
            if nc.viewControllers.contains(self) {
                nc.popToViewController(self, animated: true)
            } else {
                nc.pushViewController(self, animated: true)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0/Double(UIScreen.main.maximumFramesPerSecond)) {
            completionHandler(true)
        }
        (pipCustomController?.contentSource?.contentViewController as? FloatingViewController)?.restore()
    }
}
