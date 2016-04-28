//
//  RLNetWorkManager.swift
//  V2EX
//
//  Created by LLZ on 16/4/11.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

typealias successBlock = (response:AnyObject) -> Void
typealias errorBlock = () -> Void

typealias callBackBlock = (resArr:NSMutableArray) -> Void


class RLNetWorkManager: NSObject {
    private lazy var sessionManager = {
        return AFHTTPSessionManager()
    }()
    
    static let defaultNetWorkManager = RLNetWorkManager()//单例
    private override init() {}//防止外部用init（）或者（）来初始化这个单例
    //获取节点话题列表
    func requestNodeTopicssWithID(nodeID:String, success:successBlock, failure:errorBlock) -> NSURLSessionDataTask {
        let URLStr = mainURLStr + "/api/topics/show.json?node_id=\(nodeID)"
        let task = sessionManager.GET(URLStr, parameters: nil, success: { (task:NSURLSessionDataTask, responseObject:AnyObject) in
            success(response: responseObject)
            }, failure:  { (task:NSURLSessionDataTask?, error:NSError) in
                let errorData = error.userInfo["com.alamofire.serialization.response.error.data"]
                do {
                    let dic = try NSJSONSerialization.JSONObjectWithData(errorData as! NSData, options: .MutableContainers)
                    print("请求话题失败\(dic.objectForKey("message"))")
                } catch {}
        })
        return task!
    }
    
    //根据url请求
    func requestWithPath(path:String, success:successBlock, failure:errorBlock) -> NSURLSessionDataTask {
        let URLStr = mainURLStr + path
        let task = sessionManager.GET(URLStr, parameters: nil, success: { (task:NSURLSessionDataTask, responseObject:AnyObject) in
            success(response: responseObject)
            }, failure: { (task:NSURLSessionDataTask?, error:NSError) in
                let errorData = error.userInfo["com.alamofire.serialization.response.error.data"]
                do {
                    let dic = try NSJSONSerialization.JSONObjectWithData(errorData as! NSData, options: .MutableContainers)
                    print("请求url失败\(dic.objectForKey("message"))")
                } catch {}
        })
       return task!
    }
    //请求话题数据,block返回(以plist文件缓存话题模型)
    func requestTopicsWithPath(path:String, success:successBlock, failure:errorBlock) -> NSURLSessionDataTask {
        //截取plist文件名(id=xxxxx)
        let range = (path as NSString).rangeOfString("?")
        var plistName = "0000"//初始化
        //存在则表明是单独获取一个话题数据,否则是获取最热话题数组(不缓存)
        if range.location != NSNotFound {
            plistName = (path as NSString).substringToIndex(range.location + 1)
        }
        //获取沙盒路径
        let cahchesPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
         //plist全路径
        let plistPath = cahchesPath! + "/topics/\(plistName).plist"
        
        let fileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(plistPath) {//存在缓存文件(只有请求单个话题才有可能进去)
            let responseObject = NSArray.init(contentsOfFile: plistPath)
            success(response: responseObject!)
            return NSURLSessionDataTask()//返回一个空的task退出方法
        }
        //没有缓存
        let URLStr = mainURLStr + path
        let  task = sessionManager.GET(URLStr, parameters: nil, success: { (task:NSURLSessionDataTask, responseObject:AnyObject) in
            success(response: responseObject)
            }, failure:  { (task:NSURLSessionDataTask?, error:NSError) in
                let errorData = error.userInfo["com.alamofire.serialization.response.error.data"]
                do {
                    let dic = try NSJSONSerialization.JSONObjectWithData(errorData as! NSData, options: .MutableContainers)
                    print("请求话题失败\(dic.objectForKey("message"))")
                } catch {}
        })
        
        return task!
    }
    
    func requestHTMLWithPath(path:String, callBack:callBackBlock) -> NSOperation {
        let URLStr = mainURLStr + path
        let url = NSURL.init(string: URLStr)
        
        let arr = NSMutableArray()
        var range:NSRange = NSRange()
        var substring:NSString = ""
        
        let operation = NSBlockOperation.init { 
            let data = NSData.init(contentsOfURL: url!)//下载html
            var HTMLStr:NSString = NSString.init(data: data!, encoding: NSUTF8StringEncoding)!
            while true {//解析
                range = (HTMLStr.rangeOfString("<td width=\"48\" valign=\"top\" align=\"center\">"))//起点
                if range.location == NSNotFound {//跳出
                    break
                }
                HTMLStr = HTMLStr.substringFromIndex(NSMaxRange(range))//截取起点后面的字符串
                range = HTMLStr.rangeOfString("</tr>")//终点
                substring = HTMLStr.substringToIndex(range.location)//解析结果
                arr.addObject(substring)
            }
            callBack(resArr: arr)
        }
        
        //创建非主队列
        let queue = NSOperationQueue()
        queue.addOperation(operation)//operation.start()
        return operation
    }
}
