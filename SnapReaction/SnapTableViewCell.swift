//
//  SnapTableViewCell.swift
//  SnapReaction
//
//  Created by Dan Kindler on 11/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit

class SnapTableViewCell: UITableViewCell {

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoDateLabel: UILabel!
    @IBOutlet weak var reactionLabel: UILabel!
    
    var snap: Snap?
    static let estimatedCellHeight: CGFloat = 66.0

    let reactionLabelEmojis = ["😂", "😍", "😮", "🙄", "😑"]
    var currentReactionIndex =  0
    let photoIndicationColor = UIColor.colorWithRGB(rgbValue: 0xE92754)
    let videoIndicationColor = UIColor.colorWithRGB(rgbValue: 0x9B55A0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.text = snap?.authorName ?? ""
        indicatorView.backgroundColor = (snap?.type == .Video) ? videoIndicationColor : photoIndicationColor
        
        if let snap = snap, snap.isReactionSnap {
            reactionLabel.isHidden = false
            indicatorView.layer.cornerRadius = indicatorView.frame.size.height / 2

            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                self.changeEmojiLabel()
            })
            
        } else {
            reactionLabel.isHidden = true
            indicatorView.layer.cornerRadius = 3
        }
    }
    
    func changeEmojiLabel() {
        self.reactionLabel.text = self.reactionLabelEmojis[self.currentReactionIndex]
        self.currentReactionIndex = (self.currentReactionIndex + 1) % self.reactionLabelEmojis.count
    }
}
