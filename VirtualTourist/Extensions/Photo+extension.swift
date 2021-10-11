// 

import Foundation

extension Photo {
    
    var isDataLoaded: Bool {
        return self.data != nil
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
        loadPhotoData()
    }
    
    public override func awakeFromFetch() {
        super.awakeFromFetch()
        
        if !isDataLoaded {
            loadPhotoData()
        }
    }
    
    private func loadPhotoData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let photoUrl: URL = self?.url else { return }
            
            let data = try? Data(contentsOf: photoUrl)
            
            DispatchQueue.main.async {
                // Fail to update is there is no managedObjectContext
                if self?.managedObjectContext != nil {
                    self?.data = data
                }
            }
        }
    }
}
