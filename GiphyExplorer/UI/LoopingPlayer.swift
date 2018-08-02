// Copyright Max von Webel. All Rights Reserved.

import AVKit

class LoopingPlayer: AVPlayer {
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        if let currentItem = currentItem {
            NotificationCenter.default.removeObserver(currentItem)
        }
        super.replaceCurrentItem(with: item)
        if let item = item {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item, queue: OperationQueue.main) { _ in
                self.seek(to: CMTime.zero)
                self.play()
            }
        }
    }
}
