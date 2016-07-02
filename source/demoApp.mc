using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class demoApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart() {
    	System.println("on start");
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    	System.println("on stop");
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new demoView() ];
    }

    //! New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        Ui.requestUpdate();
    }

}