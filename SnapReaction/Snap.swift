//
//  Snap.swift
//  SnapReaction
//
//  Created by Dan Kindler on 11/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit

class Snap: NSObject {
    enum SnapType {
        case Photo
        case Video
    }
    
    var authorName: String?
    var length: Int?
    var mediaFileName: String?
    var type: SnapType?
    var isReactionSnap: Bool
    
    init(from authorName: String, length: Int, photoFileName: String, reactionSnap: Bool) {
        self.type = .Photo
        self.authorName = authorName
        self.length = length
        self.mediaFileName = photoFileName
        self.isReactionSnap = reactionSnap
    }
    
    init(from authorName: String, length: Int, videoFileName: String, reactionSnap: Bool) {
        self.type = .Video
        self.authorName = authorName
        self.length = length
        self.mediaFileName = videoFileName
        self.isReactionSnap = reactionSnap
    }
}
