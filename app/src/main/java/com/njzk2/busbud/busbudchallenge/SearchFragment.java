package com.njzk2.busbud.busbudchallenge;

import android.app.Fragment;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
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
        // Trigger the search with empty query
        toView.setText("");
        // Threshold < 1 is still 1, so the drop down is shown on touch
        toView.setThreshold(1);
        toView.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                toView.showDropDown();
                return false;
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
