package jbm.busbud.util;

/**
 * Goal: unify basic API exceptions
 * Created by jbm on 14-11-19.
 */
public class BBException extends Exception {

    public BBException() {
    }

    public BBException(String detailMessage) {
        super(detailMessage);
    }

    public BBException(String detailMessage, Throwable throwable) {
        super(detailMessage, throwable);
    }

    public BBException(Throwable throwable) {
        super(throwable);
    }
}
