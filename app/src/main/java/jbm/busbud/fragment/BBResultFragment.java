package jbm.busbud.fragment;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

/**
 * The search web view
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBResultFragment extends Fragment {

    public static final String ARGS_FROM = "jbm.busbud.fragment.Search.FROM";
    public static final String ARGS_TO = "jbm.busbud.fragment.Search.TO";

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    public class ARGS_TO {
    }
}
