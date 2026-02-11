## v.13.0-alpha

* Renamed "FriendView" to "RelationshipView" and associated files/ assets. 
* Initiated relationshipViews. 

## v1.2.0-alpha

* Added Settings screen with glass-style background card
* Displayed authenticated user details (email and user ID)
* Integrated Sign Out action within settings card
* Ensured settings layout adapts correctly to safe areas and screen sizes

## v1.1.0-alpha

* Introduced full Category management system (view, add, list, delete)
* Added dedicated Categories screen with stable card-based layout
* Implemented Add Category card with name validation, icon picker grid, and animated add interaction
* Added icon-based categories using SF Symbols with visual selection feedback
* Implemented swipe-to-delete for categories with destructive action
* Added empty-state handling when no categories exist
* Integrated Category persistence with Supabase (insert, fetch, delete)
* Ensured category list height stability with scrollable overflow
* Reset category input state after successful creation
* Refined category UI with material backgrounds, rounded cards, and consistent spacing

## v1.0.0-alpha (project restart)

* Full project restart with a new architecture and redesigned UI
* Introduced dual time modes: switch seamlessly between Timer and Stopwatch
* Locked clock controls while a session is active to prevent accidental changes
* Added background time tracking so sessions continue accurately when the app is inactive or backgrounded
* Implemented custom animated background support
* Improved state management across timer lifecycle (idle, running, paused, completed)
* Refactored session handling for better reliability and future extensibility
* General UI polish, layout stability improvements, and internal cleanup
* Gradient integrated into progressbar of timer 

## v0.9.0-alpha

* Completed TimerControlView with circular dial, countdown, and reset flow
* Integrated StudySession insertion on timer completion (Supabase-backed)
* Improved session list rendering and layout stability

## v0.8.2-alpha

* Removal of sessions and friends integrated. 
* In conjunction with removal of data, toasts added. 
* initialised began user testing

## v0.8.1-alpha

* Allows editing of nickname and email.
* Cleaner UI. 

## v0.8.0-alpha

* Introduced ToastAlertView: toast alerts when adding tags or adding friends. Later to be implemented for a variety of notifications. Also informed user of errors.  

