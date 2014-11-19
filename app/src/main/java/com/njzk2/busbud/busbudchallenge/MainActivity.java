package com.njzk2.busbud.busbudchallenge;

import android.app.Activity;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.njzk2.busbud.busbudchallenge.api.City;
import com.njzk2.busbud.busbudchallenge.api.Token;

import retrofit.RestAdapter;
import retrofit.converter.GsonConverter;


public class MainActivity extends Activity implements CityListener {

    static BusbudService service;
    // Being static, the token lives as long as the application is not destroyed.
    private static String token;

    /**
     * Call me on a bg thread only, this performs network operation
     *
     * @return
     */
    public static String getToken() {
        if (MainActivity.token == null) {
            Token token = MainActivity.service.getToken();
            if (token.success) {
                MainActivity.token = token.token;
            }
        }
        return token;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Gson gson = new GsonBuilder()
                .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
                .create();

        RestAdapter restAdapter = new RestAdapter.Builder()
                .setEndpoint("https://busbud-napi-prod.global.ssl.fastly.net/")
                .setConverter(new GsonConverter(gson))
                .build();
        service = restAdapter.create(BusbudService.class);

        setContentView(R.layout.activity_main);
        if (savedInstanceState == null) {
            new LocationFragment().show(getFragmentManager(), "location");
        }
    }

    @Override
    public void found(City city) {
        getFragmentManager().beginTransaction()
                .add(R.id.container, SearchFragment.getInstance(city))
                .commit();
    }
}
