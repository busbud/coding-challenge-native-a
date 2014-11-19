package com.njzk2.busbud.busbudchallenge;

import android.app.Fragment;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
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
        final City origin = (City) getArguments().getSerializable("city");

        Typeface interstate = Typeface.createFromAsset(getActivity().getAssets(), "fonts/Interstate.ttf");
        View rootView = inflater.inflate(R.layout.fragment_search, container, false);
        final TextView fromView = (TextView) rootView.findViewById(R.id.from_tv);
        fromView.setTypeface(interstate);
        fromView.setText(origin.fullName);

        final Button search = ((Button) rootView.findViewById(R.id.search));
        search.setTypeface(interstate);
        // Button is disabled until a valid city is selected
        search.setEnabled(false);
        final AutoCompleteTextView toView = (AutoCompleteTextView) rootView.findViewById(R.id.to_tv);
        toView.setTypeface(interstate);
        toView.requestFocus();
        final CityAdapter adapter = new CityAdapter(getActivity(), origin);
        toView.setAdapter(adapter);
        toView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                destination = adapter.getCity(position);
                search.setEnabled(true);
            }
        });
        toView.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i2, int i3) {
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int start, int count, int after) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                // Disable the search button as soon as the content changes
                if (destination == null || !editable.toString().equals(destination.fullName)) {
                    search.setEnabled(false);
                } else {
                    search.setEnabled(true);
                }
            }
        });
        toView.setThreshold(1);
        search.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (destination != null) {
                    ((CityListener) getActivity()).selected(origin, destination);
                }
            }
        });

        return rootView;
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putSerializable("destination", destination);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if (savedInstanceState != null) {
            destination = (City) savedInstanceState.getSerializable("destination");
        }
    }

}
