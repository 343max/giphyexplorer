// Copyright Max von Webel. All Rights Reserved.

import UIKit

extension MediaRepresentation.Size {
    func size(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: floor(width / CGFloat(self.width) * CGFloat(self.height)))
    }
}
