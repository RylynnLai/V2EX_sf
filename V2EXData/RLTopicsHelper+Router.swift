//
//  RLTopicsHelper+Router.swift
//  V2EX
//
//  Created by rylynn lai on 16/5/8.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import Foundation
import Alamofire

public enum TopicsRouter: URLRequestConvertible {
    case RecentTopics(Int)//最近话题
    case PopTopics//热门话题
    
    //拼装一个URLRequest
    public var URLRequest: NSMutableURLRequest {
        //懒加载，这个是一个元组（路径，方法，参数）
        let result: (path: String, method: Alamofire.Method, parameters: [String: AnyObject]) = {
            switch self {
            case .RecentTopics(let pageIndex):
                return ("/recent?p=\(pageIndex)", .GET, [String: AnyObject]())
            case .PopTopics:
                return ("/api/topics/hot.json", .GET, [String: AnyObject]())
            }
        }()

        let URL = NSURL(string: mainURLStr + result.path)!
        let URLRequest = NSMutableURLRequest(URL: URL)
        URLRequest.HTTPMethod = result.method.rawValue
        URLRequest.timeoutInterval = NSTimeInterval(10 * 1000)

        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
}