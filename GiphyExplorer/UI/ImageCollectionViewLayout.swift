// Copyright Max von Webel. All Rights Reserved.

import UIKit

extension MediaRepresentation.Size {
    func size(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: floor(width / CGFloat(self.width) * CGFloat(self.height)))
    }
}

class ImageCollectionViewLayout: UICollectionViewLayout {
    let columnCount: Int
    var cellFrames: [CGRect] = []
    var contentHeight = CGFloat(0)
    var images: [MediaRepresentation] = [] {
        didSet {
            calculateFrames()
        }
    }
    
    init(columnCount: Int) {
        self.columnCount = columnCount
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
    }
    
    func calculateFrames() {
        assert(columnCount > 0)
        
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
        return CGSize(width: collectionView!.bounds.width, height: contentHeight)
    }
    
    func layoutAttributes(item: Int) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
        attributes.frame = cellFrames[item]
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes(item: indexPath.item)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cellFrames.enumerated().compactMap { (offset, frame) in
            if frame.intersects(rect) {
                return self.layoutAttributes(item: offset)
            } else {
                return nil
            }
        }
    }
}
