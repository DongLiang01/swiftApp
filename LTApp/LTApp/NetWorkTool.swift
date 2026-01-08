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
    case invalidUrl     //无效url
    case noData       //没数据
    case decodingError   //编码错误
    case severError(message: String)  //服务器错误
    case unauthorized     //未授权，比如401未登录状态
    case custom(message: String)  //自定义粗我
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

//请求头配置
struct NetworkConfig {
    static var baseURL: String = BASE_URL
    static var timeout: TimeInterval = 30
    static var defaultHeaders: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "5fu3": "xxOi",
        "User-Agent": "i_xxOi:v\(Bundle.appVersion)",
        "x-locale": "zh-CN",
        "Cookie": "locale=zh-CN",
        "did": "debfdc599c9544c58a02f15af571d3aa716f8d1a",
        "Referer": BASE_URL,
        "X-Authorization":"",
        "Accept-Encoding" : "gzip, deflate, br",
        "Accept-Language" : "zh-Hans-CN;q=1, en-CN;q=0.9",
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

//定义类RequestInterceptor遵循Alamofire的RequestInterceptor协议，主要是拦截请求发出前和发出后，进行统一处理
//final标记无法被继承的类
final class RequestInterceptor: Alamofire.RequestInterceptor {
    //这里是拦截请求发出前
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var adaptedRequest = urlRequest
        //设置统一的header
        for header in NetworkConfig.defaultHeaders {
            adaptedRequest.setValue(header.value, forHTTPHeaderField: header.name)
        }
        completion(.success(adaptedRequest))
    }
    
    //请求失败后的拦截，可以针对一些特殊的失败code进行处理
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        //Swift 的 if let ..., ... 逗号写法，本质是 && 的语法糖，如果是或关系，就得用||
        if let response = request.task?.response as? HTTPURLResponse,
           response.statusCode == 401,
           request.retryCount == 0 {
            //重新请求
            completion(.retry)
        }else{
            completion(.doNotRetry)
        }
    }
}

//最外层数据解析: 遵守 Decodable 协议（也就是能被 JSON 解码的类型）
struct BaseResponse<T: Decodable> : Decodable {
    let code: Int
    let message: String?
    let data: T?
    
    var isSuccess: Bool {
        code == 0 || code == 200
    }
}

class NetWorkTool {
    static let share = NetWorkTool()
    private let session : Session  //请求通过它发起
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkConfig.timeout  //设置请求超时时间
        config.requestCachePolicy = .reloadIgnoringLocalCacheData  //设置缓存策略
        
        let logger = APILogger()
        session = Session(interceptor: RequestInterceptor(), eventMonitors: [logger])  //设置拦截器
    }
    
    //Result<T, NetworkError>是一个swift标准库的泛型枚举，表示一个可能成功也可能失败的结果，这里成功时返回一个泛型T数据，失败时返回我们自定义的错误NetworkError
    //swift里有默认值的参数，调用时就不会提示让你再输入，如果不想要默认值的参数，可以调用时手动去输入参数
    func request<T: Decodable>(_ path: String,
                 method: HTTPMethod = .get,
                 paramters: Parameters? = nil,
                 completion:@escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: NetworkConfig.baseURL + path) else {
            completion(.failure(.invalidUrl))
            return
        }
        session.request(url, parameters: paramters, encoding: URLEncoding.default)
            .validate()  //自动检查响应是否合法，比如检查状态码是否在200-299之间，检查 Content-Type 是否符合预期（如果设置了）；如果不加这个自动检查，像接口500/404这些错误也会被当成成功，除非你在下面的响应里手动去判断，加了这个之后，如果状态码不在正常范围内，会自动执行到下面响应里的failure处
            //responseDecodable会把数据解析成BaseResponse，然后再success那里拿到
            //这里加一个弱引用，是因为闭包内部使用了该对象的方法，使用了self，有个强引用，虽然self并没有持有这个闭包，不会循环引用，但是如果网络慢，页面退出了，这个self就会因为这里有引用而延迟释放，加个弱引用就不会了
            .responseDecodable(of: BaseResponse<T>.self) {[weak self] response in
                print("原始响应状态码:", response.response?.statusCode ?? 0)
                print("原始数据:", String(data: response.data ?? Data(), encoding: .utf8) ?? "空数据")
                
                switch response.result {
                case.success(let baseResponse):
                    if baseResponse.isSuccess, let data = baseResponse.data {
                        completion(.success(data))
                    }else{
                        completion(.failure(.severError(message: baseResponse.message ?? "未知错误")))
                    }
                case.failure(let error):
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 401 {
                            completion(.failure(.unauthorized))
                        }else{
                            //因为用了[weak self]，加了弱引用就是可选的
                            let message = self?.descriptionForStatusCode(statusCode) ?? "未知错误"
                            completion(.failure(.severError(message: message)))
                        }
                    }else{
                        completion(.failure(.custom(message: error.localizedDescription)))
                    }
                }
            }
    }
    
    func descriptionForStatusCode(_ code: Int) -> String {
        switch code {
        case 400: return "请求错误"
        case 401: return "未授权，请登录"
        case 403: return "拒绝访问"
        case 404: return "资源不存在"
        case 500: return "服务器异常"
        default:
            //这是一个系统方法，会根据code返回对应的英文描述，不管什么语言，都会返回英文
            return HTTPURLResponse.localizedString(forStatusCode: code)
        }
    }
}

