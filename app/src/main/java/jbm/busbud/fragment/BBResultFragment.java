package jbm.busbud.fragment;

import android.content.ActivityNotFoundException;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import java.util.Locale;

import jbm.busbud.R;
import jbm.busbud.api.APIUrls;
import jbm.busbud.model.BBCity;

/**
 * The search web view
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBResultFragment extends Fragment {

    private static String URL_FMT = "https://www.busbud.com/%s/bus-schedules/%s/%s";

    public static final String ARGS_FROM = "jbm.busbud.fragment.Search.FROM";
    public static final String ARGS_TO = "jbm.busbud.fragment.Search.TO";

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        if (container == null) {
            return null;
        }

        if (getArguments() == null || !getArguments().containsKey(ARGS_FROM) || !getArguments().containsKey(ARGS_TO)) {
            // Fragment argument error => close the activity with a toast.
            Toast.makeText(getActivity(), R.string.choose_a_valid_city, Toast.LENGTH_SHORT).show();
            getActivity().finish();
            return null;
        }

        // Retrieve parameters
        BBCity fromCity = getArguments().getParcelable(ARGS_FROM);
        BBCity toCity = getArguments().getParcelable(ARGS_TO);

        // Init the web view and load the URL
        WebView webView = new WebView(container.getContext());
        webView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        webView.getSettings().setJavaScriptEnabled(true);
        webView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return false;
            }
        });
        webView.loadUrl(
                String.format(Locale.getDefault(),
                        URL_FMT,
                        Locale.getDefault().getLanguage(),
                        fromCity.getCityUrl(),
                        toCity.getCityUrl()));
        return webView;
    }
}
