//
//  NetWorkTool.swift
//  LTApp
//
//  Created by dong liang on 2025/4/10.
//

import Foundation
import Alamofire

//错误类型
enum NetworkError: Error {
    case invalidUrl
    case noData
    case decodingError
    case severError(message: String)
    case unauthorized
    case custom(message: String)
}

//请求方法
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

extension Bundle {
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "UnKnown"
    }
//    和上面的并不等价，上面是计算属性，每次获取时都会执行return代码，下面的是存储属性，是编译时就会确定的，如果在访问appVersion时infoDictionary还没准备好，那就获取不到正确的值了，app运行期间访问也获取不到的
//    static var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "UnKnown"
    
    static var build: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    static var fullVersion: String {
        return "\(appVersion)(\(build))"
    }
}

struct NetworkConfig {
    static var baseURL: String = BASE_URL
    static var timeout: TimeInterval = 30
    static var defaultHeaders: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "5fu3": "xxOi",
        "User-Agent": "i_xxOi:v\(Bundle.appVersion)",
        "x-locale": "zh-CN",
        "cookie": "locale=zh-CN",
        "did": "debfdc599c9544c58a02f15af571d3aa716f8d1a",
        "referer": BASE_URL
    ]
    
    //修改header
    static func updateHeaders(with token: String?) {
        //guard let token else {} 等同于 guard let token = token else {}，是用同名变量进行可选绑定
        guard let token else {
            defaultHeaders.remove(name: "X-Authorization")
            return
        }
        defaultHeaders.add(name: "X-Authorization", value: token)
    }
}

//定义类RequestInterceptor遵循Alamofire的RequestInterceptor协议
final class RequestInterceptor: Alamofire.RequestInterceptor {
    
}

class NetWorkTool {

}
