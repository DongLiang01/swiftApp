//
//  AppDelegate.swift
//  LTApp
//
//  Created by dong liang on 2025/4/9.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    //场景配置的方法
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("请求创建新的场景")
        // 当创建新场景时调用
        // 返回一个配置好的 UISceneConfiguration 对象
        //这里会默认传name: Default Configuration，是在info.plist文件里默认配置好的，如果想给某个场景一些特殊的配置，就需要先在info.plist里创建好配置，写一个name，这里再把这个name传进去就好了
        if options.userActivities.first?.activityType == "OpenSecondaryWindow" {
            //判断是哪一个场景，这个值是创建场景时自定义设置的，可以设置不同的配置
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }else{
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }
    
    //场景被丢弃时调用的方法
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 当用户关闭场景或系统回收资源时调用
        // 可以在这里清理与丢弃的场景相关的资源
    }
    
    
}

