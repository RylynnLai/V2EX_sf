//
//  RLTopicCell.swift
//  V2EX
//
//  Created by LLZ on 16/4/1.
//  Copyright © 2016年 ucs. All rights reserved.
//

import UIKit

class RLTopicCell: UITableViewCell {

    var topicModel:RLTopic? {
        didSet{
            titleLable.text = topicModel?.title
            //以下两项没数据就空白
            contentLable.text = topicModel?.content
            createdTime.text = topicModel?.createdTime
            //-------------------------------------------------
            let iconURL = NSURL.init(string: "http:\(topicModel!.member.avatar_normal!)")
            authorBtn.sd_setBackgroundImageWithURL(iconURL, forState: .Normal, placeholderImage: UIImage.init(named: "blank"))
            nodeLable.text = topicModel?.node.name
            replieNumLable.text = topicModel?.replies
        }
    }
    
    @IBOutlet weak var nodeLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var contentLable: UILabel!
    @IBOutlet weak var createdTime: UILabel!
    @IBOutlet weak var authorBtn: UIButton!
    @IBOutlet weak var replieNumLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorBtn.layer.cornerRadius = 5
        authorBtn.layer.masksToBounds = true
        replieNumLable.layer.cornerRadius = replieNumLable.bounds.size.height * 0.5
        replieNumLable.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
