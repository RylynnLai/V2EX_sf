//
//  RLReplyCell.swift
//  V2EX
//
//  Created by LLZ on 16/5/13.
//  Copyright © 2016年 LLZ. All rights reserved.
//

import UIKit

class RLReplyCell: UITableViewCell {
    
    var replyModel:Reply? {
        didSet{
            nameLabel.text = replyModel?.member?.username
            floorNum.text = replyModel?.floor?.stringValue
            createdTime.text = String.creatTimeByTimeIntervalSince1970(Double(replyModel!.created!))
            contentLable.text = replyModel?.content
            let iconURL = NSURL.init(string: "http:\(replyModel!.member!.avatar_normal ?? "")")
            authorBtn.sd_setBackgroundImageWithURL(iconURL, forState: .Normal, placeholderImage: UIImage.init(named: "blank"))
            
            authorBtn.layer.cornerRadius = 5
            authorBtn.layer.masksToBounds = true
            floorNum.layer.cornerRadius = floorNum.bounds.size.height * 0.5
            floorNum.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var floorNum: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLable: UILabel!
    @IBOutlet weak var createdTime: UILabel!
    @IBOutlet weak var authorBtn: UIButton!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellHeight() -> CGFloat {
        layoutIfNeeded()
        return contentLable.frame.maxY + 10
    }
}
