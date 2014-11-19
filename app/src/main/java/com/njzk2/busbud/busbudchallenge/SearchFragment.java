package com.njzk2.busbud.busbudchallenge;

import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.TextView;

import com.njzk2.busbud.busbudchallenge.api.City;

/**
 * Created by simon on 18/11/14.
 */
public class SearchFragment extends Fragment {
    private City destination;

    public static SearchFragment getInstance(City city) {
        SearchFragment fragment = new SearchFragment();
        Bundle bundle = new Bundle();
        bundle.putSerializable("city", city);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_search, container, false);
        final TextView fromView = (TextView) rootView.findViewById(R.id.from_tv);
        final City origin = (City) getArguments().getSerializable("city");
        fromView.setText(origin.fullName);

        final Button search = ((Button) rootView.findViewById(R.id.search));
        // Button is disabled until a valid city is selected
        search.setEnabled(false);
        final AutoCompleteTextView toView = (AutoCompleteTextView) rootView.findViewById(R.id.to_tv);
        final CityAdapter adapter = new CityAdapter(getActivity(), origin);
        toView.setAdapter(adapter);
        toView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                destination = adapter.getCity(position);
                search.setEnabled(true);
            }
        });

        return rootView;
    }
}
