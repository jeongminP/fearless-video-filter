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
import Alamofire
import SDWebImage

final class MainViewController: UIViewController {
    @IBOutlet weak private var collectionView: UICollectionView?
    
    private let dummyArr: [VideoInfo] = VideoInfo.makeDummyData()
    
    // api를 통해 받아온 데이터를 저장하는 배열
    private var infoArr: [Clip] = []
    private var hasNext: Bool = true
    private var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView else { return }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        let nibName = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "VideoCollectionViewCell")
        
        NetworkRequest.shared.requestVideoInfo(api: .videoInfo, method: .get) { [weak self] (response: APIStruct) in
            guard let strongSelf = self,
                let code = response.header.code else { return }
            let body = response.body
            if code == ResponseCode.success.rawValue {
                if let next = body.hasNext {
                    strongSelf.hasNext = next
                }
                if let data = body.clips {
                    strongSelf.infoArr = data
                }
                DispatchQueue.main.async {
                    strongSelf.collectionView?.reloadData()
                }
            } else if code == ResponseCode.failure.rawValue {
                print("Response Failure: code \(code)")
            }
            
        }
    }
    
    // 화면 회전 시 cell size가 업데이트되지 않는 현상 방지
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView?.reloadData()
    }
    
    // 파일의 이름과 확장자를 .으로 분리.
    // index 0에는 파일의 이름을 index 1에는 파일의 확장자를 저장하여 배열로 리턴.
    private func getURL(_ str: String) -> [String] {
        return str.components(separatedBy: ".")
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    // prefetch함수를 이용해 hasNext가 true이면 다음 페이지의 데이터를 요청.
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        dataLoad(indexPaths: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath) as? VideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let infoData = infoArr[indexPath.item]
        
        // thumbnailUrl을 호출할 때, ?type=f480을 호출하기 위한 변수
        if let thumbnailUrlString = infoData.thumbnailUrl,
            let thumbnailImageURL = URL(string: thumbnailUrlString + "?type=f480") {
            cell.setThumbnailImage(with: thumbnailImageURL)
        }
        
        // channelEmblemUrl을 호출할 때, ?type=f200을 호출하기 위한 변수
        if let channelEmblemURLString = infoData.channelEmblemUrl,
            let channelEmblemURL = URL(string: channelEmblemURLString + "?type=f200") {
            cell.setChannelEmblemImage(with: channelEmblemURL)
        }
        
        if let title = infoData.title {
            cell.setTitle(title)
        }
        
        if let channelName = infoData.channelName,
            let duration = infoData.duration {
            let minute: Int = duration / 60
            let seconds: Int = duration % 60
            
            // 초 단위로 이루어진 duration을 시, 분, 초 단위로 분리.
            var component = DateComponents()
            component.setValue(minute, for: .minute)
            component.setValue(seconds, for: .second)
            if let date = Calendar.current.date(from: component) {
                let formatter = DateFormatter()
                if minute > 60 {
                    formatter.dateFormat = "HH:mm:ss"
                } else {
                    formatter.dateFormat = "mm:ss"
                }
                cell.setChannelName(channelName: channelName, videoLength: formatter.string(from: date))
            } else {
                cell.setChannelName(channelName: channelName, videoLength: "")
            }
        }
        
        return cell
    }
    
    // cellForItem 함수와 prefetch 함수에서 호출할 수 있도록 함수로 분리
    private func dataLoad(indexPaths: [IndexPath]) {
        guard let lastIndex = indexPaths.last?.item, lastIndex > infoArr.count - 4, hasNext == true else { return }
        page += 1
        let params: Parameters = ["page": String(page)]
        NetworkRequest.shared.requestVideoInfo(api: .videoInfo, method: .get, parameters: params, encoding: URLEncoding.queryString) { [weak self] (response: APIStruct) in
            guard let strongSelf = self,
                    let code = response.header.code else { return }
            if code == ResponseCode.success.rawValue {
                if let next = response.body.hasNext {
                    strongSelf.hasNext = next
                }
                if let data = response.body.clips {
                    strongSelf.infoArr.append(contentsOf: data)
                }
                DispatchQueue.main.async {
                    strongSelf.collectionView?.reloadData()
                }
            } else if code == ResponseCode.failure.rawValue {
                print("Response Failure: code \(code)")
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 10
        let height = width * 9 / 16 + 55.5
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoIndex = indexPath.row % dummyArr.count
        guard let videoName = dummyArr[videoIndex].videoName,
            let videoURL = Bundle.main.url(forResource: getURL(videoName)[0], withExtension: getURL(videoName)[1]),
            let clipno = infoArr[indexPath.item].clipNo,
            let controller = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController else { return }
        
        controller.clipNo = clipno
        controller.videoURL = videoURL
        navigationController?.pushViewController(controller, animated: false)
    }
}
