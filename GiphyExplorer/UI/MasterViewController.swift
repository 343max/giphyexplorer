// Copyright Max von Webel. All Rights Reserved.

import UIKit
import AVKit

extension Image {
    var thumbnail: MediaRepresentation? {
        get {
            return mp4mediaRepresentation(label: "preview")
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
                self.player.pause()
                self.playerLayer.isHidden = true
            }
        }
    }
    
    var isBeingDisplayed = false {
        didSet {
            if isBeingDisplayed {
                self.startPlaying()
            } else {
                player.pause()
            }
        }
    }
    
    var player: AVQueuePlayer
    var playerLayer: AVPlayerLayer
    var playerLooper: AVPlayerLooper?
    
    required init?(coder aDecoder: NSCoder) {
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        super.init(coder: aDecoder)
        contentView.layer.addSublayer(playerLayer)
        playerLayer.frame = contentView.bounds
    }
    
    func startPlaying() {
        guard let localURL = promise?.result?.localURL else {
            return
        }
        
        if (!isBeingDisplayed) {
            return
        }
        
        let playerItem = AVPlayerItem(url: localURL)
        self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
        self.playerLayer.isHidden = false
        self.player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        promise = nil
    }
}

class MasterViewController: UICollectionViewController {
    let downloadController = DownloadController.shared
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

        collectionView.prefetchDataSource = self
        
        let layout = ImageCollectionViewLayout()
        collectionView.collectionViewLayout = layout
        self.layout = layout
        
        refreshControl = UIRefreshControl(frame: collectionView.bounds)
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
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
                let controller = segue.destination as! DetailViewController
                controller.image = images[indexPath.item]
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
