## Contributions: Team 5
**Aby Garcia (Release 30%, Overall 30%):**
- Share Sheet Extension for Amazon — automatically fills in fields when adding an item (title, price, image)
- Dashboard
  - Activity Calendar Widget — tracks adding, completing, and buying items
  - Budget — set budgets for different categories and track spending, including viewing purchase history
- Settings — log out and delete account
- Updated timer cells to be clickable
- Updated and cleaned up UI for consistency: post-timer notification, editing timer, cell view when there is no image, timer cell view, item page, delete item popup, edit category

**Isabella Caballero (Release 20%, Overall 20%):**
- Photo / Camera
  - Implemented photo persistence using Firebase Storage — users can now view items with uploaded photos
  - Wishlist and Timers now grab an image URL to display on their respective pages
  - Image now shows on the item log page and post-timer check-in
  - Users can change the uploaded photo from the Edit Item Log page
- Profile Picture
  - Users can now upload a profile picture, which also displays on the Wishlist page
- Add Item Log / Item Log Page
  - Updated UI to more clearly show which mood the user selected; selection now reflects in other views
- Edit Item Page
  - Applied same mood UI changes; mood changes now reflect on the item log page after editing
- Settings Page
  - Fixed photo/gallery permission display to correctly reflect the user's current permission state
  - Tapping permission toggles now directs users to iPhone Settings; changes reflect when returning to the app

**Melody Rodriguez (Release 30%, Overall 30%):**
- List
  - Added a listener to properly pull items to the Wishlist and Timer list pages
  - Implemented ability to sort by category/status in the Wishlist
  - Implemented ability to sort by ascending/descending in the Timer list
- Item Page
  - Added "Bought Item" and "Revert to Wishlist" buttons to change item status
  - Updated UI
- Edit Item Page
  - Added ability to update the pause timer
- Notifications
  - Added local notifications for timers that can be updated
- Categories
  - Small fix: categories can no longer have duplicate names

**Franchesca Untalan (Release 25%, Overall 25%):**
- Categories
  - Users can now add, edit, and delete categories
  - Access CategoriesView from Edit Item Log and Add Item Log
  - Bug fix: names must be unique when editing categories
- Post-Timer Check-In
  - Timer Manager — listener that waits for timers to end, then adds them to a queue for processing one at a time
  - Gestures — swipe left = mark as bought; swipe right = mark as completed pause; swipe down = adjust timer sheet; reused previous components and built out flows for each action

---
## Deviations
**Affirmation Flow**
Affirmation is now included in the Bought Item flow for Post-Timer Check-In (moved from onboarding per professor feedback)

**Dashboard Stats**
Dashboard stats could not be fully tested yet

**Share Sheet Extension**
Implemented a share sheet extension for Amazon instead of a user-input link field (user input approach was too complicated)

---
## Notes
- Test Account:
  - **Username:** bloom@bloom.com
  - **Password:** abc123
  - Note: The account is a little outdated — interacting with older items may not work correctly at times
- Running on a Physical Device: If you get a signing error ("No Account for Team" or "No profiles found"), go to the target's **Signing & Capabilities** tab in Xcode and change the **Team** to your own Apple ID for both the app and extension targets
- Image loading can be slow at times
- To enable the share sheet extension, verify that the App Group `group.utcs.PauseMindfulSpending` is added to both the app target and the extension target in Signing & Capabilities
