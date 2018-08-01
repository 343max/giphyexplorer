// Copyright Max von Webel. All Rights Reserved.

import UIKit
import AVKit

class ImageCell: UICollectionViewCell {
    weak var playerLayer: AVPlayerLayer?
    var image: Image? {
        didSet {
            let notificationCenter = NotificationCenter.default
            
            notificationCenter.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            self.playerLayer?.removeFromSuperlayer()
            
            guard let image = image else {
                return
            }
            
            let player = AVPlayer(url: image.mp4s["preview"]!.mp4!.url)
            player.automaticallyWaitsToMinimizeStalling = true
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = contentView.bounds
            contentView.layer.addSublayer(playerLayer)
            self.playerLayer = playerLayer
            notificationCenter.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: OperationQueue.main) { _ in
                player.seek(to: CMTime.zero)
                player.play()
            }
            player.play()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        self.image = nil
    }
}

class MasterViewController: UICollectionViewController {
    var detailViewController: DetailViewController? = nil
    var client: GiphyClient!
    var images: [Image] = [] {
        didSet {
            DispatchQueue.main.async {
                self.layout.images = self.images.map { $0.images[MediaRepresentation.mp4previewKey]! }
                self.refreshControl.endRefreshing()
                self.collectionView?.reloadData()
            }
        }
    }
    
    var refreshControl: UIRefreshControl!
    weak var layout: ImageCollectionViewLayout!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let layout = ImageCollectionViewLayout(columnCount: 2)
        collectionView.collectionViewLayout = layout
        self.layout = layout
        
        refreshControl = UIRefreshControl(frame: collectionView.bounds)
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        if images.count == 0 {
            loadMore(reload: true)
        }
    }
    
    @objc func reload() {
        loadMore(reload: true)
    }
    
    func loadMore(reload: Bool) {
        let offset = reload ? 0 : images.count
        
        refreshControl.beginRefreshing()
        client.trending(offset: offset).then { [weak self] (response) in
            guard let self = self else {
                return
            }
            
            let images = response.payload.filter { image in
                guard let preview = image.mp4s[MediaRepresentation.mp4previewKey] else {
                    return false
                }
                return preview.dimensions != nil
            }
            
            if response.page.offset < self.images.count {
                self.images = response.payload
            } else {
                self.images += response.payload
            }
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
//                let object = objects[indexPath.row] as! NSDate
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - CollectionView
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.image = images[indexPath.item]
        return cell
    }
}

