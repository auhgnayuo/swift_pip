//
//  ListViewController.swift
//  Example
//
//  Created by auhgnayuo on 2025/4/14.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import NSObject_Rx

class ListViewController: UIViewController {
    
    
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
        v.rx.controlEvent(.touchUpInside).subscribe {[weak self] _ in
            self?.navigationController?.pushViewController(MediaViewController(pipReusableIdentifier: "Audio"), animated: true)
        }.disposed(by: rx.disposeBag)
        return v
    }()
    
    lazy var pushButton1 = {
        let v = UIButton()
        v.setTitle("Video", for: .normal)
        v.setTitleColor(.blue, for: .normal)
        v.rx.controlEvent(.touchUpInside).subscribe {[weak self] _ in
            self?.navigationController?.pushViewController(MediaViewController(pipReusableIdentifier: "Video"), animated: true)
        }.disposed(by: rx.disposeBag)
        return v
    }()
  
    lazy var stackView = {
        let v = UIStackView(arrangedSubviews: [pushButtonList, pushButton0, pushButton1])
        v.axis = .horizontal
        v.distribution = .fillEqually
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide.snp.center)
            make.width.equalToSuperview().offset(-28)
        }
        // Do any additional setup after loading the view.
    }


}

