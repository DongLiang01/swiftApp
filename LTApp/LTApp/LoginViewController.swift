//
//  LoginViewController.swift
//  LTApp
//
//  Created by dong liang on 2025/7/11.
//

/**
 swift修饰符：
 1、不写，默认使用的是internal，项目内可以自由访问，继承，调用
 2、private：只在作用域内可以访问调用
 3、fileprivate：在当前文件可以访问调用
 其实正常写项目，就是上面三种修饰符就可以了，如果是做sdk给别人用或者多target之间调用，会涉及到下面
 4、public：别的模块只可以用，但是不能继承以及重写
 5、open：别的模块可以使用、继承、重写
 **/

import UIKit
import SnapKit

struct User: Decodable {
    let followerCount: Int
    let userName: String
}

// 列表包装
struct UserListWrapper: Decodable {
    let rows: [User]
}

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        addUI()
    }
    
    func addUI() {
        self.view.addSubview(self.backBtn)
        self.view.addSubview(self.topLabel)
        self.view.addSubview(self.topSubLabel)
        self.view.addSubview(self.loginBtn)
        
        backBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(54)
            make.leading.equalToSuperview().offset(12)
        }
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(backBtn.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(20)
        }
        topSubLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(10)
            make.leading.equalTo(topLabel)
        }
        loginBtn.snp.makeConstraints { make in
            make.top.equalTo(topSubLabel.snp.bottom).offset(100)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }
    
    @objc func goback() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goLogin() {
        NetWorkTool.share.request("v1/cfd/public/profit/statistics/all", paramters: [
            "rows":"20",
            "page":"1",
        ]) { (result: Result<UserListWrapper, NetworkError>) in
            switch result {
            case .success(let wrapper):
                print("成功获取 \(wrapper.rows.count) 个用户")
                for user in wrapper.rows {
                    print("用户: \(user.userName), 粉丝数: \(user.followerCount)")
                }
            case .failure(let error):
                print("请求失败：\(error)")
            }
        }
    }
    
    private lazy var backBtn: UIButton = {
        let backBtn = UIButton(type: .custom)
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(UIColor.black, for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        backBtn.addTarget(self, action: #selector(goback), for: .touchUpInside)
        return backBtn
    }()
    
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.text = testStr
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    private lazy var topSubLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.text = "Hi，欢迎来到HPX"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var loginBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.orange
        button.setTitle(testStr, for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(goLogin), for: .touchUpInside)
        return button
    }()
    
    var testStr: String = "注册" {
        didSet {
            topLabel.text = testStr
            loginBtn.setTitle(testStr, for: .normal)
        }
    }
    //上面didSet等于是监听，是赋值完成之后，执行里面的代码
    //如果想用OC的那种实现，可以先创建一个私有存储属性，然后通过计算属性的方式来实现get和set方法
    private var _ddStr: String = ""
    var ddStr: String {
        get{
            return _ddStr
        }
        set{
            _ddStr = newValue
            topLabel.text = ddStr;
        }
    }
    
}
