#  TrackLocation

TrackLocation is a small app for displaying the user's location on a map and calculating the distance traveled.

#  Description

The TrackLocation app tracks the user's location even when your app is not running.
The user can start and stop tracking at any time. It also shows the distance traveled by the user.
If the user starts tracking, the app will calculate the distance traveled whether it is running or not.
It will stop calculating the distance only after the user stops it manually.
After the tracking stops, the distance traveled will become zero.

#  Getting started

1. Make sure you have the Xcode version 14.0 or above installed on your computer.
2. Download the TrackLocation project files from the repository.
3. Open the project files in Xcode.
4. Run the active scheme and once it starts running, stop it before you start using it.

#  Usage

It is recommended to run the app on a real device, not on a simulator.
If you are using a simulator, you will need to simulate location changes for the app to work.
To simulate a location change, open the iOS simulator, open "Features" in the upper left corner 
of the screen, select "Location" and choose one of your preferred simulation methods.
Tap on the "Start Tracking" button and you will be prompted to give the app permission to track your location.
If you select "Allow Once", you will give the app one-time permission to track your location. 
The next time you open the app, you will be prompted to give permission again.
If you select "Allow While Using App", you will give the app a "provisional" always permission.
The next time you open the app, you will not be asked for permission, but you will be prompted to change 
the permission to "Always Allow" (make it non provisional) or return back to "Allow While Using App" permission at a certain point in time.
If you select "Don't allow", the app will not be able to track your location (you can change the permission later in the app settings).
Make sure to select "Allow While Using App" during the first prompt and "Change To Always Allow" during the second prompt 
to give the app permission to track your location when it is in the foreground, in the background, or not running at all.
Tap on the "Stop Tracking" button if you want to stop tracking. You can start tracking again, but the distance traveled will be reset to zero.
If you are using a simulator, please make sure location simulation is enabled for the app to work properly.

# Dependencies

* 'Swinject' is a dependency injection framework that allows you to get loosely-coupled components in your app.
