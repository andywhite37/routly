package routly;

import js.Browser.*;
import js.html.HashChangeEvent;

import routly.IRouteEmitter;

class RouteEmitterBase implements IRouteEmitter {
  public var subscribers(default, null) : Array<IRouteHandler>;

  public function new() {
    subscribers = [];
    bindEvents();
  }

  function bindEvents() : Void {
    // No-op in base class
    // Subclass can override to bind native events from the constructor
  }

  function getCurrentRawRoute() : String {
    // Cannot implement in base class
    // Subclass should override to get the current route
    throw new thx.error.AbstractMethod();
  }

  function cleanRawRoute(route : String) : String {
    // Default implementation of cleaning a route for publishing
    if (route == null || route == "") {
      route = "/";
    }
    if (route.charAt(0) == "#") {
      route = route.substring(1);
    }
    if (route == "") {
      route = "/";
    }
    return StringTools.urlDecode(route);
  }

  public function emitCurrentRoute() {
    var route = getCurrentRawRoute();
    route = cleanRawRoute(route);
    for (subscriber in subscribers) {
      subscriber.onRouteChange(route);
    }
  }

  public function subscribeRouteChange(router : IRouteHandler) : Void {
    subscribers.push(router);
  }
}
