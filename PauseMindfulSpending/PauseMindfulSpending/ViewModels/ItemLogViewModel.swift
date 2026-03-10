import SwiftUI

class ItemLogViewModel: ObservableObject {
    
    private let firestoreService = FireStoreService()
    
    // let item = firestoreService.fetchItem(uid: <#T##String#>, itemId: <#T##String#>, completion: <#T##([String : Any]?) -> Void#>)
    
    /*
     variables:
     
     viewModel
       |- item
     
     variables i need:
     item.name
     item.createdAt
     for each : item.category (collection), display
     item.cost
     mood stuff = TODO
     item.notes
     item. get timerID and etc.
     
     navigation:
     
     editTimerButton
     editItemButton
     deleteItemButton
     */
    
    func pressedEditTimerButton() {
        print("pressed edit timer")
    }
    
    func pressedEditItemButton() {
        print("pressed edit item")
    }
    
    func pressedDeleteItemButton() {
        print("pressed delete item")
    }
}
