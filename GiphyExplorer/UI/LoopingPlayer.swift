// Copyright Max von Webel. All Rights Reserved.

import AVKit

class LoopingPlayer: AVPlayer {
    weak var observer: NSObjectProtocol?
    
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        NotificationCenter.default.removeObserver(self)
        super.replaceCurrentItem(with: item)
        if let item = item {
            NotificationCenter.default.addObserver(self, selector: #selector(rewind), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        }
    }
    
    @objc func rewind() {
        seek(to: CMTime.zero)
        play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
