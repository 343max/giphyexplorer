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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var image: Image? {
        didSet {
            DispatchQueue.main.async {
                self.updateLayout()
            }
            if let url = image?.fullSizeURL {
                self.promise = downloadController.download(url: url)
            }
        }
    }
    private var promise: DownloadController.AssetPromise? {
        didSet {
            if let promise = promise {
                promise.then { (asset) in
                    DispatchQueue.main.async {
                        let playerItem = AVPlayerItem(url: asset.localURL)
                        self.player.replaceCurrentItem(with: playerItem)
                        self.updateLayout()
                        self.player.play()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    private var downloadController = DownloadController.shared
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!

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
        
        player = LoopingPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.isHidden = true
        self.view.layer.addSublayer(playerLayer)
    }
    
    override func viewDidLayoutSubviews() {
        updateLayout()
    }
}

