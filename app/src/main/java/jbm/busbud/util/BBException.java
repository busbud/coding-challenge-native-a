package jbm.busbud.util;

/**
 * Goal: unify basic API exceptions
 *
 * @author Jean-Baptiste Morin - jb.morin@gmail.com
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
