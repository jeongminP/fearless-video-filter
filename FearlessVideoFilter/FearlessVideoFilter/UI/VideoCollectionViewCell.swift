//
//  VideoCollectionViewCell.swift
//  FearlessVideoFilter
//
//  Created by 박정민 on 2020/05/07.
//  Copyright © 2020 Hackday2020. All rights reserved.
//

import UIKit
import SDWebImage

final class VideoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var thumbnailImageView: UIImageView?
    @IBOutlet weak private var titleLabel: UILabel?
    @IBOutlet weak private var videoLengthLabel: UILabel?
    @IBOutlet weak private var channelEmblemImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        thumbnailImageView?.image = nil
        channelEmblemImageView?.image = nil
        super.prepareForReuse()
    }
    
    func setThumbnailImage(with url: URL) {
            thumbnailImageView?.sd_setImage(with: url, completed: nil)
    }
    
    func setChannelEmblemImage(with url: URL) {
            channelEmblemImageView?.sd_setImage(with: url, completed: nil)
    }
    
    func setTitle(_ title: String) {
        titleLabel?.text = title
    }
    
    func setChannelName(channelName: String, videoLength: String) {
        videoLengthLabel?.text = channelName + " • " + videoLength
    }

}
