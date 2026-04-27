**Group number:** 5

**Team members:** Bella Caballero, Aby Garcia, Melody Rodriguez, Franchesca Untalan

**Name of project:** Pause: Mindful Spending

**Dependencies:** Xcode 16.4, Swift 5.0, Firebase/FireStore (via Swift Package Manager)

**Special Instructions:**
- The Amazon Share Sheet Extension only works locally — Apple Developer account required for external device use
- To enable the Share Sheet Extension, ensure the app group "group.utcs.PauseMindfulSpending" is set for both the app and the extension targets
- If you get a signing error ("No Account for Team" or "No profiles found"), go to Signing & Capabilities in Xcode and set the Team to your own Apple ID for the app and all extension targets
- Image loading may be slow at times
- Test Account: Username: luna@gmail.com / Password: abc123

Feature Description          | Release Planned | Release Actual | Deviations (if any)                                              | Who/Percentage
-----------------------------|-----------------|----------------|------------------------------------------------------------------|-----------------------------
Login / Create Account       | Alpha           | Alpha          | None                                                             | Franchesca (100%); Aby polished UI (Alpha)
Navigation Bar & Tab Root View | Alpha         | Alpha          | None                                                             | Aby (100%)
Manual Item Entry            | Alpha           | Alpha          | None                                                             | Isabella (100%)
Set a Timer View             | Alpha           | Alpha          | None                                                             | Isabella (100%)
Photo Upload for Item        | Alpha           | Beta           | Backend priorities delayed to Beta; implemented with Firebase Storage | Isabella (100%)
Wishlist                     | Alpha           | Alpha          | None                                                             | Melody (100%)
Timer List                   | Alpha           | Alpha          | None                                                             | Melody (100%)
FireStore Backend            | Alpha           | Alpha          | None                                                             | Melody (100%)
Post Timer Check-In          | Alpha           | Beta           | Ran out of time in Alpha; UI stub created; fully implemented in Beta | Franchesca (100%); Aby polished UI (Beta)
Progress Dashboard           | Alpha           | Alpha          | None                                                             | Aby (100%)
Settings Page                | Alpha           | Alpha          | None                                                             | Aby (100%)
Affirmations                 | Alpha           | Beta           | Moved to Bought Item flow per professor feedback                  | Franchesca (100%)
Welcome Back Page            | Alpha           | Dropped        | Removed — added unnecessary friction on app open                 | N/A
Item Log – View, Edit, Delete | Alpha          | Alpha          | None                                                             | Franchesca (100%)
Share Sheet Extension (Amazon) | Beta          | Beta           | Implemented as Share Sheet extension; only works locally due to Apple Developer constraints | Aby (100%)
Item Tagging / Categories    | Beta            | Beta           | None                                                             | Franchesca (80%); Aby polished UI (20%)
Dashboard – Budget Widget    | Beta            | Beta           | Stats could not be fully tested in Beta                          | Aby (100%)
Dashboard – Activity Calendar | Beta           | Beta           | None                                                             | Aby (100%)
Settings – Logout & Delete Account | Beta      | Beta           | None                                                             | Aby (100%)
Timer Cell – Clickable & UI  | Beta            | Beta           | None                                                             | Aby (100%)
Wishlist – Sort by Category/Status | Beta      | Beta           | None                                                             | Melody (100%)
Timer List – Sort Ascending/Descending | Beta  | Beta           | None                                                             | Melody (100%)
Item Page – Bought/Revert Buttons | Beta       | Beta           | None                                                             | Melody (80%); Aby polished UI (20%)
Edit Item – Update Pause Timer | Beta          | Beta           | None                                                             | Melody (100%)
Local Notifications for Timers | Beta         | Beta           | None                                                             | Melody (100%)
Category Duplicate Prevention | Beta           | Beta           | None                                                             | Melody (100%)
Photo Persistence & Display  | Alpha           | Beta           | Delayed from Alpha due to backend complexity                     | Isabella (100%)
Profile Picture Upload       | Beta            | Beta           | None                                                             | Isabella (100%)
Mood Selection UI            | Beta            | Beta           | None                                                             | Isabella (100%)
Settings – Permissions Display | Beta         | Beta           | None                                                             | Isabella (100%)
Post Timer – Timer Manager & Gestures | Beta   | Beta           | None                                                             | Franchesca (100%)
UI Consistency Polish        | Beta            | Beta           | None                                                             | Aby (100%)
Bug Fixes & Final Polish     | Final           | Final          | None                                                             | Aby (35%), Melody (35%), Isabella (15%), Franchesca (15%)
User-Defined Purchase Rules  | Final           | Dropped        | Dropped due to time constraints; stub present                    | N/A
Friction Tools               | Final           | Dropped        | Stretch goal — not implemented                                   | N/A
Auto-Detect from Screenshots | Final           | Dropped        | Stretch goal — not implemented                                   | N/A
