package com.njzk2.busbud.busbudchallenge;

import com.njzk2.busbud.busbudchallenge.api.City;
import com.njzk2.busbud.busbudchallenge.api.Token;

import java.util.List;
import java.util.Locale;

import retrofit.http.GET;
import retrofit.http.Header;
import retrofit.http.Query;

/**
 * Created by simon on 11/11/2014.
 */
public interface BusbudService {

    @GET("/auth/guest")
    Token getToken();

    /**
     * Find the five closest city matching the query and connected to origin
     * @param token
     * @param lang
     * @param query
     * @param origin
     * @return
     */
    @GET("/search?limit=5")
    List<City> listCities(@Header("X-Busbud-Token") String token, @Query("lang") String lang,
                          @Query("q") String query,
                          @Query("origin_id") String origin);

    /**
     * Find the closest city
     * @param token
     * @param lang
     * @param lat
     * @param lon
     * @return
     */
    @GET("/search?limit=1")
    List<City> getCity(@Header("X-Busbud-Token") String token, @Query("lang") String lang,
                       @Query("lat") double lat, @Query("lon") double lon);
}
