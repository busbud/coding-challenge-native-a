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
    static Typeface interstate;
    private City destination;
    private City origin;
    private TextView fromView;
    private Button search;
    private AutoCompleteTextView toView;

    public static SearchFragment getInstance() {
        SearchFragment fragment = new SearchFragment();
        return fragment;
    }

    public void setOrigin(City origin) {
        this.origin = origin;
        if (origin != null) {
            fromView.setText(origin.fullName);
            toView.setAdapter(new CityAdapter(getActivity(), origin));
        }
    }

    public void setDestination(City destination) {
        this.destination = destination;
        if (search != null) {
            search.setEnabled(destination != null);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        interstate = Typeface.createFromAsset(getActivity().getAssets(), "fonts/Interstate.ttf");
        View rootView = inflater.inflate(R.layout.fragment_search, container, false);
        fromView = (TextView) rootView.findViewById(R.id.from_tv);
        fromView.setTypeface(interstate);

        search = ((Button) rootView.findViewById(R.id.search));
        search.setTypeface(interstate);
        search.setText("\uD83D\uDD0D " + getString(R.string.search));
        // Button is disabled until a valid city is selected
        search.setEnabled(false);
        toView = (AutoCompleteTextView) rootView.findViewById(R.id.to_tv);
        toView.setTypeface(interstate);
        toView.requestFocus();
        toView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                setDestination(((CityAdapter) parent.getAdapter()).getCity(position));
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
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (savedInstanceState == null) {
            LocationFragment locationFragment = new LocationFragment();
            locationFragment.setTargetFragment(this, 42);
            locationFragment.show(getFragmentManager(), "location");
        } else {
            setOrigin((City) savedInstanceState.getSerializable("origin"));
            setDestination((City) savedInstanceState.getSerializable("destination"));
        }

    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putSerializable("origin", origin);
        outState.putSerializable("destination", destination);
    }
}
