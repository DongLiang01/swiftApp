//
//  ViewController.swift
//  LTApp
//
//  Created by dong liang on 2025/4/9.
//

import UIKit
import SnapKit

class DLViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.orange
        addUI()
    }
    
    func addUI() {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("点击我", for: .normal)
        button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(50)
            make.size.equalTo(CGSize(width: 100, height: 50))
        }
    }
    
    //这个@objc是必须加的，因为UIKit的addTarget是OC时代的API，使用选择器#selector来标识方法，为了与OC的运行时兼容，必须加上@objc
    //加上@IBAction就不用加objc，会隐式的给加上，它是标记可以被 Interface Builder 识别的方法
    @objc func clickButton() {
        print("点击按钮")
    }

}

