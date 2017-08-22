package routly;

import js.Browser;
import js.html.HashChangeEvent;

class HashChangeRouteEmitter extends RouteEmitterBase {
  public function new() {
    super();
  }

  override function bindEvents() : Void {
    // wrap the browser's window.onhashchange, which fires a
    // js.html.HashChangeEvent, which must be converted to a regular
    // string representing the new hash-path.  E.g., if the url is changed
    // to http://blah.com/#/test, then emit will be called with path "/test"
    Browser.window.onhashchange = function(changeEvent : HashChangeEvent) {
      if (changeEvent.newURL == changeEvent.oldURL) {
        return;
      }
      emitCurrentRoute();
    }
  }

  override function getCurrentRawRoute() : String {
    return Browser.window.location.hash;
  }
}
