package routly;

import utest.Assert;

class TestRoutly {
  public var emitter : FakeRouteEmitter;
  public var router : Routly;

  public function new () {}


  public function setup() {
    emitter = new FakeRouteEmitter("/");
    router = new Routly(emitter);
  }

  public function testIssue20160113v2() {
    router.routes([
      "/products" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/products/:slug" => function(?descriptor : RouteDescriptor) {
        Assert.same("fake-slug", descriptor.arguments.get("slug"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/products/fake-slug");
  }

  public function testIssue20160112() {
    router.routes([
      "/" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/users" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/users");
  }

  public function testIssue20160112v2() {
    router.routes([
      "/" => function(?descriptor : RouteDescriptor) {
        Assert.fail("path should not match");
      },
      "/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.same("123", descriptor.arguments.get("id"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/~123");
  }

  public function testIssue20160113() {
    router.routes([
      "/orders" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/orders/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/orders/~:orderId/lines/~:lineId" => function(?descriptor : RouteDescriptor) {
        Assert.same("P4NK3A", descriptor.arguments.get("orderId"));
        Assert.same("df3914a1-e7a8-43bd-a457-6c644b77ba35", descriptor.arguments.get("lineId"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/orders/~P4NK3A/lines/~df3914a1-e7a8-43bd-a457-6c644b77ba35");
  }

  public function testIssue20151229() {
    router.routes([
      "/users/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/users/create" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/users/create");
  }

  public function testIssue20151211() {
    router.listen({ emitInitialRoute: false });

    router.routes([
      "/a/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/b/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.same("123", descriptor.arguments.get("id"));
      }
    ]);
    emitter.setTestRoute("/b/~123");

    router.routes([
      "/a/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.same("123", descriptor.arguments.get("id"));
      },
      "/b/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      }
    ]);
    emitter.setTestRoute("/a/~123");
  }

  public function testBasePathWithInitialFire() {
    router.routes([
      "/" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: true });
  }

  public function testBasePathWithoutInitialFire() {
    router.routes([
      "/" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/");
  }

  public function testPathWithNoArguments() {
    router.routes([
      "/test" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test");
  }

  public function testPathMatchesWithOneArgument() {
    router.routes([
      "/test/~:id" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test/~1");
  }

  public function testPathMatchesWithMultipleArguments() {
    router.routes([
      "/test/~:id1/foo/~:id2/bar/~:id3" => function(?descriptor : RouteDescriptor) {
        Assert.same("123", descriptor.arguments.get("id1"));
        Assert.same("456", descriptor.arguments.get("id2"));
        Assert.same("789", descriptor.arguments.get("id3"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test/~123/foo/~456/bar/~789");
  }

  public function testBasePathQueryStringOneKVP() {
    router.routes([
      "/" => function(?descriptor : RouteDescriptor) {
        Assert.equals(descriptor.query.get("hello"), "world");
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/?hello=world");
  }

  public function testQueryStringOneKVP() {
    router.routes([
      "/test/~:id1/foo/~:id2/bar/~:id3" => function(?descriptor : RouteDescriptor) {
        Assert.same("world", descriptor.query.get("hello"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test/~123/foo/~456/bar/~789?hello=world");
  }

  public function testQueryStringMultipleKVPs() {
    router.routes([
      "/test/~:id1/foo/~:id2/bar/~:id3" => function(?descriptor : RouteDescriptor) {
        Assert.same("world", descriptor.query.get("hello"));
        Assert.same("bar", descriptor.query.get("foo"));
        Assert.same("y", descriptor.query.get("x"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test/~123/foo/~456/bar/~789?hello=world&foo=bar&x=y");
  }

  public function testQueryStringOneFlag() {
    router.routes([
      "/test/~:id1/foo/~:id2/bar/~:id3" => function(?descriptor : RouteDescriptor) {
        Assert.isTrue(descriptor.query.exists("flag"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test/~123/foo/~456/bar/~789?flag");
  }

  public function testQueryStringMultipleFlags() {
    router.routes([
      "/test/~:id1/foo/~:id2/bar/~:id3" => function(?descriptor : RouteDescriptor) {
        Assert.isTrue(descriptor.query.exists("flagX"));
        Assert.isTrue(descriptor.query.exists("flagY"));
        Assert.isTrue(descriptor.query.exists("flagZ"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test/~123/foo/~456/bar/~789?flagX&flagY&flagZ");
  }

  public function testQueryStringMixingKVPsAndFlags() {
    router.routes([
      "/test/~:id1/foo/~:id2/bar/~:id3" => function(?descriptor : RouteDescriptor) {
        Assert.isTrue(descriptor.query.exists("flagX"));
        Assert.isTrue(descriptor.query.exists("flagY"));
        Assert.isTrue(descriptor.query.exists("flagZ"));
        Assert.same("bar", descriptor.query.get("foo"));
        Assert.same("world", descriptor.query.get("hello"));
        Assert.same("two", descriptor.query.get("one"));
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/test/~123/foo/~456/bar/~789?foo=bar&flagX&hello=world&flagY&one=two&flagZ");
  }

  public function testEmptyPath() {
    router.routes([
      "/" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("");
  }

  public function testUnknownPath() {
    router.routes([
      "/exists" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      }
    ]);
    router.unknown(function(message : String, descriptor : RouteDescriptor) : Void {
      Assert.same("no route match found for path: /nonexistent", message);
    });
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/nonexistent");
  }

  public function testSimilarPaths() {
    router.routes([
      "/foo/test" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/test/foo" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/test" => function(?descriptor : RouteDescriptor) {
        Assert.fail();
      },
      "/foo" => function(?descriptor : RouteDescriptor) {
        Assert.pass();
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/foo");
  }

  public function testUnencodedPath() {
    router.routes([
      "/orders/~:orderId" => function(?descriptor : RouteDescriptor) {
        Assert.same("ABC123", descriptor.arguments["orderId"]);
      }
    ]);
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/orders/~ABC123");
  }

  public function testEncodedPath() {
    router.routes([
      "/orders/~:orderId" => function(?descriptor : RouteDescriptor) {
        Assert.same("ABC123", descriptor.arguments["orderId"]);
      }
    ]);
    router.unknown(function(message, desc) {
      Assert.fail();
    });
    router.listen({ emitInitialRoute: false });
    emitter.setTestRoute("/orders/%7EABC123");
  }
}
