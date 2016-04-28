//
//  NSString+Extension.swift
//  V2EX
//
//  Created by LLZ on 16/3/30.
//  Copyright © 2016年 ucs. All rights reserved.
//

import Foundation

public extension String {
    //String是一个结构体(struct) 所以这里用static,而不用class
    public static func HTMLstringWithBody(body:String) -> String {
        return "<html><head><meta charset=\"utf-8\"><meta http-equiv=\"Content-Type\"content=text/html; charset=utf-8\"/><style>img{width:\(screenW - 17)px !important;}</style></head> <body>\(body)</body></html>"
    }

    
    public static func formatStringByTimeIntervalSince1970(timeInterval:NSTimeInterval) -> String {
        let timeDate = NSDate.init(timeIntervalSince1970: timeInterval)
        let formatter = NSDateFormatter.init()
        formatter.dateStyle = .FullStyle
        formatter.dateFormat = "yyyy-M-d hh:mm:ss a"
        return formatter.stringFromDate(timeDate)
    }
    public static func creatTimeByTimeIntervalSince1970(timeInterval:NSTimeInterval) -> String? {
        let creatTimeDate = NSDate.init(timeIntervalSince1970: timeInterval)
        let nowTimeDate = NSDate.init()
        let sec = nowTimeDate.timeIntervalSinceDate(creatTimeDate)
        
        var timeStr:String?
        if sec > 0 && sec < 60 * 60 {//1分钟~60分钟
            timeStr = "\(Int((sec + 30) / 60))分钟前 ●"
        } else if sec >= 60 * 60 && sec < 60 * 60 * 24 {//1小时~24小时
            timeStr = "\(Int((sec / 60 + 30) / 60))小时前 ●"
        } else if sec >= 60 * 60 * 24 {//天
            timeStr = "\(Int((sec / 60 / 60 + 12) / 24))天前 ●"
        }
        return timeStr
    }
}