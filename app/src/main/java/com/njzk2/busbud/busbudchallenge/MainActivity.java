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
    static String token;

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
                .add(R.id.container, new PlaceholderFragment())
                .commit();
    }

    /**
     * A placeholder fragment containing a simple view.
     */
    public static class PlaceholderFragment extends Fragment {

        public PlaceholderFragment() {
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_search, container, false);
            return rootView;
        }
    }
}
