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
        button.setTitle("去登录", for: .normal)
        button.addTarget(self, action: #selector(goLogin), for: .touchUpInside)
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(50)
            make.size.equalTo(CGSize(width: 100, height: 50))
        }
        
        let button1 = UIButton(type: .system)
        button1.backgroundColor = UIColor.white
        button1.setTitle("创建新场景窗口", for: .normal)
        button1.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        view.addSubview(button1)
        button1.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(100)
            make.leading.equalToSuperview().offset(50)
//            make.size.equalTo(CGSize(width: 100, height: 50))
        }
    }
    
    @objc func goLogin() {
        let controller = LoginViewController()
        controller.testStr = "登录"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //这个@objc是必须加的，因为UIKit的addTarget是OC时代的API，使用选择器#selector来标识方法，为了与OC的运行时兼容，必须加上@objc
    //加上@IBAction就不用加objc，会隐式的给加上，它是标记可以被 Interface Builder 识别的方法
    @objc func clickButton() {
        guard UIApplication.shared.supportsMultipleScenes else {
            print("当前设备不支持多窗口！")
            return
        }
        
        let activity = NSUserActivity(activityType: "OpenSecondaryWindow")
        if let session = findExistingWindowSession(name: "secondSceneTag") {
            // 激活现有窗口
            UIApplication.shared.requestSceneSessionActivation(session, userActivity: activity, options: nil) { error in
                print("激活窗口失败：\(error.localizedDescription)")
            }
        }else{
            // 创建新窗口
            print("开始创建新窗口")
            UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
                print("创建窗口失败：\(error.localizedDescription)")
            }
        }
    }
    
    //判断当前open的场景，是否包含想要打开的场景，避免重复创建
    private func findExistingWindowSession(name: String) -> UISceneSession? {
        for session in UIApplication.shared.openSessions {
            if let customSecene = session.scene as? CustomWindowScene,
               customSecene.windowTag == name {
                return session
            }
        }
        return nil
    }

}

