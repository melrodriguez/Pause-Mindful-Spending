import FirebaseFirestore
import FirebaseStorage
import UIKit

extension FireStoreService {
    func uploadPhoto(
        uid: String,
        itemName: String,
        image: UIImage,
        completion: @escaping (String?) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storagePath = "users/\(uid)/items/\(itemName)/photo.jpg"
        let storageRef = Storage.storage().reference().child(storagePath)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    completion(nil)
                    return
                }
                
                self.updateDocumentFromSubcollection(
                    parentCollection: "users",
                    parentId: uid,
                    subCollection: "items",
                    subId : itemName,
                    fieldsToUpdate: [
                        "imageUrl" : downloadURL.absoluteString,
                        "updatedAt" : FieldValue.serverTimestamp()
                    ]
                )
                completion(downloadURL.absoluteString)
            }
        }
    }
    
    func deletePhoto(
        uid: String,
        itemName: String,
        completion: @escaping (Bool) -> Void
    ) {
        let storagePath = "users/\(uid)/items/\(itemName)/photo.jpg"
        let storageRef = Storage.storage().reference().child(storagePath)
        
        storageRef.delete { error in
            guard error == nil else {
                completion(false)
                return
            }
            self.updateDocumentFromSubcollection(
                parentCollection: "users",
                parentId: uid,
                subCollection: "items",
                subId: itemName,
                fieldsToUpdate: [
                    "imageUrl" : FieldValue.delete(),
                    "updatedAt" : FieldValue.serverTimestamp()
                ]
            )
            completion(true)
        }
    }
    
    func uploadProfilePicture(
        uid: String,
        image: UIImage,
        completion: @escaping (String?) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storagePath = "users/\(uid)/profile/photo.jpg"
        let storageRef = Storage.storage().reference().child(storagePath)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    completion(nil)
                    return
                }
                Firestore.firestore().collection("users").document(uid).setData(["photoUrl": downloadURL.absoluteString], merge: true)
                
                completion(downloadURL.absoluteString)
            }
        }
    }
    
    func deleteProfilePicture(
        uid: String,
        completion: @escaping(Bool)->Void
    ) {
        let storagePath = "users/\(uid)/profile/photo.jpg"
        let storageRef = Storage.storage().reference().child(storagePath)
        
        storageRef.delete { error in
            guard error == nil else {
                completion(false)
                return
            }
            Firestore.firestore().collection("users").document(uid).updateData(["photoUrl": FieldValue.delete()])
            completion(true)
        }
    }
}
