// Copyright Max von Webel. All Rights Reserved.

import UIKit

class ImageCollectionViewLayout: UICollectionViewLayout {
    var cellFrames: [CGRect] = []
    var contentWidth = CGFloat(0) {
        didSet {
            if (oldValue != contentWidth) {
                cellFrames = []
            }
        }
    }
    var contentHeight = CGFloat(0)
    var images: [MediaRepresentation] = [] {
        didSet {
            calculateFrames()
        }
    }
    
    func calculateFramesIfNeeded() {
        contentWidth = collectionView!.frame.width
        if cellFrames.count < images.count {
            calculateFrames()
        }
    }
    
    func calculateFrames() {
        let columnCount = min(Int(ceil(contentWidth / 320)), 3)
        let columnWidth = ceil(collectionView!.frame.width / CGFloat(columnCount))
        var cellFrames: [CGRect] = []
        var contentHeight = CGFloat(0)
        for i in 0..<images.count {
            let y = (i - columnCount >= 0) ? cellFrames[i - columnCount].maxY : 0
            let x = columnWidth * CGFloat(i % columnCount)
            let size = images[i].dimensions!.size(width: columnWidth)
            let frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            contentHeight = max(contentHeight, frame.maxY)
            cellFrames.append(frame)
        }
        
        self.cellFrames = cellFrames
        self.contentHeight = contentHeight
    }
    
    override var collectionViewContentSize: CGSize {
        calculateFramesIfNeeded()
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    func layoutAttributes(item: Int) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
        attributes.frame = cellFrames[item]
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        calculateFramesIfNeeded()
        return layoutAttributes(item: indexPath.item)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        calculateFramesIfNeeded()
        return cellFrames.enumerated().compactMap { (offset, frame) in
            if frame.intersects(rect) {
                return self.layoutAttributes(item: offset)
            } else {
                return nil
            }
        }
    }
}
