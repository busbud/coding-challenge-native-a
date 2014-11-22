package jbm.busbud.api;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.params.HttpProtocolParams;
import org.json.JSONObject;

import jbm.busbud.util.BBException;
import jbm.busbud.util.StringUtils;

/**
 * Singleton that store the long live token or retrieve it if needed, and that execute requests
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
 */
public class BBHttpHelper {

    /*
     * STATIC VARS
     */
    public interface JSONNodes {
        public final String SUCCESS = "success";
        public final String TOKEN = "token";
    }

    private static final String X_BUSBUD_TOKEN_HEADER = "X-Busbud-Token";

    /*
     * SINGLETON METHODS
     */
    private static BBHttpHelper sInstance;

    public static BBHttpHelper getInstance() {
        if (sInstance == null) {
            sInstance = new BBHttpHelper();
        }
        return sInstance;
    }

    /**
     * The long live busbud token
     */
    private String mXBusbudToken;

    /**
     * A single re-used HTTP Client
     */
    private HttpClient mHttpClient = getHttpClient();

    /**
     * In order to get a better HTTP client that will
     * be more accurate on slow mobile networks
     *
     * @return
     */
    private static HttpClient getHttpClient() {
        final HttpParams params = new BasicHttpParams();
        HttpConnectionParams.setConnectionTimeout(params, 20 * 1000);
        HttpConnectionParams.setSoTimeout(params, 20 * 1000);
        HttpConnectionParams.setSocketBufferSize(params, 8192);
        HttpProtocolParams.setUserAgent(params, "BusBudAndroidApplication");
        return new DefaultHttpClient(params);
    }

    /**
     * This method dress an HTTP request.
     * Beware it does a request synchronously.
     *
     * @param url
     * @return
     */
    public HttpResponse httpGetBusBudUrl(String url) throws BBException {
        try {
            final HttpGet request = new HttpGet(url);
            if (mXBusbudToken == null || !isXBusbudTokenValid()) {
                final HttpGet requestAuth = new HttpGet(APIUrls.AUTH_URL_BASE);
                final HttpResponse response = mHttpClient.execute(requestAuth);
                if (response.getStatusLine().getStatusCode() == HttpStatus.SC_OK) {
                    // Response format:
                    // {"success":true,"token":"GUEST_DKK_cmXESSe-HEMYCNqs2Q","admin":false,"employee":false}
                    JSONObject result = new JSONObject(StringUtils.fromInputStream(response.getEntity().getContent()));
                    if (result.optBoolean(JSONNodes.SUCCESS, false) && result.has(JSONNodes.TOKEN)) {
                        mXBusbudToken = result.getString(JSONNodes.TOKEN);
                    } else {
                        // TODO BBException
                        throw new IllegalArgumentException("Service not available");
                    }
                } else {
                    // TODO BBException
                    throw new IllegalArgumentException("Service not available");
                }
            }
            request.addHeader(X_BUSBUD_TOKEN_HEADER, mXBusbudToken);
            return mHttpClient.execute(request);
        } catch (Exception e) {
            throw new BBException(e);
        }
    }

    public void cancel() {
        ClientConnectionManager manager = mHttpClient.getConnectionManager();
        if (manager != null) {
            manager.shutdown();
        }
    }

    private boolean isXBusbudTokenValid() {
        // TODO : Is the token still available?
        // TODO : API documentation missing.
        return true;
    }
}
