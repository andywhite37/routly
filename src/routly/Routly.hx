package routly;

import thx.Error;
using thx.Strings;

import routly.IRouteEmitter;

class Routly implements IRouteHandler {
  var routeEmitter(default, null) : IRouteEmitter;
  var routeHandlers(default, null) : Map<String, RouteDescriptor -> Void>;
  var unknownPathCallback(default, null) : String -> RouteDescriptor -> Void;

  public function new(routeEmitter : IRouteEmitter) {
    this.routeEmitter = routeEmitter;
    this.routeHandlers = new Map();
    this.unknownPathCallback = (message, desc) -> { throw new Error('ERROR: no unknown path callback configured! (message: $message, descriptor: $desc)'); };
  }

  public function routes(routeHandlers : Map<String, RouteDescriptor -> Void>) : Void {
    this.routeHandlers = routeHandlers;
  }

  public function unknown(callback : String -> RouteDescriptor -> Void) : Void {
    this.unknownPathCallback = callback;
  }

  public function onRouteChange(path : String) : Void {
    var descriptor = findMatch(path);

    if (descriptor == null) {
      unknownPathCallback('no route match found for path: $path', new RouteDescriptor(path));
      return;
    }

    var key = descriptor.virtual;
    var routeHandler = routeHandlers.get(key);

    if (routeHandler == null) {
      unknownPathCallback('no route handler found for path: $path', new RouteDescriptor(path));
      return;
    }

    routeHandler(descriptor);
  }

  public function listen(options: { emitInitialRoute : Bool }) {
    routeEmitter.subscribeRouteChange(this);
    if (options.emitInitialRoute) {
      routeEmitter.emitCurrentRoute();
    }
  }

  private function findMatch(path : String) : RouteDescriptor {
    // check each registered route for a match against
    // the raw path, return the matching key if one is found
    for(virtualPath in routeHandlers.keys()) {
      // SHOULD THE matches METHOD INSTEAD TAKE 2 ARRAYS?
      // THIS WAY WE DON'T SPLIT THE RAW PATH OVER AND OVER
      var descriptor = matches(path, virtualPath);
      if (descriptor != null)
        return descriptor;
    }
    return null;
  }

  private function matches(rawPath : String, virtualPath : String) : RouteDescriptor {
    // we want to strip everything after the question mark
    var questionMarkIndex = rawPath.lastIndexOf("?");
    var formatted = if (questionMarkIndex > 0) rawPath.substring(0, questionMarkIndex) else rawPath;

    // compare the raw route with the parameterized route
    // "/test/:id" becomes ["test", ":id"]
    var routeSplit = virtualPath.trimCharsLeft("/").split("/");
    if (routeSplit == null || routeSplit.length == 0)
      throw "we have registered an empty route apparently?";

    // split up the raw route, e.g., "/test/1" becomes ["test", "1"]
    var rawSplit = formatted.trimCharsLeft("/").split("/");
    if (rawSplit == null || rawSplit.length == 0)
      throw "bad path, where are the slashes?! : " + formatted;

    // simple check against the # of segments, which must be equal
    if (routeSplit.length != rawSplit.length) return null;

    // since the lengths match, we now must walk the path and check that
    // each segment is identical OR the raw segment contains a colon (but the content of the segment BEFORE
    // the colon must still match)
    for(i in 0...rawSplit.length) {
      var colonIndex = routeSplit[i].indexOf(":");
      var segmentMismatch = colonIndex == -1 && rawSplit[i] != routeSplit[i];
      if (segmentMismatch) return null;

      var argumentSegmentMismatch = colonIndex != -1 && rawSplit[i].substring(0, colonIndex) != routeSplit[i].substring(0, colonIndex);
      if (argumentSegmentMismatch) return null;
    }

    // the raw path does match the given virtual path
    return new RouteDescriptor(
      rawPath,
      virtualPath,
      parseArguments(rawSplit, routeSplit),
      parseQueryString(rawPath)
    );
  }

  // takes in the split virtual and raw paths and returns an array of IDs
  // i.e., raw path /test/123/foo/456/bar/789 will return ["123", "456", "789"]
  private function parseArguments(raw : Array<String>, virtual : Array<String>) : Map<String, String> {

    if (raw == null || virtual == null || raw.length != virtual.length)
      throw "invalid arrays passed to buildDescriptor.  must be non-null and equal length.";

    var arguments = new Map<String, String>();
    for(i in 0...raw.length) {
      var colonIndex = virtual[i].indexOf(":");
      if (colonIndex > -1)
        arguments.set(virtual[i].substring(colonIndex + 1), raw[i].substring(colonIndex));
    }

    return arguments;
  }

  private function parseQueryString(rawPath : String) : Map<String, String> {
    if (rawPath == null)
      throw "Invalid url passed to parseQueryString: " + rawPath;

    var results = new Map<String, String>();

    // strip everything to to the left of (and including) the question mark
    var startIndex = rawPath.lastIndexOf("?");
    if (startIndex > -1) {

      // split into key-values separate by ampersands
      var pairs = rawPath.substring(startIndex + 1).split("&");

      // build our dictionary
      for(pair in pairs) {
        var split = pair.split("=");

        // simply add each key-value-air or flag to the dictionary
        results.set(StringTools.urlDecode(split[0]), if (split.length == 2) StringTools.urlDecode(split[1]) else "");
      }
    }

    return results;
  }
}
