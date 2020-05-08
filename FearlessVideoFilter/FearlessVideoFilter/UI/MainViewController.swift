//
//  ViewController.swift
//  FearlessVideoFilter
//
//  Created by 박정민 on 2020/05/06.
//  Copyright © 2020 Hackday2020. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dummyArr: [VideoInfo] = VideoInfo.makeDummyData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nibName = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "VideoCollectionViewCell")
        
    }
    
    // 파일의 이름과 확장자를 .으로 분리.
    // index 0에는 파일의 이름을 index 1에는 파일의 확장자를 저장하여 배열로 리턴.
    func getURL(_ str: String) -> [String] {
        return str.components(separatedBy: ".")
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 5.0
        return CGSize(width: width, height: width * 0.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let infoData = dummyArr[indexPath.row]
        let videoName = getURL(dummyArr[indexPath.row].videoName)
        if let videoURL = Bundle.main.url(forResource: videoName[0], withExtension: videoName[1]) {
            // 블러처리 해주는 기초적인 클래스 구현 - 현재는 한 구간만 블러 가능
            let filteredItem = FilteredPlayerItem(videoURL: videoURL)
            
            // 블러 시작구간을 start, 끝구간을 end로 설정
            guard let start = Double(dummyArr[indexPath.row].start),
                let end = Double(dummyArr[indexPath.row].end) else { return }
            
            filteredItem.blur(from: start, to: end, animationRate: 1.0)
            let player = AVPlayer(playerItem: filteredItem.playerItem)
            
//            let player = AVPlayer(url: videoURL)
            
            let controller = AVPlayerViewController()
            controller.player = player

            present(controller, animated: true) {
                player.play()
            }
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let infoData = dummyArr[indexPath.row]
        
        let imageURL = getURL(dummyArr[indexPath.row].thumbnailName)
        
        do {
            if let thumbnailURL = Bundle.main.url(forResource: imageURL[0], withExtension: imageURL[1]) {
                let data = try Data(contentsOf: thumbnailURL)
                cell.thumbnailImageView.image = UIImage(data: data)
            }
        } catch let err {
             print("Error : \(err.localizedDescription)")
        }
        
        cell.titleLabel.text = infoData.title
        cell.videoLengthLabel.text = infoData.videoLength
        
        return cell
    }
}

