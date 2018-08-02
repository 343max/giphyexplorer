// Copyright Max von Webel. All Rights Reserved.

import UIKit
import AVKit

extension Image {
    var fullSize: MediaRepresentation? {
        get {
            return mp4mediaRepresentation(label: "original")
        }
    }
    
    var fullSizeURL: URL? {
        get {
            return fullSize?.mp4?.url
        }
    }
}

extension CGRect {
    func align(innerRect: CGRect) -> CGRect {
        var newRect = innerRect
        newRect.origin.x = self.midX - newRect.width / 2
        newRect.origin.y = self.midY - newRect.height / 2
        return newRect
    }
}

class DetailViewController: UIViewController {
    var image: Image? {
        didSet {
            updateLayout()
            if let url = image?.fullSizeURL {
                self.promise = downloadController.download(url: url)
            }
        }
    }
    private var promise: DownloadController.AssetPromise? {
        didSet {
            if let promise = promise {
                promise.then { (asset) in
                    let playerItem = AVPlayerItem(url: asset.localURL)
                    self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
                    self.updateLayout()
                    self.player.play()
                }
            }
        }
    }
    private var downloadController = DownloadController.shared
    private var player: AVQueuePlayer!
    private var playerLayer: AVPlayerLayer!
    private var playerLooper: AVPlayerLooper?

    func updateLayout() {
        guard let videoSize = image?.fullSize?.dimensions?.size(width: view.bounds.width)  else {
            playerLayer.isHidden = true
            return
        }
        
        playerLayer.isHidden = false
        let videoFrame = CGRect(origin: CGPoint.zero, size: videoSize)
        playerLayer.frame = view.bounds.align(innerRect: videoFrame).integral
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.isHidden = true
        self.view.layer.addSublayer(playerLayer)
    }
    
    override func viewDidLayoutSubviews() {
        updateLayout()
    }
}

