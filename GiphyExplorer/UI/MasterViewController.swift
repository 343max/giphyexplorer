// Copyright Max von Webel. All Rights Reserved.

import UIKit
import AVKit

extension Image {
    var thumbnail: MediaRepresentation? {
        get {
            guard let thumbnail = self.mp4s[MediaRepresentation.mp4previewKey] else {
                return nil
            }
            
            if thumbnail.mp4 == nil {
                return nil
            }
            
            return thumbnail
        }
    }
    var thumbnailURL: URL? {
        get {
            return thumbnail?.mp4?.url
        }
    }
}

class ImageCell: UICollectionViewCell {
    var promise: DownloadController.AssetPromise? {
        didSet {
            if let promise = promise {
                promise.then {
                    self.startPlaying()
                }
            } else {
                self.cleanUpPlayer()
            }
        }
    }
    
    var isBeingDisplayed = false {
        didSet {
            if isBeingDisplayed {
                self.startPlaying()
            } else {
                player?.pause()
            }
        }
    }
    
    weak var player: AVPlayer?
    weak var playerLayer: AVPlayerLayer?
    
    func startPlaying() {
        guard let localURL = promise?.result?.localURL else {
            return
        }
        
        if (!isBeingDisplayed) {
            return
        }
        
        cleanUpPlayer()
        
        let player = AVPlayer(url: localURL)
        player.automaticallyWaitsToMinimizeStalling = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = contentView.bounds
        contentView.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
        self.player = player
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: OperationQueue.main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }

    }
    
    func cleanUpPlayer() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.playerLayer?.removeFromSuperlayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        promise = nil
    }
}

class MasterViewController: UICollectionViewController {
    let downloadController = DownloadController()
    var detailViewController: DetailViewController? = nil
    var client: GiphyClient!
    var loading = false {
        didSet {
            DispatchQueue.main.async {
                if let refreshControl = self.refreshControl {
                    if self.loading {
                        refreshControl.beginRefreshing()
                    } else {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    var images: [Image] = [] {
        didSet {
            self.layout.images = self.images.map { $0.thumbnail! }
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
        
        collectionView.prefetchDataSource = self
        
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
        assert(!loading)
        loading = true

        let offset = reload ? 0 : images.count
        client.trending(offset: offset).then { [weak self] (response) in
            guard let self = self else {
                return
            }
            
            let images = response.payload.filter { image in
                guard let preview = image.thumbnail else {
                    return false
                }
                return preview.dimensions != nil
            }
            
            DispatchQueue.main.async {
                if response.page.offset < self.images.count {
                    self.images = images
                    self.collectionView.reloadData()
                } else {
                    let indexes = (self.images.count ..< self.images.count + images.count).map { return IndexPath(item: $0, section: 0) }
                    self.images += images
                    self.collectionView.insertItems(at: indexes)
                }
                
                self.loading = false
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
        cell.promise = downloadController.download(url: images[indexPath.item].thumbnailURL!)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ImageCell)?.isBeingDisplayed = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? ImageCell)?.isBeingDisplayed = false
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !loading && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height * 1.5 {
            loadMore(reload: false)
        }
    }
}

extension MasterViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let url = images[indexPath.item].thumbnailURL {
                let _ = downloadController.download(url: url)
            }
        }
    }
}
