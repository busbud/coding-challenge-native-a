# Installation
Pods need to be installed for a Swift projet. Xcode 6 is required.

$ gem install cocoapods --pre

$ cd /path/to/project

$ pod install

Now use the generated .xcodeworkspace to launch the project!

Note: Since this app uses location services, it is better to test it from an iOS device.

# Notes
Style guide used to implement the solution: `https://github.com/raywenderlich/swift-style-guide`
- In Swift, classes should NOT be prefixed. (i.e. City model is named City and not BBCity)



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
