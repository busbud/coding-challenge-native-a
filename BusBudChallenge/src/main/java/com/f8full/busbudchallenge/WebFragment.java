package com.f8full.busbudchallenge;

import android.graphics.drawable.AnimationDrawable;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ProgressBar;

/**
 * Created by F8Full on 14-01-26.
 */
public class WebFragment extends Fragment {

    public static final String EXTRA_URL = "url";

    private String mUrl = null;

    private ProgressBar mPBar = null;
    private ImageView mImageView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mUrl = getArguments().getString(EXTRA_URL);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_web, container, false);

        mPBar = (ProgressBar) view.findViewById(R.id.web_view_progress);

        FrameLayout view1 = (FrameLayout) view.findViewById(R.id.web_view);

        mImageView = new ImageView(getActivity());
        mImageView.setBackgroundColor(getResources().getColor(R.color.busbud_blue));
        mImageView.setImageResource(R.drawable.big_image_loading);
        mImageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        mImageView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                 ViewGroup.LayoutParams.MATCH_PARENT));
        mImageView.post(new Runnable() {
             @Override
             public void run() {
                 ((AnimationDrawable) mImageView.getDrawable()).start();
             }
         });
        view1.addView(mImageView);


        WebView webview = new WebView(getActivity());
        webview.setVisibility(View.GONE);

        if (mUrl != null) {
            webview.setWebViewClient(new MyWebViewClient());
            webview.setWebChromeClient(new MyWebChromeClient());
            webview.getSettings().setUseWideViewPort(true);
            webview.getSettings().setBuiltInZoomControls(true);
            webview.getSettings().setLoadWithOverviewMode(true);
            webview.getSettings().setSupportZoom(true);
            webview.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
            webview.getSettings().setAllowFileAccess(true);
            webview.getSettings().setDomStorageEnabled(true);
            webview.getSettings().setJavaScriptEnabled(true);
            webview.getSettings().setAppCacheEnabled(true);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB)
                webview.getSettings().setDisplayZoomControls(false);

            webview.loadUrl(mUrl);
        }
        view1.addView(webview);


        return view;
    }

    public class MyWebChromeClient extends WebChromeClient {

        @Override
        public void onProgressChanged(WebView view, int progress)
        {
            if (progress < 100 && mPBar.getVisibility() == ProgressBar.GONE)
                mPBar.setVisibility(ProgressBar.VISIBLE);
            mPBar.setProgress(progress);
            if (progress == 100)
                mPBar.setVisibility(ProgressBar.GONE);
        }
    }

    public class MyWebViewClient extends WebViewClient {

        @Override
        public void onPageFinished(WebView view, String url) {
            view.setVisibility(View.VISIBLE);
            final Animation fade = new AlphaAnimation(0.0f, 1.0f);
            fade.setDuration(200);
            view.startAnimation(fade);
            view.setVisibility(View.VISIBLE);
        }
    }
}
