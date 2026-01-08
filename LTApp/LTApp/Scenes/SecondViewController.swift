//
//  SecondViewController.swift
//  LTApp
//
//  Created by dong liang on 2025/4/10.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.blue;
        addUI()
    }
    
    func addUI() {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("去登录", for: .normal)
        button.addTarget(self, action: #selector(goLogin), for: .touchUpInside)
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(50)
            make.size.equalTo(CGSize(width: 100, height: 50))
        }
    }
    
    @objc func goLogin() {
        print("点击登录")
        let controller = LoginViewController()
        controller.testStr = "登录"
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
