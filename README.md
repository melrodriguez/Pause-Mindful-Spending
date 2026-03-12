## Contributions

**Aby:**
- Navigation bar and root view to switch between tabs and add an item
- Home page/dashboard: editing the dashboard and widgets, adding widgets
- Widgets for different stats, retrieved and calculated from the database: impulses resisted, pause streaks, and money saved
- Settings page: night mode and haptics, loading in user profile and settings
- Polished views for login and create account page

**Isabella:**
- Created the add item view and functionality for that workflow, including retrieving categories
- Created the set a timer view and logic, giving the option to edit and set a timer
- Item logged indicator view on completion
- Researched and set up camera permissions

**Melody:**
- Set up most of the backend: Added a FireStoreService class with multiple extensions for the User, Categories, Items, Events, Settings, and Timers logic
- Wishlist: Fetches the names of the items and displays the list
- Timer List: Fetches the timers and uses a single Timer in ViewModel to display the duration left of all timers efficiently
- Connected Settings Page single card view to the Wishlist and Timer views, so that it changes the display type of the list

**Franchesca:**
- Authentication (App Startup) Flow: Set up the app startup flow and enabled users to login or create an account + login
- Item Log: Enabled users to view each of their items individually, edit its attributes, and delete items, accessible from the Wishlist page
- Post Timer Check-in: Ran out of time to implement this feature but created the UI for it. Harder than expected ;-;

---

## Deviations

**Photo Upload of Item**
We currently do not have the ability to upload and load item photos. There is a lot of backend logic to our app when it comes to the database and we wanted to make sure that our app correctly updates and fetches from the database before we implement the image logic.

**Welcome Back Page**
We removed this page based on the feedback we received from our design. The welcome back page would add an unnecessary step when opening the app.

**Post Timer Check-in**
We ended up not having enough time to implement the post timer check in. (one of Franchesca's features)

---

## Notes
- Test the alpha release by making a new account
- Since we have not added the ability to create categories yet, here is a sample user:
  - **Username:** mel@mel.com
  - **Password:** supersecurepassword
