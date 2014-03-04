# Submission

## Configuration

You will need to rename conf.h.default to conf.h and supply a valid application identifier for access to the busbud staging API in 
"Busbud App/Busbud App/"

## App Flow

- Upon launching the application, you will see "Loading..." and an activity indicator.
- This will be displayed until a GPS location is found, and the busbud API returns a location for the latitude, longitude, and error values.
- Once the API has returned the current location, a "Find a bus" button will appear on the screen. Tapping on this will take you to select a destination.
- Tapping on a location will load the web view to purchase the fare. You can go back to select a new destination by tapping the "Back" button in the upper left corner of the screen.