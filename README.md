# Requirements
Write a native Busbud app that
- uses geo-location to find the user's current city as an origin city
- allows the user to find and choose their destination city from the origin city
- loads a web view of the page for the origin and destination
   - the url to load is `https://www.busbud.com/:lang/bus-schedules/:origin.city_url/:destination.city_url`

## Non-functional requirements
- The code should be hosted on github, and the repo should be shared with Busbud and submitted as a pull request
- The repo should include 3 screenshots under the `/screenshots` folder to show the app usage:
   - the geolocation result for the origin
   - the dropdown for the destination choice
   - the web view of the appropriate page

#Supporting API

##Usage
    curl 'https://busbud-napi-prod.global.ssl.fastly.net/search?lang=en&limit=5&lat=45.5019&lon=-73.5853' \
    -H 'X-Busbud-Token: GUEST_9f_femkwS4-6kOX6V5qjPg'

- All API calls are made against https://busbud-napi-prod.global.ssl.fastly.net/search
- All API calls support localization via the `lang` parameter
- In order to issue an authorized request against the suggestion endpoint, a long-lived guest token must be obtained from `https://busbud-napi-prod.global.ssl.fastly.net/auth/guest` and passed as the value of the `X-Busbud-Token` HTTP Header


##Search
    
###GET /search?q=`:prefix`&lang=`:lang`&limit=`:limit`&lat=`:geo.latitude`&lon=`:geo.longitude`&origin_id=`:origin.city_id`
Returns a list of the top cities supported by Busbud that are closest to the supplied `geo` location. 
- Optionally filter by `:prefix` if `q` is specified.
- Optionally filter by connectivity to `:origin` if `origin_id` is specified; supply the origin's `city_id` when specifying the parameter

   ```
    // GET /search?q=Mont&lang=fr&limit=5&lat=45.5019&lon=-73.5853
    [
      {
       "city_id": "375dd5879001acbd84a4683dedfb933e",
       "city_url": "Montreal,Quebec,Canada",
       "full_name": "Montréal, Québec, Canada"
      },
      {
       "city_id": "375dd5879001acbd84a4683dede3ff0a",
       "city_url": "Montpelier,Vermont,UnitedStates",
       "full_name": "Montpelier, Vermont, United States"
      },
      {
       "city_id": "47d4ea85048e645185b005865a0a1969",
       "city_url": "Montmagny,Quebec,Canada",
       "full_name": "Montmagny, Quebec, Canada"
      },
      {
       "city_id": "47d4ea85048e645185b005865a09e260",
       "city_url": "MontJoli,Quebec,Canada",
       "full_name": "Mont-Joli, Quebec, Canada"
      },
      {
       "city_id": "1bd27fec73a7b466133eaba87d12cf5d",
       "city_url": "Montgomery,Alabama,UnitedStates",
       "full_name": "Montgomery, State of Alabama, United States"
      }
     ]
   ```


# Solution

This is my way to solve the coding challenge (time spend : 7 hours).
Most of the error cases are handled, but I did not process an advanced QA testing.

## Global configuration 

The solution is for Android. Tested on Nexus 4 only.
The solution has been developed on AndroidStudio with gradle.
This app is only traduced in French and English. All the texts are in dedicated files. For the API, we use the current device language code (lang parameter).

I started with a basic fresh Android app. To simplify dependencies for this PoC, I used:
- minSdkVersion 16
- targetSdkVersion 21

I used support lib and AppCompat, but I didn't test on older devices.

We basically need to have two mains permissions:
- Internet access: to access the API
- Geolocation: As we don't need to have a very accurate position, I used Coarse Geolocation that costs less in battery than the GPS and that is faster.

## Solution

Globally, we have a search API that is called in a specific way. The API is a basic HTTP - REST JSON API.
Of course all the calls has to be done in a background thread in order to not block the UI.
I used a singleton to abstract the X-BusBud-Token long live token (BBHttpHelper.java). The singleton also handles a unique HTTPClient. We are on mobile, let's reuse, reuse, reuse. There is a small helper that is dedicated to parse the JSON.
The only model object is the BBCity.java that is parcelable to be passed through screens. I added a getShortName() to display a title on the Result WebView screen.

For the UI, I used AutocompleteTextView, and I tweaked a bit the behavior, but a good approach is to re-implement a full search screen with nicer UX, a bit like: http://cyrilmottier.com/2014/05/20/custom-animations-with-fragments/

I started by added some key classes to make the API calls. And I wrote some unit tests to check that the API responds the way the README.md describes.

Then I started a small UI implementation using fragments:
- TutorialFragment: to explain the app, only if you never clicked on "Search bus tickets" before
- SearchFragment: to locate the user and let him search
- ResultFragment: WebView with two BBCity object parameters to display the results

The search fragment is the one that is listening to the location. Once the location is found, we make an asynchronous call the the API to find the closest origin city.
While we are looking for position and getting the closest City, the edit text inputs and search buttons are diabled.
As we don't use GPS, but coarse location, it's really fast.

Once the city is found, the inputs are enabled to the user. We set the "from" field to the found origin city and the focus is on the "to" field.
There are some errors cases that are basically handled:
- no location service on device (can happen on Android)
- API issue or no connectivity

The user can then search for a city into the second input text area.

NOTE: I extended a bit what was asked: the user can change the origin city. In that case the destination city input is erased. And once a new origin city is used, the origin_id is also changed in all API calls.

If the users have selected two valid cities, the search will open the web view.
Otherwise a toast is displayed.

There is a loader while the web page is loading, because it's very long.

And then... Here we are.
