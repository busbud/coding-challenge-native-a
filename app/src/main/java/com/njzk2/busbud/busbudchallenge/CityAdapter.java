package com.njzk2.busbud.busbudchallenge;

import android.content.Context;
import android.location.Location;
import android.widget.ArrayAdapter;
import android.widget.Filter;

import com.njzk2.busbud.busbudchallenge.api.City;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Created by simon on 18/11/14.
 */
public class CityAdapter extends ArrayAdapter<String> {
    private List<City> resultList = new ArrayList<City>();
    private Location location;
    private City origin;


    public CityAdapter(Context context, City origin) {
        super(context, android.R.layout.simple_list_item_1, android.R.id.text1);
        this.origin = origin;
        this.location = location;
    }

    @Override
    public int getCount() {
        return resultList.size();
    }

    @Override
    public String getItem(int index) {
        return resultList.get(index).fullName;
    }

    public City getCity(int index) {
        return resultList.get(index);
    }

    @Override
    public Filter getFilter() {
        Filter filter = new Filter() {
            @Override
            protected FilterResults performFiltering(CharSequence constraint) {
                FilterResults filterResults = new FilterResults();
                if (constraint == null) {
                    constraint = "";
                }
                // Retrieve the autocomplete results.
                resultList = MainActivity.service.listCities(MainActivity.getToken(), Locale.getDefault().getLanguage(),
                        constraint.toString(), origin.cityId);

                filterResults.values = resultList;
                filterResults.count = resultList.size();
                return filterResults;
            }

            @Override
            protected void publishResults(CharSequence constraint, FilterResults results) {
                if (results != null && results.count > 0) {
                    notifyDataSetChanged();
                }
                else {
                    notifyDataSetInvalidated();
                }
            }};
        return filter;
    }
}
