# Requirements
Write a native Busbud app that
- uses geo-location to find the user's current city as an origin city
- allows the user to choose their destination city from the origin city
- loads a web view of the page for the origin and destination
   - the url to load is `http://www.busbud.com/:lang/bus-schedules/:origin_city.urlform/:destination_city.urlform`

## Non-functional requirements
- The code should be hosted on github, and the repo should be shared with Busbud and submitted as a pull request
- The repo should include 3 screenshots under the `/screenshots` folder to show the app usage:
   - the geolocation result for the origin
   - the dropdown for the destination choice
   - the web view of the appropriate page

#Supporting API

##Usage
    curl -X GET \
    -H "X-Busbud-Application-ID: ${APPLICATION_ID}" \
    -H "X-Busbud-Device-Token: ${DEVICE_TOKEN}" \
    https://api-staging.busbud.com/en/api/v1/currencies

- All API calls are made against https://api-staging.busbud.com
- All API calls support localization via the language parameter
- All API calls require two authorizing headers, `X-Busbud-Application-ID` and `X-Busbud-Device-Token`
  - Apply to get an Application ID
  - Device tokens can be dynamically generated, but must be at least 22 url-safe-base64 characters in length.

##Search
    
###GET /`:lang`/api/v1/search/locations/?latitude=`:geo.latitude`&longitude=`:geo.longitude`&accuracy=`:geo.accuracy`
Returns a list of the top cities supported by Busbud that are closest to the supplied `geo` location. Accuracy should be supplied in _meters_ if value is decimal, or with units otherwise

    // GET /en/api/v1/search/locations/?latitude=45.5247&longitude=-73.5894&accuracy=10
    {
        "current": {
            "distance": 1.7678974003806247, 
            "fullname": "Montreal, Quebec, Canada", 
            "name": "Montreal", 
            "timezone": "America/Montreal", 
            "urlform": "Montreal,Quebec,Canada"
        }, 
        "locations": [
            {
                "distance": 42.95185556130974, 
                "fullname": "Saint-Jérôme, Quebec, Canada", 
                "name": "Saint-Jérôme", 
                "timezone": "America/Montreal", 
                "urlform": "SaintJerome,Quebec,Canada"
            }
        ]
    }

###GET /`:lang`/api/v1/search/locations-from/`:origin_city.urlform`/`:prefix`
Returns a list of the top cities supported by Busbud that can be reached by bus from `:origin_city`. The list of cities is filtered to cities that start with `:prefix`. 

    // GET /en/api/v1/search/locations-from/Montreal,Quebec,Canada/T
    {
        "from": {
            "fullname": "Montreal, Quebec, Canada", 
            "name": "Montreal", 
            "timezone": "America/Montreal", 
            "urlform": "Montreal,Quebec,Canada"
        }, 
        "locations": [
            {
                "fullname": "Toronto, Ontario, Canada", 
                "name": "Toronto", 
                "urlform": "Toronto,Ontario,Canada"
            }, 
            {
                "fullname": "Trois-Rivières, Quebec, Canada", 
                "name": "Trois-Rivières", 
                "urlform": "TroisRivieres,Quebec,Canada"
            }
        ]
    }

##Settings
###GET /`:lang`/api/v1/languages
Returns a list of all languages supported by Busbud. The `code` is used the replace the `:lang` parameter in API calls.

    GET /en/api/v1/languages
    [
        {"code": "de", "label": "Deutsch"},
        {"code": "en", "label": "English"},
        {"code": "es", "label": "Español"},
        {"code": "fr", "label": "Français"},
        {"code": "it", "label": "Italiano"},
        {"code": "nl", "label": "Nederlands"},
        {"code": "pl", "label": "Polski"},
        {"code": "pt", "label": "Português"},
        {"code": "sv", "label": "Svenska"},
        {"code": "tr", "label": "Türkçe"}
    ]
