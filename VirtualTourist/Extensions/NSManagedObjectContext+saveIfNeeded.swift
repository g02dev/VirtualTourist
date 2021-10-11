// 

import Foundation
import CoreData

extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        if self.hasChanges {
            try self.save()
        }
    }
}
