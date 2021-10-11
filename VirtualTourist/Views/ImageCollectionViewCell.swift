// 

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            if let data = photo.data {
                imageView.image = UIImage(data: data)
            } else {
                imageView.image = UIImage(named: Constants.UI.imagePlaceholderName)
            }
        }
    }    
}