/// 网络请求日志监控器（带耗时分析），可以对接口时间进行监测
final class APILogger: EventMonitor {
    
    /// 重写 queue 属性，把你自己的串行队列提供给 Alamofire 使用
    let queue = DispatchQueue(label: "com.yourapp.apilogger")

    /// 存储每个请求开始时间
    private let timingStorage = RequestTimingStorage()

//    /// 请求开始时调用，记录时间，需要注意的是这个方法是在resume()之后立即调用的，此时task不一定创建好了，如果没创建好，就没法记录开始时间，所以记录开始时间可以用didCreateTask
//    func requestDidResume(_ request: Request) {
//        if let task = request.task {
//            //用Task包起来是因为await必须在一个async上下文环境才能使用，但是requestDidResume不是一个异步方法，所以加一个Task{}，会启动一个新的并发任务，相当于async上下文，内部就可以使用await了
//            Task{
//                await timingStorage.recordStart(for: task)
//            }
//        }
//        
//        print("➡️➡️➡️ [REQUEST START]")
//        debugPrint(request)
//    }
//
//    /// 请求结束时调用，计算耗时
    func requestDidFinish(_ request: Request) {
        if let task = request.task {
            Task {
                if let duration = await timingStorage.duration(for: task) {
                    print("✅ [FINISH] \(request)")
                    print("⏱️ Duration: \(String(format: "%.3f", duration)) seconds")
                    await timingStorage.remove(for: task)
                }
            }
        }
    }
    
    func request(_ request: Request, didCreateTask task: URLSessionTask) {
        Task {
            await timingStorage.recordStart(for: task)
        }
        print("➡️➡️➡️ [REQUEST START]")
        debugPrint(request)
    }
    
//    //这里不调用，不知道为啥，结束时间监测使用requestDidFinish就行
//    func request(_ request: Request, didCompleteTask task: URLSessionTask, with error: Error?) {
//        Task {
//            if let duration = await timingStorage.duration(for: task) {
//                print("✅ [FINISH] \(request)")
//                print("⏱️ Duration: \(String(format: "%.3f", duration)) seconds")
//                await timingStorage.remove(for: task)
//            }
//        }
//    }

    /// 响应已解析完成，输出响应日志
    func request<T>(_ request: DataRequest, didParseResponse response: DataResponse<T, AFError>) {
        let url = request.request?.url?.absoluteString ?? "<Unknown URL>"
        let method = request.request?.httpMethod ?? "<Unknown Method>"
        let statusCode = response.response?.statusCode ?? -1
        let headers = request.request?.allHTTPHeaderFields ?? [:]

        let requestBody = request.request?.httpBody.flatMap {
            String(data: $0, encoding: .utf8)
        } ?? "<Empty Body>"

        let responseBody = response.data.flatMap {
            String(data: $0, encoding: .utf8)
        } ?? "<No Response Body>"

        print("""
        -----------------------------
        📤 REQUEST:
        URL: \(url)
        METHOD: \(method)
        HEADERS: \(headers)
        BODY: \(requestBody)

        📥 RESPONSE:
        STATUS: \(statusCode)
        BODY:
        \(responseBody)
        -----------------------------
        """)
    }
}

//actor 表示一个线程安全的类，就像一个带锁的对象，它能保证任何时候都只有一个线程能访问它的内部状态
//它和类很像，都是引用类型，可以有属性和方法，可以继承协议，区别就是它是线程安全的，即便你从多个线程访问它的属性，也会自动的串行调度这些操作，还有它不可以被继承，但是可以实现协议，比如两个actor实现同一个协议
//外界访问它的属性和方法必须使用await，因为是异步操作
//为什么它不允许继承，假如一个class继承了它，重写了它的方法，因为没有被actor包裹，就没法保证多线程同时调用的安全性
actor RequestTimingStorage {
    private var startTimes: [URLSessionTask: Date] = [:]
    
    //外界调用方法时都是await，但是这个方法并没有标注async，例如一般func recordStart(for task: URLSessionTask) async这样去写，是因为actor内部隐式的加了
    //但某些时候还是必须显示的加上async，比如方法内部有其他异步操作（包括调用actor内部的其他方法，也是异步操作）
    func recordStart(for task: URLSessionTask) {
        startTimes[task] = Date()
    }

    func duration(for task: URLSessionTask) -> TimeInterval? {
        guard let start = startTimes[task] else { return nil }
        return Date().timeIntervalSince(start)
    }

    func remove(for task: URLSessionTask) {
        startTimes.removeValue(forKey: task)
    }
}

