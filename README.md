coding-challenge-native-a
=========================

Write a native Busbud app that
- uses geo-location to find the user's current city as an origin city
- allows the user to choose their destination city from the origin city
- loads a web view of the page for the origin and destination

#Supporting API

##Search

###GET /`:lang`/api/v1/search/locations/`:prefix`
Returns a list of the top cities supported by Busbud matching the search prefix `:prefix`.

    // GET /en/api/v1/search/locations/Mon
    {
        "locations": [
            {
                "fullname": "Montevideo, Montevideo, Uruguay", 
                "name": "Montevideo", 
                "urlform": "Montevideo,Montevideo,Uruguay"
            }, 
            {
                "fullname": "Monroeville, Pennsylvania, United States", 
                "name": "Monroeville", 
                "urlform": "Monroeville,Pennsylvania,UnitedStates"
            }, 
            {
                "fullname": "Montreal, Quebec, Canada", 
                "name": "Montreal", 
                "urlform": "Montreal,Quebec,Canada"
            }, 
            {
                "fullname": "Mont-Laurier, Quebec, Canada", 
                "name": "Mont-Laurier", 
                "urlform": "MontLaurier,Quebec,Canada"
            }
        ]
    }
    
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

###GET /`:lang`/api/v1/search/locations-from/`:fromcity.urlform`/`:prefix`
Returns a list of the top cities supported by Busbud that can be reached by bus from `:fromcity`. The list of cities is filtered to cities that start with `:prefix`. 

    // GET /en/api/v1/search/locations-from/Montreal,Canada/T
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


