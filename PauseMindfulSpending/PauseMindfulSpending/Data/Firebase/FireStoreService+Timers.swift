import FirebaseFirestore

extension FireStoreService {
    func createTimer(
        uid: String,
        durationSeconds: Int,
        completion: @escaping (String?) -> Void) {
        // Used when creating an item. Creates a timer given a duration in seconds and
        // returns the timerId through the completion handler
        
        var data: [String: Any] = [:]
        let now = Date()
        
        data["startDate"] = FieldValue.serverTimestamp()
        data["status"] = "active"
        data["createdAt"] = FieldValue.serverTimestamp()
        data["endDate"] = now.addingTimeInterval(TimeInterval(durationSeconds))
        data["updatedAt"] = FieldValue.serverTimestamp()

        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "timers",
            data: data) { timerId in
                guard let timerId = timerId else {
                    completion(nil)
                    return
                }
                
                completion(timerId)
            }
    }
    
    func pauseTimer (uid: String, timerId: String) {
        // Updates timer status to pause and adds a value of when it is paused
        
        var data: [String: Any] = [:]
        
        data["pausedAt"] = FieldValue.serverTimestamp()
        data["status"] =  "paused"
        data["updatedAt"] = FieldValue.serverTimestamp()
        
        self.updateDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "timers",
            subId: timerId,
            fieldsToUpdate: data
        )
    }
    
    func fetchTimer(
        uid: String,
        timerId: String,
        completion: @escaping ([String: Any]?) -> Void
    ) {
        // Fetches a timer document and passes it through completion handler
        
        self.fetchDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "timers",
            subId: timerId) { data in
            guard let data = data else{
                completion(nil)
                return
            }
                
            completion(data)
        }
    }
    
    func resumeTimer(uid: String, timerId: String) {
        // Resumes a paused timer and updates endDate
        
        self.fetchTimer(uid: uid, timerId: timerId) { timerData in
            guard
                let timerData = timerData,
                let pauseTs = timerData["pausedAt"] as? Timestamp,
                let endTs = timerData["endDate"] as? Timestamp
            else {
                return
            }
                    
            let pausedAt = pauseTs.dateValue()
            let endDate = endTs.dateValue()
            let now = Date()
                    
            let pauseDuration = now.timeIntervalSince(pausedAt)
            let newEndDate = endDate.addingTimeInterval(pauseDuration)
            self.updateDocumentFromSubcollection(
                parentCollection: "users",
                parentId: uid,
                subCollection: "timers",
                subId: timerId,
                fieldsToUpdate: ([
                    "endDate": newEndDate,
                    "pausedAt": FieldValue.delete(),
                    "status": "active",
                    "updatedAt": FieldValue.serverTimestamp()
                ])
            )
        }
    }
    
    func updateTimer(uid: String, timerId: String, newDurationSeconds: Int) {
        // Updates the timer document with a new timer
        // TODO: Rethink timer logic? Currently, just setitng a new timer using same id
        
        let now = Date()
        
        self.updateDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "timers",
            subId: timerId,
            fieldsToUpdate: ([
                "startDate": FieldValue.serverTimestamp(),
                "endDate": now.addingTimeInterval(TimeInterval(newDurationSeconds)),
                "status": "active",
                "updatedAt": FieldValue.serverTimestamp()
            ])
        )
    }
    
    func deleteTimer(uid: String, timerId: String) {
        // Deletes the specified timer document
        
        self.deleteDocumentFromSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "timers",
            subId: timerId
        )
    }
}
