package routly;

class FakeRouteEmitter extends RouteEmitterBase {
  public var testRoute(default, default) : String;

  public function new(testRoute : String) {
    super();
    this.testRoute = testRoute;
  }

  override function getCurrentRawRoute() : String {
    return this.testRoute;
  }

  // method for faking a route change from unit tests
  public function setTestRoute(testRoute : String) : Void {
    this.testRoute = testRoute;
    emitCurrentRoute();
  }
}
