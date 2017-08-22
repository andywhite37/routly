package routly;

interface IRouteHandler {
  public function onRouteChange(route : String) : Void;
}

interface IRouteEmitter {
  public function emitCurrentRoute() : Void;
  public function subscribeRouteChange(handler : IRouteHandler) : Void;
}
