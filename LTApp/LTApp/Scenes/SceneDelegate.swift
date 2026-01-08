//
//  SceneDelegate.swift
//  LTApp
//
//  Created by dong liang on 2025/4/9.
//

import UIKit

//自定义UIWindowScene，可以添加一些标识来区分不同的场景
class CustomWindowScene: UIWindowScene {
    enum WindowType: String {
        case primary   // 窗口1
        case secondary // 窗口2
    }
    var windowType: WindowType = .primary // 默认是窗口1
    var windowTag: String = "unTagged"
}

/**
 app启动时调用：
 1. func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //窗口初始化
    }
 2. func sceneWillEnterForeground(_ scene: UIScene) {
        //场景进入前台
    }
 3. func sceneDidBecomeActive(_ scene: UIScene) {
        //场景进入活动状态
    }
 
 如果info.plist文件里Enable Multiple Scenes设置yes的话，第一步就要调这个方法创建场景了，设置为no的是，不会执行下面，会正常执行上面三个步骤，但是不能创建新的场景窗口了
 func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
     //请求创建场景
 }
 
 启动之后，创建新的场景：
 1. func sceneWillResignActive(_ scene: UIScene) {
        //当前场景窗口先设置为非活动状态
    }
 2.  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) ->   UISceneConfiguration {
          //请求创建场景
      }
 3. func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //窗口初始化
    }
4. func sceneWillEnterForeground(_ scene: UIScene) {
        //场景进入前台
   }
5. func sceneDidBecomeActive(_ scene: UIScene) {
        //场景进入活动状态
   }
 6. func sceneDidEnterBackground(_ scene: UIScene) {上一个场景进入后台}
 **/

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // 1. 场景将要连接到应用程序时调用
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? CustomWindowScene) else {return}
        
        if connectionOptions.userActivities.first?.activityType == "OpenSecondaryWindow" {
            //场景二
            windowScene.windowTag = "secondSceneTag"
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = UINavigationController(rootViewController: SecondViewController())
            window?.makeKeyAndVisible()
            print("次级窗口已初始化：\(windowScene.windowTag)")
        }else{
            windowScene.windowTag = "firstSceneTag"
            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = UINavigationController(rootViewController: DLViewController())
            window?.makeKeyAndVisible()
            print("主窗口已初始化：\(windowScene.windowTag)")
        }
    }

    // 6. 场景即将断开连接时调用
    func sceneDidDisconnect(_ scene: UIScene) {
        // 当场景被系统释放或即将终止时调用
        // 可以在这里释放场景相关的资源
        guard let windowScene = (scene as? CustomWindowScene) else {return}
        
        print("断开状态的场景：\(windowScene.windowTag)")
    }

    // 2. 场景变为活动状态时调用
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 当场景从非活动状态变为活动状态时调用
        // 可以在这里重新启动任何在场景非活动时暂停的任务
        guard let windowScene = (scene as? CustomWindowScene) else {return}
        
        print("进入活动状态的场景：\(windowScene.windowTag)")
    }

    // 3. 场景即将变为非活动状态时调用
    func sceneWillResignActive(_ scene: UIScene) {
        // 当场景从活动状态变为非活动状态时调用
        // 这可能发生在临时中断（如来电）或场景即将进入后台时
        guard let windowScene = (scene as? CustomWindowScene) else {return}
        
        print("进入非活动状态的场景：\(windowScene.windowTag)")
    }

    // 5. 场景即将进入前台时调用
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 当场景从后台进入前台时调用
        // 可以在这里撤销在进入后台时所做的更改
        guard let windowScene = (scene as? CustomWindowScene) else {return}
        
        print("进入前台的场景：\(windowScene.windowTag)")
    }

    // 4. 场景进入后台时调用
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 当场景进入后台时调用
        // 可以在这里保存数据、释放共享资源、存储足够的应用状态信息
        guard let windowScene = (scene as? CustomWindowScene) else {return}
        
        print("进入后台的场景：\(windowScene.windowTag)")
    }


}

