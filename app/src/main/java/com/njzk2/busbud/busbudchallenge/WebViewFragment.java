package com.njzk2.busbud.busbudchallenge;

import android.app.Fragment;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;

import com.njzk2.busbud.busbudchallenge.api.City;

/**
 * Created by simon on 13/11/2014.
 */
public class WebViewFragment extends Fragment {

    public static WebViewFragment getInstance(City from, City to) {
        WebViewFragment fragment = new WebViewFragment();
        Bundle bundle = new Bundle();
        bundle.putString("from", from.cityUrl);
        bundle.putString("to", to.cityUrl);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        final WebView webView = new WebView(getActivity());
        webView.loadUrl("https://www.busbud.com/:lang/bus-schedules/" + getArguments().getString("from") + "/" + getArguments().get("to"));
        return webView;
    }

}
