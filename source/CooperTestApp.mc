import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class CooperTestApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new CooperTestView() ] as Array<Views or InputDelegates>;
    }
}

function getApp() as Application.AppBase {
    return new CooperTestApp();
}
