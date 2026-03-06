import FirebaseFirestore

extension FireStoreService {
    func createTimer(
        uid: String,
        durationSeconds: Int,
        completion: @escaping (String?) -> Void
    ) {
        // Used when creating an item. Creates a timer given a duration in seconds and
        // returns the timerId through the completion handler
        
        var data: [String: Any] = [:]
        let now = Date()
        
        data["startDate"] = FieldValue.serverTimestamp()
        data["status"] = "active"
        data["createdAt"] = FieldValue.serverTimestamp()
        data["endDate"] = now.addingTimeInterval(TimeInterval(durationSeconds))
        
        self.addDocumentToSubcollection(
            parentCollection: "users",
            parentId: uid,
            subCollection: "timers",
            data: data
        ) { data in
            if data != nil {
                completion(data)
            }
        }
    }
    
    func pauseTimer (uid: String, timerId: String) {
        // Updates timer status to pause and adds a value of when it is paused
        
        var data: [String: Any] = [:]
        
        data["pausedAt"] = FieldValue.serverTimestamp()
        data["status"] =  "paused"
        
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
            subId: timerId,
        ) { data in
            if data != nil {
                completion(data)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func resumeTimer(uid: String, timerId: String) {
        // Resumes a paused timer and updates endDate
        
        var timerData: [String: Any] = [:]
        
        self.fetchTimer(uid: uid, timerId: timerId) { data in
            if data != nil {
                timerData = data!
            }
        }
        
        if let pauseTs = timerData["pausedAt"] as? Timestamp,
           let endTs = timerData["endDate"] as? Timestamp {
            
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
                    "status": "active"
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
                "status": "active"
            ])
        )
    }
}
